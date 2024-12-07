import 'dart:io';
import 'dart:typed_data';
import 'dart:isolate';

import 'package:p2p/controller/auth_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:p2p/widgets/text_message.dart';
import 'package:p2p/widgets/file_message.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class WebSocketService extends GetxService {
  IO.Socket? socket;
  bool isConnected = false;
  final myKey =
      encrypt.Key.fromUtf8("wfiWtWJLjqDr3gZRNKCPYQyBR/hk3b7qrnJIz8i2f+Y=");
  final iv = encrypt.IV.fromLength(16);
  late final encrypt.Encrypter encrypter;

  // Change messages to an RxList of Widgets
  final RxList<Widget> messages = <Widget>[].obs;

  // for sharing files in chunks
  final RxMap<String, List<Uint8List>> fileChunks =
      <String, List<Uint8List>>{}.obs;

  // Add a new RxList to store incoming file notifications
  final RxList<Map<String, dynamic>> fileNotifications =
      <Map<String, dynamic>>[].obs;

  String getUsername() {
    return AuthController.instance.auth.currentUser!.email!.split('@')[0];
  }

  WebSocketService() {
    encrypter =
        encrypt.Encrypter(encrypt.AES(myKey, mode: encrypt.AESMode.cbc));
  }

  void initialize() {
    socket = IO.io(
      'http://192.168.39.97:5000', // Replace with your host machine's IP address
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({
            'token': '123',
            'username': getUsername()
          }) // Include the authentication token
          .build(),
    );
    if (isConnected == false) {
      socket!.connect();
    }

    socket!.onConnect((_) {
      isConnected = true;
      print('Connected to Socket.IO server');
    });

    socket!.onConnectError((data) {
      isConnected = false;
      print('Connection Error: $data');
    });

    socket!.onDisconnect((_) {
      isConnected = false;
      print('Disconnected from server');
    });

    // Update event handler for incoming messages
    socket!.on('message', (data) {
      print("MESSAGE RECEIVED: $data");

      // Create a TextMessage widget and add it to messages
      messages.add(TextMessage(
        sender: data['username'],
        message: data['message'],
        roomId: data['room'],
      ));
    });

    handleIncommingFileChunks();
  }

  void sendMessage(String message, String room) {
    final username = getUsername();
    print('Sending message: $username, $room, $message');
    socket?.emit('message', {
      'username': username,
      'room': room, // Use 'room' instead of 'group_id'
      'message': message,
    });
  }

  void joinRoom(String room) {
    socket?.emit('join', {
      'username': getUsername(),
      'room': room,
    });
  }

  void leaveRoom(String room) {
    socket?.emit('leave', {
      'username': getUsername(),
      'room': room,
    });
  }

  void sendFile(String filePath, String room) async {
    final receivePort = ReceivePort();

    // Spawn an isolate and pass the sendPort
    await Isolate.spawn(_sendFileIsolate, {
      'sendPort': receivePort.sendPort,
      'filePath': filePath,
      'chunkSize': 1024, // 1KB chunk size
      'username': getUsername(),
      'room': room,
    });

    receivePort.listen((data) {
      // Receive data from the isolate and emit via socket
      if (data['event'] == 'file_chunk') {
        socket?.emit('file_chunks', data['chunkData']);
      } else if (data['event'] == 'end_file') {
        socket?.emit('end_file', data['endData']);
        receivePort.close();
      }
    });
  }

  void handleIncommingFileChunks() {
    socket?.on('file_chunks', (data) async {
      final receivePort = ReceivePort();

      // Spawn an isolate to handle incoming file chunks
      await Isolate.spawn(_handleFileChunkIsolate, {
        'sendPort': receivePort.sendPort,
        'data': data,
        'appDirPath': (await getApplicationDocumentsDirectory()).path,
      });

      receivePort.listen((message) {
        if (message['event'] == 'file_saved') {
          // Update UI with the new file message
          messages.add(FileMessage(
            filename: message['filename'],
            sender: message['sender'],
            filePath: message['filePath'],
            roomId: message['room'],
          ));
          receivePort.close();
        }
      });
    });

    socket?.on('end_file', (data) {
      if (data == null) return;
      print("File transfer completed: $data");
      final filename = data['filename'];
      final sender = data['username'];
      // Remove the notification when file transfer is complete
      fileNotifications
          .removeWhere((notification) => notification['filename'] == filename);
    });
  }

  void dispose() {
    socket?.disconnect(); // this function is used to disconnect the socket
    // No need to close messages as ValueNotifier doesn't require it
  }
}

// Top-level function to send file in an isolate
void _sendFileIsolate(Map<String, dynamic> args) async {
  final sendPort = args['sendPort'] as SendPort;
  final filePath = args['filePath'] as String;
  final chunkSize = args['chunkSize'] as int;
  final username = args['username'] as String;
  final room = args['room'] as String;

  final file = File(filePath);
  final fileStream = file.openRead();
  int chunkNumber = 0;
  final totalChunks = (file.lengthSync() / chunkSize).ceil();
  final filename = file.path.split('/').last;
  final filesize = file.lengthSync();
  final filetype = file.path.split('.').last;

  await for (final binaryChunk in fileStream) {
    for (int i = 0; i < binaryChunk.length; i += chunkSize) {
      int end = (i + chunkSize < binaryChunk.length)
          ? i + chunkSize
          : binaryChunk.length;
      Uint8List chunk = Uint8List.fromList(binaryChunk.sublist(i, end));
      chunkNumber++;

      // Send chunk data back to main isolate
      sendPort.send({
        'event': 'file_chunk',
        'chunkData': {
          'username': username,
          'room': room,
          'chunk': chunk,
          'filename': filename,
          'filetype': filetype,
          'filesize': filesize,
          'total_chunks': totalChunks,
          'current_chunk_number': chunkNumber,
        },
      });
    }
  }

  // Notify main isolate that file transfer is complete
  sendPort.send({
    'event': 'end_file',
    'endData': {
      'username': username,
      'room': room,
      'filename': filename,
    },
  });
}

// Top-level function to handle incoming file chunks in an isolate
void _handleFileChunkIsolate(Map<String, dynamic> args) async {
  final sendPort = args['sendPort'] as SendPort;
  final data = args['data'] as Map<String, dynamic>;
  final appDirPath = args['appDirPath'] as String;

  final chunk = data['chunk'] as Uint8List;
  final filename = data['filename'] as String;
  final totalChunks = data['total_chunks'] as int;
  final currentChunkNumber = data['current_chunk_number'] as int;
  final sender = data['username'] as String;
  final room = data['room'] as String;

  // Use a temporary directory to store chunks
  final tempDir = Directory('$appDirPath/TempChunks/$filename');
  if (!await tempDir.exists()) {
    await tempDir.create(recursive: true);
  }
  final chunkFile = File('${tempDir.path}/part_$currentChunkNumber');
  await chunkFile.writeAsBytes(chunk);

  // Check if all chunks are received
  final chunkFiles = tempDir
      .listSync()
      .whereType<File>()
      .where((file) => file.path.contains('part_'))
      .toList();

  if (chunkFiles.length == totalChunks) {
    // Combine all chunks into a single file
    final downloadPath = '$appDirPath/Downloads';
    final downloadDir = Directory(downloadPath);
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    final file = File('$downloadPath/$filename');
    final fileStream = file.openWrite(mode: FileMode.writeOnlyAppend);

    for (int i = 1; i <= totalChunks; i++) {
      final partFile = File('${tempDir.path}/part_$i');
      final bytes = await partFile.readAsBytes();
      fileStream.add(bytes);
      await partFile.delete(); // Delete chunk after adding
    }

    await fileStream.close();
    await tempDir.delete(recursive: true); // Delete the temp directory

    // Notify main isolate that file is saved
    sendPort.send({
      'event': 'file_saved',
      'filename': filename,
      'sender': sender,
      'filePath': '$downloadPath/$filename',
      'room': room,
    });
  }
}

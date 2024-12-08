import 'dart:io';
import 'dart:typed_data';
import 'dart:isolate';

import 'package:p2p/controller/auth_controller.dart';
import 'package:p2p/models/typing_user.dart';
import 'package:p2p/widgets/room_message.dart';
import 'package:p2p/widgets/typing_indicator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:p2p/widgets/text_message.dart';
import 'package:p2p/widgets/file_message.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class WebSocketService extends GetxService {
  IO.Socket? socket;
  final myKey = encrypt.Key.fromUtf8("ASDFGHJKLASDFGHJ");
  final iv = encrypt.IV.fromLength(16);
  late final encrypt.Encrypter encrypter;
  Rx<bool> isConnected = false.obs;

  final RxList<TypingIndicator> typingUsers = <TypingIndicator>[].obs;
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
      'http://192.168.56.1:5000', // Replace with your host machine's IP address
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({
            'token': '123',
            'username': getUsername()
          }) // Include the authentication token
          .build(),
    );
    if (isConnected.value == false) {
      socket!.connect();
    }

    socket!.onConnect((_) {
      isConnected.value = true;
      print('Connected to Socket.IO server');
      Get.snackbar("Success", "Connected to server");
    });
    socket!.onReconnect((_) {
      isConnected.value = true;
      print('Reconnected to Socket.IO server');
    });

    socket!.onConnectError((data) {
      Get.snackbar("Error", "Connection Error with socket server");
      isConnected.value = false;
      print('Connection Error: $data');
    });
    socket!.onError((data) {
      Get.snackbar("Error", "Error with socket server");
      isConnected.value = false;
      print('Error: $data');
    });

    socket!.onDisconnect((_) {
      Get.snackbar("Disconnected", "Disconnected from server");
      isConnected.value = false;
      print('Disconnected from server');
    });

    // Update event handler for incoming messages
    socket!.on('message', (data) {
      print("MESSAGE RECEIVED: $data");
      // Decrypt the message
      final message = encrypter.decrypt64(data['message'], iv: iv);
      // Create a TextMessage widget and add it to messages
      messages.add(TextMessage(
        sender: data['username'],
        message: message,
        roomId: data['room'],
      ));
    });

    handleIncommingFileChunks();
    handleJoinRoom();
    handleLeaveRoom();
  }

  // function to listen new members joining the room
  void handleJoinRoom() {
    socket?.on('join', (data) {
      final String username = data['username'];
      final String room = data['room'];
      print("JOIN RECEIVED: $username");

      messages.add(RoomMessage(
        message: '$username joined the room',
        roomId: room,
      ));
      print(messages.length);
    });
  }

  void emitUserTyping(String room) {
    socket?.emit('typing', {
      'username': getUsername(),
      'room': room,
    });
  }

  void handleUserTyping() {
    socket?.on('typing', (data) {
      final username = data['username'];
      final room = data['room'];
      print("$username is typing in $room");
      if (username == getUsername()) return;
      typingUsers.add(TypingIndicator(username: username, roomId: room));
    });
  }

  void emitUserStoppedTyping(String room) {
    socket?.emit('stop_typing', {
      'username': getUsername(),
      'room': room,
    });
  }

  void handleUserStoppedTyping() {
    socket?.on('stop_typing', (data) {
      final username = data['username'];
      final room = data['room'];
      print("$username stopped typing in $room");
      typingUsers.removeWhere((user) => user.username == username);
    });
  }

  // function to listen member leaving the room
  void handleLeaveRoom() {
    socket?.on('leave', (data) {
      print("LEAVE RECEIVED: $data");
      final username = data['username'];
      final String room = data['room'];
      //final room = data['room'];
      messages.add(RoomMessage(
        message: '$username left the room',
        roomId: room,
      ));
    });
  }

  void sendMessage(String message, String room) {
    final username = getUsername();
    final String encryptedMsg = encrypter.encrypt(message, iv: iv).base64;
    print('Sending message: $username, $room, $encryptedMsg');
    socket?.emit('message', {
      'username': username,
      'room': room, // Use 'room' instead of 'group_id'
      'message': encryptedMsg,
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
    // messages.add(RoomMessage(
    //   message: 'You left the room',
    //   roomId: room,
    // ));
  }

  void sendFile(String filePath, String room) async {
    final file = File(filePath);
    final fileStream = file.openRead();
    final buffer = <Uint8List>[];
    final int chunkSize = (file.lengthSync() / 5).floor(); // Dynamic chunk size

    // Read the file in chunks
    await for (final binaryChunk in fileStream) {
      for (int i = 0; i < binaryChunk.length; i += chunkSize) {
        int end = (i + chunkSize < binaryChunk.length)
            ? i + chunkSize
            : binaryChunk.length;
        Uint8List chunk = Uint8List.fromList(binaryChunk.sublist(i, end));
        buffer.add(chunk);

        socket?.emit('file_chunks', {
          'username': getUsername(),
          'room': room,
          'chunk': chunk,
          'filename': file.path.split('/').last,
          'filetype': file.path.split('.').last,
          'filesize': file.lengthSync(),
          'total_chunks': (file.lengthSync() / chunkSize).ceil(),
          'current_chunk_number': buffer.length,
        });
      }
    }

    // Notify all users that file transfer is complete
    socket?.emit('end_file', {
      'username': getUsername(),
      'room': room,
      'filename': file.path.split('/').last,
    });
  }

  void handleIncommingFileChunks() {
    socket?.on('file_chunks', (data) async {
      print("FILE CHUNK RECEIVED: $data");
      final chunk = data['chunk'];
      final filename = data['filename'];
      final filetype = data['filetype'];
      final filesize = data['filesize'];
      final totalChunks = data['total_chunks'];
      final currentChunkNumber = data['current_chunk_number'];
      final sender = data['username'];
      final room = data['room'];

      if (!fileChunks.containsKey(filename)) {
        // Initialize the list with empty Uint8List
        fileChunks[filename] =
            List<Uint8List>.filled(totalChunks, Uint8List(0), growable: true);

        // Add a notification for the new incoming file
        fileNotifications.add({
          'filename': filename,
          'filesize': filesize,
          'sender': sender,
          'room': room,
        });
      }
      if (fileChunks[filename]!.isEmpty || fileChunks[filename] == null) {
        fileChunks[filename] =
            List<Uint8List>.filled(totalChunks, Uint8List(0), growable: true);
      }

      fileChunks[filename]![currentChunkNumber - 1] = chunk;
      // Check if all chunks are received
      if (fileChunks[filename]!.every((element) => element.isNotEmpty)) {
        // Combine all chunks into a single file
        final Directory appDocumentsDir =
            await getApplicationDocumentsDirectory();
        final downloadPath = '${appDocumentsDir.path}/Downloads';
        final downloadDir = Directory(downloadPath);
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        final file = File('$downloadPath/$filename');
        final fileStream = file.openWrite(mode: FileMode.writeOnlyAppend);
        for (final chunk in fileChunks[filename]!) {
          fileStream.add(chunk);
        }
        await fileStream.close();
        fileChunks.remove(filename);
        // store the file in the messages list
        messages.add(FileMessage(
          filename: filename,
          sender: sender,
          filePath: '$downloadPath/$filename',
          roomId: room,
        ));
        // Remove the notification when file transfer is complete
        fileNotifications.removeWhere(
            (notification) => notification['filename'] == filename);
      }
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

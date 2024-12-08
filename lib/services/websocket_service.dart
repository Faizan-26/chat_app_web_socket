library;

import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:p2p/controller/auth_controller.dart'; // Your auth controller
import 'package:p2p/widgets/room_message.dart'; // Your custom widgets
import 'package:p2p/widgets/typing_indicator.dart';
import 'package:p2p/widgets/text_message.dart';
import 'package:p2p/widgets/file_message.dart';
import 'package:path_provider/path_provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class TypingUser {
  final String username;
  final String roomId;

  TypingUser({required this.username, required this.roomId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TypingUser &&
          runtimeType == other.runtimeType &&
          username == other.username &&
          roomId == other.roomId;

  @override
  int get hashCode => username.hashCode ^ roomId.hashCode;
}

class WebSocketService extends GetxService {
  IO.Socket? socket;
  final myKey = encrypt.Key.fromUtf8("ASDFGHJKLASDFGHJ");
  final iv = encrypt.IV.fromLength(16);
  late final encrypt.Encrypter encrypter;
  Rx<bool> isConnected = false.obs;

  final RxSet<TypingUser> typingUsers = <TypingUser>{}.obs;
  final RxList<Widget> messages = <Widget>[].obs;
  
  // incomingFiles["$room-$filename"] = {
  //   'chunks': List<Uint8List>,
  //   'total': int,
  //   'receivedCount': int,
  //   'filePath': String
  // }
  final RxMap<String, Map<String, dynamic>> incomingFiles =
      <String, Map<String, dynamic>>{}.obs;

  // Data related to the file currently being sent
  // sendingFileData = {
  //   'room': room,
  //   'filename': filename,
  //   'filetype': filetype,
  //   'filesize': filesize,
  //   'total_chunks': int,
  //   'chunks': {chunkNumber: Uint8List}
  // }
  Map<String, dynamic> sendingFileData = {};

  String getUsername() {
    return AuthController.instance.auth.currentUser!.email!.split('@')[0];
  }

  WebSocketService() {
    encrypter =
        encrypt.Encrypter(encrypt.AES(myKey, mode: encrypt.AESMode.cbc));
  }

  String encryptMsg(String message) {
    final iv = encrypt.IV.fromLength(16); // Generate a new IV for each message
    final encrypted = encrypter.encrypt(message, iv: iv);
    print('Encrypting message: $message');
    print('Encryption key: ${myKey.base64}');
    print('IV: ${iv.base64}');
    print('Encrypted message: ${encrypted.base64}');
    // Include the IV with the encrypted message
    return jsonEncode({'iv': iv.base64, 'message': encrypted.base64});
  }

  String decrypt(String encryptedData) {
    final data = jsonDecode(encryptedData);
    final iv = encrypt.IV.fromBase64(data['iv']);
    final message = data['message'];
    print('Decrypting message: $message');
    print('Encryption key: ${myKey.base64}');
    print('IV: ${iv.base64}');
    final decrypted = encrypter.decrypt64(message, iv: iv);
    print('Decrypted message: $decrypted');
    return decrypted;
  }

  void initialize() {
    socket = IO.io(
      'http://10.54.9.21:5000', // Replace with your server IP or domain
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': '123', 'username': getUsername()})
          .build(),
    );

    if (!isConnected.value) {
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

    socket!.on('message', (data) {
      print("MESSAGE RECEIVED: $data");
      try {
        final decryptedMessage = decrypt(data['message']);
        messages.add(TextMessage(
            sender: data['username'],
            message: decryptedMessage,
            roomId: data['room'],
            timestamp: DateTime.now()));
      } catch (e) {
        print('Decryption error: $e');
      }
    });

    handleFileEvents();
    handleJoinRoom();
    handleLeaveRoom();
    handleUserTyping();
    handleUserStoppedTyping();
  }

  void handleJoinRoom() {
    socket?.on('join', (data) {
      final String username = data['username'];
      final String room = data['room'];
      messages.add(RoomMessage(
        message: '$username joined the room',
        roomId: room,
      ));
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
      if (username == getUsername()) return;
      typingUsers.add(TypingUser(username: username, roomId: room));
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
      typingUsers.remove(TypingUser(username: username, roomId: room));
    });
  }

  void handleLeaveRoom() {
    socket?.on('leave', (data) {
      final username = data['username'];
      final String room = data['room'];
      messages.add(RoomMessage(
        message: '$username left the room',
        roomId: room,
      ));
    });
  }

  void sendMessage(String message, String room) {
    final username = getUsername();
    final encryptedMsg = encryptMsg(message);
    socket?.emit('message', {
      'username': username,
      'room': room,
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
  }

  Future<void> sendFile(String filePath, String room) async {
    final file = File(filePath);
    final fileSize = await file.length();
    const int chunkSize = 64 * 1024;
    final totalChunks = (fileSize / chunkSize).ceil();

    final fileBytes = await file.readAsBytes();
    final fileName = file.path.split('/').last;
    final fileType = fileName.contains('.') ? fileName.split('.').last : 'bin';

    // Store metadata for retransmissions
    sendingFileData = {
      'room': room,
      'filename': fileName,
      'filetype': fileType,
      'filesize': fileSize,
      'total_chunks': totalChunks,
      'chunks': {}
    };

    int currentChunkNumber = 0;
    for (int offset = 0; offset < fileBytes.length; offset += chunkSize) {
      currentChunkNumber++;
      final end = (offset + chunkSize < fileBytes.length)
          ? offset + chunkSize
          : fileBytes.length;
      Uint8List chunk = fileBytes.sublist(offset, end);

      // Compute per-chunk checksum
      final chunkChecksum = md5.convert(chunk).toString();

      // Store chunk for possible retransmission
      sendingFileData['chunks'][currentChunkNumber] = chunk;

      final encodedChunk = base64Encode(chunk);
      socket?.emit('file_chunks', {
        'username': getUsername(),
        'room': room,
        'chunk': encodedChunk,
        'filename': fileName,
        'filetype': fileType,
        'filesize': fileSize,
        'total_chunks': totalChunks,
        'current_chunk_number': currentChunkNumber,
        'chunk_checksum': chunkChecksum
      });
    }

    // After sending all chunks
    socket?.emit('end_file', {
      'username': getUsername(),
      'room': room,
      'filename': fileName,
    });

    // Copy the file to the app directory for the sender
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    final downloadPath = '${appDocumentsDir.path}/Downloads';
    final downloadDir = Directory(downloadPath);
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    final receivedFilePath = '$downloadPath/$fileName';
    await file.copy(receivedFilePath);

    // Notify the sender by adding the file message to the messages list
    messages.add(FileMessage(
      filename: fileName,
      sender: getUsername(),
      filePath: receivedFilePath,
      roomId: room,
      timestamp: DateTime.now(),
    ));
  }

  void handleFileEvents() {
    // Received a chunk from someone else (not the sender)
    socket?.on('file_chunks', (data) async {
      final filename = data['filename'];
      final room = data['room'];
      final totalChunks = data['total_chunks'];
      final currentChunkNumber = data['current_chunk_number'];
      final sender = data['username'];

      // If we are the sender, we do not store our own file chunks
      if (sender == getUsername()) {
        return;
      }

      final encodedChunk = data['chunk'];
      Uint8List chunk;
      try {
        chunk = base64Decode(encodedChunk);
      } catch (e) {
        print("Failed to decode incoming file chunk: $e");
        return;
      }

      final key = "$room-$filename";
      if (!incomingFiles.containsKey(key)) {
        incomingFiles[key] = {
          'chunks': List<Uint8List>.filled(totalChunks, Uint8List(0)),
          'total': totalChunks,
          'receivedCount': 0,
          'filePath': ''
        };
      }

      var fileData = incomingFiles[key]!;
      fileData['chunks'][currentChunkNumber - 1] = chunk;
      fileData['receivedCount'] = fileData['receivedCount'] + 1;

      // If all chunks received, write to file
      if (fileData['receivedCount'] == totalChunks) {
        final Directory appDocumentsDir =
            await getApplicationDocumentsDirectory();
        final downloadPath = '${appDocumentsDir.path}/Downloads';
        final downloadDir = Directory(downloadPath);
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        final receivedFilePath = '$downloadPath/$filename';
        final outFile = File(receivedFilePath);

        final fileStream = outFile.openWrite(mode: FileMode.writeOnly);
        for (final c in fileData['chunks']) {
          fileStream.add(c);
        }
        await fileStream.close();

        fileData['filePath'] = receivedFilePath;

        // Show file message to user
        messages.add(FileMessage(
            filename: filename,
            sender: sender,
            filePath: receivedFilePath,
            roomId: room,
            timestamp: DateTime.now()));
      }
    });

    // File transfer complete notification
    socket?.on('end_file', (data) async {
      print("File transfer completed: $data");
      // By the time we get this, the receiving client should already have all chunks and written the file.
    });

    // Server requests retransmission of a specific chunk
    socket?.on('retransmit_chunk', (data) {
      final filename = data['filename'];
      final chunkNumber = data['chunk_number'];
      final room = data['room'];

      // If this matches our currently sending file
      if (sendingFileData['filename'] == filename &&
          sendingFileData['room'] == room) {
        Uint8List? chunk = sendingFileData['chunks'][chunkNumber];
        if (chunk != null) {
          final encodedChunk = base64Encode(chunk);
          final chunkChecksum = md5.convert(chunk).toString();
          final fileSize = sendingFileData['filesize'];
          final fileType = sendingFileData['filetype'];
          final totalChunks = sendingFileData['total_chunks'];

          socket?.emit('file_chunks', {
            'username': getUsername(),
            'room': room,
            'chunk': encodedChunk,
            'filename': filename,
            'filetype': fileType,
            'filesize': fileSize,
            'total_chunks': totalChunks,
            'current_chunk_number': chunkNumber,
            'chunk_checksum': chunkChecksum
          });
        }
      }
    });
  }

  @override
  void onClose() {
    socket?.disconnect();
    super.onClose();
  }
}

import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:p2p/global/gloval_service.dart';
import 'package:p2p/widgets/file_message.dart';
import 'package:p2p/widgets/room_message.dart';
import 'package:p2p/widgets/text_message.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get/get.dart';

class GroupChatPage extends StatefulWidget {
  final String groupName;
  final String groupId;

  const GroupChatPage({
    super.key,
    required this.groupName,
    required this.groupId,
  });

  @override
  GroupChatPageState createState() => GroupChatPageState();
}

class GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    _initializeWebSocket();
    webSocketService.messages.listen((_) {
      _scrollToBottom();
    });
  }

  void _initializeWebSocket() {
    webSocketService.joinRoom(widget.groupId);

    webSocketService.socket?.onDisconnect((_) {
      print('Disconnected from WebSocket');
      Get.back();
      return;
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final messageText = _messageController.text.trim();

    if (messageText.isNotEmpty) {
      webSocketService.sendMessage(
        messageText,
        widget.groupId, // Use groupId as room identifier
      );
      _messageController.clear();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    print("RECIEVED: TRUE");
    webSocketService.leaveRoom(widget.groupId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
      ),
      body: Column(
        children: [
          Obx(() {
            if (webSocketService.fileNotifications
                .map((e) => e['room'])
                .contains(widget.groupId)) {
              return const LinearProgressIndicator();
            }
            return const SizedBox();
          }),
          Expanded(
            child: Obx(() {
              final messagesList = webSocketService.messages.where((wid) {
                if (wid is TextMessage) {
                  print(wid.roomId);
                  print(widget.groupId);
                  return wid.roomId == widget.groupId;
                } else if (wid is FileMessage) {
                  return wid.roomId == widget.groupId;
                }
                if (wid is RoomMessage) {
                  return wid.roomId == widget.groupId;
                }
                return false;
              }).toList();

              if (messagesList.isEmpty) {
                return const Center(
                  child: Text('No messages yet'),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                itemCount: messagesList.length,
                itemBuilder: (context, index) {
                  return messagesList[index];
                },
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      // Implement file upload functionality here using file picker
                      FilePicker.platform.pickFiles().then((result) {
                        if (result != null) {
                          final path = result.files.single.path;
                          if (path == null) {
                            Get.snackbar(
                                "Path Error", "Cannot find specified file");
                            return;
                          }
                          webSocketService.sendFile(path, widget.groupId);
                        }
                      });
                    },
                    icon: const Icon(Icons.attach_file)),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

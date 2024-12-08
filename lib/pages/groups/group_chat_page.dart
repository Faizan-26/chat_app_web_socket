import 'dart:math';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:p2p/global/gloval_service.dart';
import 'package:p2p/widgets/file_message.dart';
import 'package:p2p/widgets/room_message.dart';
import 'package:p2p/widgets/text_message.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' as foundation;

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
  bool _isEmojiPickerVisible = false;

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

  void _toggleEmojiPicker() {
    setState(() {
      _isEmojiPickerVisible = !_isEmojiPickerVisible;
    });
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
          if (!_isEmojiPickerVisible)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  if (!_isEmojiPickerVisible)
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
                  IconButton(
                    onPressed: _toggleEmojiPicker,
                    icon: const Icon(Icons.emoji_emotions),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                      ),
                      onTap: () {
                        if (_isEmojiPickerVisible) {
                          setState(() {
                            _isEmojiPickerVisible = false;
                          });
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          if (_isEmojiPickerVisible)
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      if (!_isEmojiPickerVisible)
                        IconButton(
                            onPressed: () {
                              // Implement file upload functionality here using file picker
                              FilePicker.platform.pickFiles().then((result) {
                                if (result != null) {
                                  final path = result.files.single.path;
                                  if (path == null) {
                                    Get.snackbar("Path Error",
                                        "Cannot find specified file");
                                    return;
                                  }
                                  webSocketService.sendFile(
                                      path, widget.groupId);
                                }
                              });
                            },
                            icon: const Icon(Icons.attach_file)),
                      IconButton(
                        onPressed: _toggleEmojiPicker,
                        icon: const Icon(Icons.emoji_emotions),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Type your message...',
                          ),
                          onTap: () {
                            if (_isEmojiPickerVisible) {
                              setState(() {
                                _isEmojiPickerVisible = false;
                              });
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ).animate().slide(begin: const Offset(0, 4)),
                SizedBox(
                  height: 250, // Adjusted height for better display
                  child: EmojiPicker(
                    textEditingController: _messageController,
                    config: Config(
                      height: 250, // Adjusted height for better display
                      checkPlatformCompatibility: true,

                      emojiViewConfig: EmojiViewConfig(
                        emojiSizeMax: 28 *
                            (foundation.defaultTargetPlatform ==
                                    TargetPlatform.iOS
                                ? 1.20
                                : 1.0),
                      ),
                      viewOrderConfig: const ViewOrderConfig(
                        top: EmojiPickerItem.searchBar,
                        middle: EmojiPickerItem.emojiView,
                        bottom: EmojiPickerItem.categoryBar,
                      ),
                      skinToneConfig: const SkinToneConfig(),
                      categoryViewConfig: const CategoryViewConfig(),
                      bottomActionBarConfig: const BottomActionBarConfig(),
                      searchViewConfig: const SearchViewConfig(
                          backgroundColor: Color(0xFFEBEFF2)),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slide(begin: const Offset(0, 1)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

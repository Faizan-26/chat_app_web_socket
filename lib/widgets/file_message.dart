import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:p2p/global/gloval_service.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

class FileMessage extends StatelessWidget {
  final String filename;
  final String sender;
  final String roomId;
  final String filePath;
  final DateTime timestamp;

  const FileMessage({
    super.key,
    required this.filename,
    required this.sender,
    required this.roomId,
    required this.filePath,
    required this.timestamp,
  });

  String _getFileType(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
      return 'image';
    } else if (['mp4', 'mov', 'wmv', 'avi'].contains(extension)) {
      return 'video';
    } else {
      return 'file';
    }
  }

  IconData _getFileIcon(String fileType) {
    switch (fileType) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.videocam;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('dd/MM/yyyy HH:mm').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    final isSender =
        sender == webSocketService.getUsername(); // Replace with actual logic
    final fileType = _getFileType(filename);

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: () async {
          if (fileType == 'image') {
            Get.to(() => ImagePreview(filePath: filePath));
          } else if (fileType == 'video') {
            Get.to(() => VideoPreview(filePath: filePath));
          } else {
            final result = await OpenFile.open(filePath);
            if (result.type != ResultType.done) {
              Get.snackbar("Error", "Failed to open file");
            }
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSender
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: isSender ? const Radius.circular(12) : Radius.zero,
              bottomRight: isSender ? Radius.zero : const Radius.circular(12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isSender)
                Icon(
                  _getFileIcon(fileType),
                  color: Theme.of(context).colorScheme.secondary,
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: isSender
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      filename,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSender
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sent by $sender',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall!.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTimestamp(timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).textTheme.bodySmall!.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isSender)
                Icon(
                  _getFileIcon(fileType),
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImagePreview extends StatelessWidget {
  final String filePath;

  const ImagePreview({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PhotoView(
        imageProvider: FileImage(File(filePath)),
      ),
    );
  }
}

class VideoPreview extends StatefulWidget {
  final String filePath;

  const VideoPreview({super.key, required this.filePath});

  @override
  _VideoPreviewState createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.filePath)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}

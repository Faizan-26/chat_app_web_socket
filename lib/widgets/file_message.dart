// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart'; // Add this import
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

class FileMessage extends StatelessWidget {
  final String filename;
  final String sender;
  final String roomId;
  final String filePath; // Add this field

  const FileMessage({
    super.key,
    required this.filename,
    required this.sender,
    required this.roomId,
    required this.filePath, // Add this parameter
  });

  String _getFileType(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
      print("TYPE IS ");
      return 'image';
    } else if (['mp4', 'mov', 'wmv', 'avi'].contains(extension)) {
      print("TYPE IS VIDEO");
      return 'video';
    } else {
      print("TYPE IS FILE");
      return 'file';
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileType = _getFileType(filename);
    print("FILE PATH : $filePath");
    return ListTile(
      leading: const Icon(Icons.insert_drive_file),
      title: Text(filename),
      subtitle: Text('Sent by $sender'),
      trailing: IconButton(
        icon: const Icon(Icons.download),
        onPressed: () async {
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
      ),
    );
  }
}

class ImagePreview extends StatelessWidget {
  final String filePath;

  const ImagePreview({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    print("FILE PATH : TYPE IS IMAGE");
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

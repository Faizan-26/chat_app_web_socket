// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart'; // Add this import

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

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.insert_drive_file),
      title: Text(filename),
      subtitle: Text('Sent by $sender'),
      trailing: IconButton(
        icon: const Icon(Icons.download),
        onPressed: () async {
          // Implement file opening functionality here
          final result = await OpenFile.open(filePath);
          if (result.type != ResultType.done) {
            Get.snackbar("Error", "Failed to open file");
          }
        },
      ),
    );
  }
}

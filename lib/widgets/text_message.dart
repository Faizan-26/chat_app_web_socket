// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class TextMessage extends StatelessWidget {
  final String sender;
  final String message;
  final String roomId;

  const TextMessage({
    super.key,
    required this.sender,
    required this.message,
    required this.roomId,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(sender[0].toUpperCase())),
      title: Text(sender),
      subtitle: Text(message),
    );
  }
}

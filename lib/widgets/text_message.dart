// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:p2p/global/gloval_service.dart';

class TextMessage extends StatelessWidget {
  final String sender;
  final String message;
  final String roomId;
  final DateTime timestamp;
  const TextMessage({
    super.key,
    required this.sender,
    required this.message,
    required this.roomId,
    required this.timestamp,
  });
  String dateTimeToStringFromCurrentDateTime() {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute}';
    //}
  }

  @override
  Widget build(BuildContext context) {
    return sender == webSocketService.getUsername()
        ? rightListTile(
            sender,
            dateTimeToStringFromCurrentDateTime(),
            message,
            bubbleColor: Theme.of(context)
                .colorScheme
                .primary, // Sent message bubble color
            textColor: Theme.of(context)
                .colorScheme
                .onPrimary, // Text color on sent bubble
          )
        : leftListTile(
            sender,
            dateTimeToStringFromCurrentDateTime(),
            message,
            bubbleColor: Theme.of(context)
                .colorScheme
                .surface, // Received message bubble color
            textColor: Theme.of(context)
                .colorScheme
                .onSurface, // Text color on received bubble
          );
  }
}

Widget leftListTile(
  String leadingTextContent,
  String titleTextContent,
  String subtitleTextContent, {
  required Color bubbleColor,
  required Color textColor,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor:
              bubbleColor.darken(0.2), // Slightly darker avatar color
          child: Text(
            leadingTextContent[0].toUpperCase(),
            style: TextStyle(color: textColor),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titleTextContent,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Text(
                  subtitleTextContent,
                  style: TextStyle(color: textColor),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget rightListTile(
  String leadingTextContent,
  String titleTextContent,
  String subtitleTextContent, {
  required Color bubbleColor,
  required Color textColor,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                titleTextContent,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Text(
                  subtitleTextContent,
                  style: TextStyle(color: textColor),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          backgroundColor:
              bubbleColor.darken(0.2), // Slightly darker avatar color
          child: Text(
            leadingTextContent[0].toUpperCase(),
            style: TextStyle(color: textColor),
          ),
        ),
      ],
    ),
  );
}

extension on Color {
  Color darken(double amount) {
    return Color.fromARGB(
      alpha,
      (red * (1 - amount)).round(),
      (green * (1 - amount)).round(),
      (blue * (1 - amount)).round(),
    );
  }
}

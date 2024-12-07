// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class RoomMessage extends StatelessWidget {
  const RoomMessage({
    super.key,
    required this.message,
    required this.roomId,
  });
  final String message;
  final String roomId;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
          vertical: 5, horizontal: MediaQuery.of(context).size.width * 0.1),
      decoration: const BoxDecoration(
        color: Color.fromARGB(54, 11, 182, 235),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

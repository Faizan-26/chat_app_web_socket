import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TypingIndicator extends StatelessWidget {
  final String username;
  final String roomId;

  const TypingIndicator(
      {super.key, required this.username, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: const Dot()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: (index * 300).ms)
                  .fadeOut(duration: 500.ms, delay: (index * 300).ms),
            );
          }),
        ),
      ],
    );
  }
}

class Dot extends StatelessWidget {
  const Dot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
    );
  }
}

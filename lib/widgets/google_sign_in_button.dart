import 'package:flutter/material.dart';
import '../controller/auth_controller.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.account_circle),
        label: const Text('Continue with Google'),
        onPressed: () {
          AuthController.instance.signInWithGoogle();
        },
        style: ElevatedButton.styleFrom(
          enableFeedback: true,
          textStyle: const TextStyle(fontSize: 16),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

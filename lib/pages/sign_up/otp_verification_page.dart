import 'package:flutter/material.dart';
import '../../controller/auth_controller.dart';

class OTPVerificationPage extends StatelessWidget {
  final String email;
  final otpController = TextEditingController();
  final String passwordController;
  OTPVerificationPage(
      {required this.email, required this.passwordController, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: otpController,
              decoration: const InputDecoration(labelText: 'Enter OTP'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                AuthController.instance.verifyOTPAndCreateAccount(
                  email,
                  otpController.text.trim(),
                  passwordController,
                );
              },
              child: const Text('Verify OTP and Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}

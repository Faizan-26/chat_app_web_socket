import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/auth_controller.dart';
import '../../widgets/google_sign_in_button.dart';

class SignUpPage extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // check if email is valid
                if (!emailController.text.trim().contains('@gmail.com') &&
                    !emailController.text.trim().contains('@yahoo.com') &&
                    !emailController.text.trim().contains('@outlook.com') &&
                    !emailController.text.trim().contains('@cfd.nu.edu.pk')) {
                  Get.snackbar(
                    'Error',
                    'Please enter a valid email address',
                  );
                  return;
                }
                // check if password is valid
                if (passwordController.text.trim().length < 6) {
                  Get.snackbar(
                    'Error',
                    'Password must be at least 6 characters long',
                  );
                  return;
                }
                AuthController.instance.sendOTP(
                  emailController.text.trim(),
                  passwordController.text.trim(),
                );
              },
              child: const Text('Send OTP'),
            ),
            const SizedBox(height: 20),
            const GoogleSignInButton(),
          ],
        ),
      ),
    );
  }
}

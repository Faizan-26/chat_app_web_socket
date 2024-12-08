import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/auth_controller.dart';
import '../sign_up/page.dart';
import '../../widgets/google_sign_in_button.dart';

class LoginPage extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Hero(
              tag: 'loginimg',
              child: Image.asset(
                'assets/loginimg.png',
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.4,
              ),
            ),
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
                AuthController.instance.login(
                  emailController.text.trim(),
                  passwordController.text.trim(),
                );
              },
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () => Get.to(() => SignUpPage()),
              child: const Text('Create an Account'),
            ),
            // const SizedBox(height: 20),
            const GoogleSignInButton(),
          ],
        ),
      ),
    );
  }
}

import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../controller/auth_controller.dart';
import '../../widgets/google_sign_in_button.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final otpController = TextEditingController();

  bool isSignUp = false; // Toggle between Login and Sign-Up
  bool isOTPScreen = false; // Toggle between email/password and OTP screen
  bool isPasswordVisible = false; // Password visibility toggle

  bool isEmailValid() {
    const regex = r'^[^@]+@[^@]+\.[^@]+$';
    return RegExp(regex).hasMatch(emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(isSignUp ? 'Sign Up' : 'Login'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: size.height * 0.03), // Top spacing
              Hero(
                tag: 'authImage',
                child: Image.asset(
                  'assets/loginimg.png',
                  width: size.width * 0.7,
                  height: size.height * 0.28,
                ),
              ),
              SizedBox(height: size.height * 0.03),
              AnimatedSwitcher(
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                ),
                duration: const Duration(milliseconds: 500),
                child: isOTPScreen
                    ? _buildOTPField(context)
                    : _buildEmailPasswordFields(context),
              ),
              SizedBox(height: size.height * 0.03),
              const Hero(tag: 'continue', child: Text('Or continue with')),
              SizedBox(height: size.height * 0.03),
              const GoogleSignInButton(),
              SizedBox(height: size.height * 0.03),
              const Hero(tag: 'divider', child: Divider(thickness: 1)),
              // SizedBox(height: size.height * 0.03),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailPasswordFields(BuildContext context) {
    return Column(
      key: const ValueKey('emailPasswordFields'),
      children: [
        TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email),
          ),
        ),
        const SizedBox(height: 16),
        if (!isOTPScreen) // Hide password field on OTP screen
          TextField(
            controller: passwordController,
            obscureText: !isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(isPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
              ),
            ),
          ),
        if (!isOTPScreen && !isSignUp)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                if (!isEmailValid()) {
                  Get.snackbar("Error", "Please enter a valid email.");
                  return;
                }
                AuthController.instance.resetPassword(emailController.text);
              },
              child: const Text('Forgot Password?'),
            ),
          ),
        if (!(!isOTPScreen && !isSignUp)) const SizedBox(height: 40),
        // const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            if (isSignUp) {
              // Validate and send OTP for sign-up
              if (!isEmailValid()) {
                Get.snackbar('Error', 'Please enter a valid email address');
                return;
              }
              if (passwordController.text.trim().length < 6) {
                Get.snackbar(
                    'Error', 'Password must be at least 6 characters long');
                return;
              }
              bool isOtpSent = await EmailOTP.sendOTP(
                email: emailController.text.trim(),
              );
              if (isOtpSent) {
                setState(() {
                  isOTPScreen = true;
                });
              } else {
                Get.snackbar('Error', 'Failed to send OTP');
              }
            } else {
              // Login action
              AuthController.instance.login(
                emailController.text.trim(),
                passwordController.text.trim(),
              );
            }
          },
          child: Text(isSignUp ? 'Send OTP' : 'Login'),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms, curve: Curves.easeInOut);
  }

  Widget _buildOTPField(BuildContext context) {
    return Column(
      key: const ValueKey('otpField'),
      children: [
        TextField(
          controller: otpController,
          decoration: const InputDecoration(
            labelText: 'Enter OTP',
            prefixIcon: Icon(Icons.security),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            AuthController.instance.verifyOTPAndCreateAccount(
              emailController.text.trim(),
              otpController.text.trim(),
              passwordController.text.trim(),
            );
          },
          child: const Text('Verify OTP and Sign Up'),
        ),
      ],
    )
        .animate()
        .slideX(begin: -1, end: 0, duration: 500.ms, curve: Curves.easeInOut);
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(isSignUp ? "Already have an account?" : "Don't have an account?"),
        TextButton(
          onPressed: () {
            setState(() {
              isSignUp = !isSignUp; // Toggle between Login and Sign-Up
              isOTPScreen = false; // Reset OTP screen on toggle
            });
          },
          child: Text(isSignUp ? 'Login' : 'Sign Up'),
        ),
      ],
    );
  }
}

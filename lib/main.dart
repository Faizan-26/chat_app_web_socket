import 'package:email_otp/email_otp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/auth_controller.dart';
import 'pages/login/page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Failed to initialize Firebase: $e');
    return;
  }
  try {
    EmailOTP.config(
      appEmail: 'admin@securechat.com',
      otpLength: 6,
      otpType: OTPType.numeric,
      appName: "Secure Chat",
      expiry: 30000, // equivalent to 5 minutes
      // emailTheme: EmailTheme.v5,
    );
    EmailOTP.setTemplate(template: '''
    <div style="background-color: #f4f4f4; padding: 20px; font-family: Arial, sans-serif;">
        <div style="background-color: #fff; padding: 20px; border-radius: 10px; box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);">
          <h1 style="color: #007BFF; text-align: center;">{{appName}}</h1>
          <p style="color: #333; font-size: 18px; text-align: center;">Your OTP is <strong style="font-size: 24px; color: #007BFF;">{{otp}}</strong></p>
          <p style="color: #333; font-size: 16px; text-align: center;">This OTP is valid for 5 minutes.</p>
          <hr style="border: none; border-top: 1px solid #ddd; margin: 20px 0;">
          <p style="color: #333; font-size: 14px; text-align: center;">Thank you for using our service.</p>
          <p style="color: #333; font-size: 14px; text-align: center;">If you did not request this OTP, please ignore this email.</p>
        </div>
      </div>
    ''');
  } catch (e) {
    print('Failed to configure EmailOTP: $e');
    return;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AuthController());
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Secure Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          color: Colors.blue,
          elevation: 0,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.blue),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // Background color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue, // Text color
          ),
        ),
      ),
      home: LoginPage(),
    );
  }
}

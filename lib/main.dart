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
      expiry: 300000, // equivalent to 5 minutes
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
        primaryColor: const Color(0xFFF5F5DC), // Beige
        scaffoldBackgroundColor: const Color(0xFFFFF9F6), // Off-White
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F5DC), // Beige
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF333333), // Dark Gray
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Color(0xFF87CEEB)), // Soft Blue
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFFFF9F6), // Off-White
          labelStyle: TextStyle(color: Color(0xFF333333)), // Dark Gray
          hintStyle: TextStyle(color: Color(0xFF666666)), // Medium Gray
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Color(0xFFFFDAB9), width: 2.0), // Peach
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFD3D3D3)), // Light Gray
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF87CEEB), // Soft Blue
            foregroundColor: Colors.white, // White text
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFFFDAB9), // Peach
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF333333)), // Dark Gray
          bodySmall: TextStyle(color: Color(0xFF666666)), // Medium Gray
        ),
        iconTheme: const IconThemeData(color: Color(0xFF87CEEB)), // Soft Blue
      ),
      home: LoginPage(),
    );
  }
}

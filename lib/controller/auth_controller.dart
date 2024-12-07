import 'package:email_otp/email_otp.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/Home/page.dart';
import '../pages/login/page.dart';
import '../pages/sign_up/otp_verification_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  late Rx<User?> _user;

  FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(auth.currentUser);
    _user.bindStream(auth.userChanges());
    ever(_user, _initialScreen); // ever is a reactive function from GetX
  }

  void _initialScreen(User? user) {
    if (user == null) {
      Get.offAll(() => LoginPage());
    } else {
      Get.offAll(() => const HomePage());
    }
  }
  get userId => _user.value!.uid;

  Future<void> register(String email, String password) async {
    try {
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      Get.snackbar("Success", "Account created successfully. Please log in.");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Get.snackbar("Error",
            "The password is too weak. Please choose a stronger password.");
      } else if (e.code == 'email-already-in-use') {
        Get.snackbar("Error", "An account already exists with this email.");
      } else if (e.code == 'invalid-email') {
        Get.snackbar("Error", "The email address is invalid.");
      } else {
        Get.snackbar("Error", "Registration failed. Please try again later.");
      }
    } catch (e) {
      // Handle any other errors
      Get.snackbar("Error", "An unexpected error occurred. Please try again.");
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // Handle specific FirebaseAuth exceptions
      if (e.code == 'user-not-found') {
        Get.snackbar(
            "Error", "No user found with this email. Please check the email.");
      } else if (e.code == 'wrong-password') {
        Get.snackbar("Error", "Incorrect password. Please try again.");
      } else if (e.code == 'invalid-email') {
        Get.snackbar("Error", "The email address is invalid.");
      } else {
        Get.snackbar("Error", "Login failed. Please try again later.");
      }
    } catch (e) {
      // Handle any other errors
      Get.snackbar("Error", "An unexpected error occurred. Please try again.");
    }
  }

  Future<void> logout() async {
    await auth.signOut();
    Get.snackbar("Success", "You have logged out successfully.");
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        Get.snackbar("Error", "Google sign-in was cancelled.");
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await auth.signInWithCredential(credential);
      Get.snackbar("Success", "Signed in with Google successfully.");
    } catch (e) {
      Get.snackbar("Error", "Google sign-in failed. Please try again.");
    }
  }

  // OTP Verification
  // Function to send OTP to the user's email
  Future<void> sendOTP(String email, String passwordController) async {
    try {
      await EmailOTP.sendOTP(email: email); // Send OTP to the user's email
      Get.to(() => OTPVerificationPage(
          passwordController: passwordController,
          email: email)); // Navigate to OTP screen
    } catch (e) {
      Get.snackbar("Error", "Failed to send OTP. Please try again.");
    }
  }

  Future<void> verifyOTPAndCreateAccount(
      String email, String enteredOtp, String password) async {
    try {
      bool isVerified = EmailOTP.verifyOTP(otp: enteredOtp); // Verify the OTP
      if (!isVerified) {
        Get.snackbar("Error", "Invalid OTP. Please try again.");
        return;
      }

      await register(email, password); // Create the account
    } catch (e) {
      Get.snackbar("Error", "Failed to verify OTP. Please try again.");
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../controller/auth_controller.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: SizedBox(
          width: 24,
          height: 24,
          child: SvgPicture.string(
            googleSvg,
          ),
        ),
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

const String googleSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 488 512"><!--!Font Awesome Free 6.7.1 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2024 Fonticons, Inc.--><path d="M488 261.8C488 403.3 391.1 504 248 504 110.8 504 0 393.2 0 256S110.8 8 248 8c66.8 0 123 24.5 166.3 64.9l-67.5 64.9C258.5 52.6 94.3 116.6 94.3 256c0 86.5 69.1 156.6 153.7 156.6 98.2 0 135-70.4 140.8-106.9H248v-85.3h236.1c2.3 12.7 3.9 24.9 3.9 41.4z"/></svg>
''';

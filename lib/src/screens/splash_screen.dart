import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_management_app/src/screens/login_screen.dart';
import 'package:task_management_app/src/view/home/home_view.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateBasedOnAuthState();
  }

  Future<void> _navigateBasedOnAuthState() async {
    // Wait for 3 seconds to show splash screen
    await Future.delayed(Duration(seconds: 3));
    FlutterNativeSplash.remove();

    // Check if user is signed in
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User is signed in, go to HomeView
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // User is not signed in, go to LoginScreen
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          "assets/images/task_management_logo.png",
          width: 250,
          height: 250,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:multilogin2/utils/next_screen.dart';
import 'package:provider/provider.dart';
import 'package:multilogin2/provider/sign_in_provider.dart';
import 'package:multilogin2/screens/home_screen.dart';
import 'package:multilogin2/screens/login_screen.dart';
import '../utils/config.dart';

/// `SplashScreen` is a class that displays the splash screen of the application.
///
/// It uses `SignInProvider` to check if the user is signed in and navigate to the appropriate screen.
/// It also provides several methods to handle navigation.
///
/// Methods:
/// - `initState()`: Initializes the state of the widget. It sets a timer to navigate to the appropriate screen after a delay.
/// - `build(BuildContext context)`: Builds the widget tree for this screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// Initializes the state of the widget.
  ///
  /// It sets a timer to navigate to the appropriate screen after a delay.
  /// If the user is not signed in, it navigates to the `LoginScreen`.
  /// If the user is signed in, it navigates to the `HomeScreen`.
  @override
  void initState() {
    super.initState();
    final signInProvider = context.read<SignInProvider>();
    Timer(const Duration(seconds: 2), () {
      signInProvider.isSignedIn == false
          ? nextScreen(context, const LoginScreen())
          : nextScreen(context, const HomeScreen());
    });
  }

  /// Builds the widget tree for this screen.
  ///
  /// It displays the application's logo.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
            child: Image(
              image: AssetImage(Config.loba_icon_black),
              height: 80,
              width: 80,
            )
        ),
      ),
    );
  }
}
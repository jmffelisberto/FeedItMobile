import 'package:flutter/material.dart';
import 'package:multilogin2/provider/sign_in_provider.dart';
import 'package:provider/provider.dart';
import 'package:multilogin2/screens/login_screen.dart';
import 'package:multilogin2/utils/next_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen ({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final signInProvider = context.read<SignInProvider>();
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: Text("Sign Out"),
          onPressed: () {
            signInProvider.userSignOut();
            nextScreenReplace(context, const LoginScreen());
        }
      ),
    ));
  }
}
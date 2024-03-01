import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:multilogin2/provider/sign_in_provider.dart';
import 'package:multilogin2/screens/home_screen.dart';
import 'package:multilogin2/screens/login_screen.dart';
import '../utils/config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key:key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
  //State<SplashScreen> createState() => _SplashScreenState extends State<SplashScreen>();
}

class _SplashScreenState extends State<SplashScreen> {
  //init state
  @override
  void initState(){
    final sp = context.read<SignInProvider>();
    super.initState();
    //timer of 2 secs
    Timer(const Duration(seconds: 2), () {
      sp.isSignedIn == false 
          ? Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context)=> const LoginScreen())
      )   
          : Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context)=> const HomeScreen())
      );
    });
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Image(
            image: AssetImage(Config.app_icon),
            height: 80,
            width: 80,
          )
        ),
      ),
    );
  }
}
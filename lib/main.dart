import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:multilogin2/provider/internet_provider.dart';
import 'package:multilogin2/provider/issue_service_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:multilogin2/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'provider/sign_in_provider.dart';

void main() async {
  // initialize the application
  WidgetsFlutterBinding.ensureInitialized();

  Platform.isAndroid
      ? await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyCeAibaTC5J-9yX4FN1G4U6sTMWUuHYJiM",
        appId: "1:418688149116:android:5f5d2e2f1affc2b6484bf9",
        messagingSenderId: "418688149116",
        projectId: "multilogin2-d03cd",
      ))
      : await Firebase.initializeApp();

  //eliminateLocalInstances();

  runApp(const MyApp());
  ConnectivityService();
}


Future<void> eliminateLocalInstances() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('local_issues');
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: ((context) => SignInProvider()),
        ),
        ChangeNotifierProvider(
          create: ((context) => InternetProvider()),
        ),
      ],
      child: const MaterialApp(
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }

}
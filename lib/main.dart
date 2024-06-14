import 'dart:io';
import 'dart:ui';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:multilogin2/provider/internet_provider.dart';
import 'package:multilogin2/provider/issue_service_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:multilogin2/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'provider/sign_in_provider.dart';
import 'package:multilogin2/provider/analytics_service.dart';

/// The entry point of the application.
///
/// This function ensures that Firebase is initialized before the application runs.
/// It also sets up error handling for Flutter and the platform dispatcher.
/// Finally, it runs the `MyApp` widget, which is the root of your widget tree.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(MyApp());
}

/// Eliminates local instances.
///
/// This function removes 'local_issues' from shared preferences.
Future<void> eliminateLocalInstances() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('local_issues');
}

/// The root widget of the application.
///
/// This widget is a `MultiProvider` that provides `SignInProvider` and `InternetProvider` to the rest of the widget tree.
/// It also sets up the `AnalyticsService` for Firebase Analytics.
/// The home of the `MaterialApp` is a `WillPopScope` widget that handles the Android back button.
class MyApp extends StatelessWidget {
  MyApp({super.key});
  final AnalyticsService _analyticsService = AnalyticsService();

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
      child: MaterialApp(
        title: 'Loba Issues',
        navigatorObservers: [_analyticsService.getAnalyticsObserver()],
        home: WillPopScope(
          onWillPop: () async {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
              return false;
            } else {
              return true;
            }
          },
          child: const SplashScreen(),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

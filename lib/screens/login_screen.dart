import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multilogin2/provider/internet_provider.dart';
import 'package:multilogin2/screens/home_screen.dart';
import 'package:multilogin2/screens/phoneauth_screen.dart';
import 'package:multilogin2/utils/next_screen.dart';
import 'package:multilogin2/utils/snack_bar.dart';
import 'package:provider/provider.dart';
//import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:multilogin2/utils/config.dart';

import '../provider/sign_in_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen ({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();
  final RoundedLoadingButtonController googleController = RoundedLoadingButtonController();
  final RoundedLoadingButtonController facebookController = RoundedLoadingButtonController();
  final RoundedLoadingButtonController phoneController = RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding:
          const EdgeInsets.only(left: 40, right: 40, top: 90, bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image(
                      image: AssetImage(Config.app_icon),
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                        "Welcome to FlutterFirebase",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 20),
                    Text("Learn Authentication with Provider",
                        style: TextStyle(fontSize: 15, color: Colors.grey[600]))
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RoundedLoadingButton(
                      controller: googleController,
                      successColor: Colors.red,
                      onPressed: () {
                        handleGoogleSignIn();
                      },
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.80,
                      elevation: 0,
                      borderRadius: 25,
                      color: Colors.red,
                      child: Wrap(
                        children: const [
                          Icon(
                            FontAwesomeIcons.google,
                            size: 20,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text("Sign in with Google",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500)
                          ),
                        ],
                      )
                  ),
                  SizedBox(
                    height: 10, // for padding
                  ),
                  RoundedLoadingButton(
                      controller: facebookController,
                      successColor: Colors.blue,
                      onPressed: () {
                        handleFacebookAuth();
                      },
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.80,
                      elevation: 0,
                      borderRadius: 25,
                      color: Colors.blue,
                      child: Wrap(
                        children: const [
                          Icon(
                            FontAwesomeIcons.facebook,
                            size: 20,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text("Sign in with Facebook",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500)
                          ),
                        ],
                      )
                  ),
                  SizedBox(
                    height: 10, // for padding
                  ),
                  RoundedLoadingButton(
                      controller: phoneController,
                      successColor: Colors.blue,
                      onPressed: () {
                        nextScreenReplace(context, const PhoneAuthScreen());
                        phoneController.reset();
                      },
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.80,
                      elevation: 0,
                      borderRadius: 25,
                      color: Colors.black,
                      child: Wrap(
                        children: const [
                          Icon(
                            FontAwesomeIcons.phone,
                            size: 20,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text("Continue with Phone",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500)
                          ),
                        ],
                      )
                  ),
                  SizedBox(
                    height: 30, // for padding
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future handleGoogleSignIn() async {
    final signInProvider = context.read<SignInProvider>();
    final internetProvider = context.read<InternetProvider>();
    await internetProvider.checkInternetConnection();

    if (internetProvider.hasInternet == false) {
      openSnackbar(context, "Check your Internet connection", Colors.red);
      googleController.reset();
    } else {
      await signInProvider.signInWithGoogle().then((value) {
        if (signInProvider.hasError == true) {
          openSnackbar(
              context, signInProvider.errorCode.toString(), Colors.red);
          googleController.reset();
        } else {
          // checking whether user exists or not
          signInProvider.checkUserExists().then((value) async {
            if (value == true) {
              // user exists
              await signInProvider.getUserDataFromFirestore(signInProvider.uid)
                  .then((value) =>
                  signInProvider
                      .saveDataToSharedPreferences()
                      .then((value) =>
                      signInProvider.setSignIn().then((value) {
                        googleController.success();
                        handleAfterSignIn();
                      })));
            } else {
              // user does not exist
              signInProvider.saveDataToFirestore().then((value) =>
                  signInProvider
                      .saveDataToSharedPreferences()
                      .then((value) =>
                      signInProvider.setSignIn().then((value) {
                        googleController.success();
                        handleAfterSignIn();
                      })));
            }
          });
        }
      });
    }
  }

  Future handleFacebookAuth() async {
    final signInProvider = context.read<SignInProvider>();
    final internetProvider = context.read<InternetProvider>();
    await internetProvider.checkInternetConnection();

    if (internetProvider.hasInternet == false) {
      openSnackbar(context, "Check your Internet connection", Colors.red);
      facebookController.reset();
    } else {
      await signInProvider.signInWithFacebook().then((value) {
        if (signInProvider.hasError == true) {
          openSnackbar(context, signInProvider.errorCode.toString(), Colors.red);
          facebookController.reset();
        } else {
          // checking whether user exists or not
          signInProvider.checkUserExists().then((value) async {
            if (value == true) {
              // user exists
              await signInProvider.getUserDataFromFirestore(signInProvider.uid).then((value) => signInProvider
                  .saveDataToSharedPreferences()
                  .then((value) => signInProvider.setSignIn().then((value) {
                facebookController.success();
                handleAfterSignIn();
              })));
            } else {
              // user does not exist
              signInProvider.saveDataToFirestore().then((value) => signInProvider
                  .saveDataToSharedPreferences()
                  .then((value) => signInProvider.setSignIn().then((value) {
                facebookController.success();
                handleAfterSignIn();
              })));
            }
          });
        }
      });
    }
  }

  // handle after signin
  handleAfterSignIn() {
    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      nextScreenReplace(context, const HomeScreen());
    });

  }
}
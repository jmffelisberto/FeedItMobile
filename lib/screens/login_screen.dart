import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multilogin2/provider/internet_provider.dart';
import 'package:multilogin2/screens/home_screen.dart';
import 'package:multilogin2/screens/phoneauth_screen.dart';
import 'package:multilogin2/utils/next_screen.dart';
import 'package:multilogin2/utils/snack_bar.dart';
import 'package:provider/provider.dart';
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment(0.0, 0.40),
            colors: [Colors.black, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 80),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image(
                      image: AssetImage(Config.loba_icon_white),
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 20),
                    const Text("Welcome to Trial",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 5),
                    Text("Testing login & local to cloud storage",
                        style: TextStyle(
                            fontSize: 10, color: Colors.black)),
                  ],
                ),
                SizedBox(height: 50),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: 'Write Your Email',
                              hintStyle: TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: Colors.grey[200],
                              contentPadding: EdgeInsets.all(15),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.transparent),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.transparent),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: Colors.grey[200],
                              contentPadding: EdgeInsets.all(15),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.transparent),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.transparent),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  // Do something
                                },
                                icon: Icon(
                                  Icons.arrow_forward_outlined,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            obscureText: true,
                          ),
                          SizedBox(height: 20),
                          Text("Forgot your password?",
                              style: TextStyle(
                                  fontSize: 10, color: Colors.grey)),
                          SizedBox(height: 20),
                          RoundedLoadingButton(
                            controller: googleController,
                            successColor: Colors.red,
                            onPressed: () {
                              handleGoogleSignIn();
                            },
                            width: MediaQuery.of(context).size.width * 0.80,
                            borderRadius: 10,
                            color: Colors.red,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  FontAwesomeIcons.google,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Sign in with Google",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          RoundedLoadingButton(
                            controller: facebookController,
                            successColor: Colors.blue,
                            onPressed: () {
                              handleFacebookAuth();
                            },
                            width: MediaQuery.of(context).size.width * 0.80,
                            borderRadius: 10,
                            color: Colors.blue,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  FontAwesomeIcons.facebook,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Sign in with Facebook",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          RoundedLoadingButton(
                            controller: phoneController,
                            successColor: Colors.lightGreen,
                            onPressed: () {
                              nextScreenReplace(context, const PhoneAuthScreen());
                              phoneController.reset();
                            },
                            width: MediaQuery.of(context).size.width * 0.80,
                            borderRadius: 10,
                            color: Colors.lightGreen,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  FontAwesomeIcons.phone,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Continue with Phone",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
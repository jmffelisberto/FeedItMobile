import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multilogin2/provider/internet_provider.dart';
import 'package:multilogin2/screens/create_account_screen.dart';
import 'package:multilogin2/screens/forgot_password_screen.dart';
import 'package:multilogin2/screens/home_screen.dart';
import 'package:multilogin2/screens/phoneauth_screen.dart';
import 'package:multilogin2/screens/phonelogin_screen.dart';
import 'package:multilogin2/utils/next_screen.dart';
import 'package:multilogin2/utils/snack_bar.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:multilogin2/utils/config.dart';

import '../provider/analytics_service.dart';
import '../provider/sign_in_provider.dart';

/// `LoginScreen` is a class that displays the login form.
///
/// It uses `FirebaseAuth`, `SignInProvider`, and `InternetProvider` to handle user authentication.
/// It also provides several methods to handle user interactions, form submissions, and navigation between screens.
///
/// Methods:
/// - `initState()`: Initializes the state of the widget.
/// - `handleGoogleSignIn()`: Handles user authentication with Google.
/// - `handleFacebookAuth()`: Handles user authentication with Facebook.
/// - `handleEmailSignIn()`: Handles user authentication with email and password.
/// - `_showPhoneAuthOptionsModal(BuildContext context)`: Shows a modal with options for phone authentication.
/// - `handleAfterSignIn()`: Handles navigation after successful sign-in.
/// - `build(BuildContext context)`: Builds the widget tree for this screen.

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();
  final RoundedLoadingButtonController googleController = RoundedLoadingButtonController();
  final RoundedLoadingButtonController facebookController = RoundedLoadingButtonController();
  final RoundedLoadingButtonController phoneController = RoundedLoadingButtonController();
  final RoundedLoadingButtonController emailButtonController = RoundedLoadingButtonController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  /// Initializes the state of the widget.
  @override
  Widget build(BuildContext context) {
    SignInProvider sp = context.watch<SignInProvider>();
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
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
                          Text("Welcome to Trial",
                              style: GoogleFonts.exo2(
                                fontSize: 24,
                              fontWeight: FontWeight.bold
                              ),),
                          const SizedBox(height: 5),
                          Text("Testing login & local to cloud storage",
                            style: GoogleFonts.exo2(
                                fontSize: 10,
                            ),),
                        ],
                      ),
                      SizedBox(height: 50),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30), //changed to 30, was 60
                              topRight: Radius.circular(30),
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
                                      onPressed: () async {
                                        try {
                                          await sp.handleEmailSignIn(
                                            _emailController.text.trim(),
                                            _passwordController.text.trim(),
                                          );
                                          Future.delayed(const Duration(milliseconds: 1000)).then((value) {
                                            nextScreenReplace(context, const HomeScreen());
                                          });
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(e.toString()),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
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
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                                    );
                                  },
                                  child: Text(
                                    "Forgot your password?",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                RoundedLoadingButton(
                                  controller: emailButtonController,
                                  successColor: Colors.lightGreen,
                                  onPressed: () {
                                    nextScreenReplace(
                                        context, const CreateAccountScreen());
                                  },
                                  width: MediaQuery.of(context).size.width * 0.80,
                                  borderRadius: 10,
                                  color: Colors.black, // Set the button color to black
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.account_circle_sharp, // Use the email icon
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "Sign In",
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
                                    _showPhoneAuthOptionsModal(context);
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
          ),
        ),
    );
  }

  /// Handles user authentication with Google.
  /// It uses `SignInProvider` and `InternetProvider` to check the internet connection and sign in with Google.
  /// It also checks whether the user exists or not and saves the user data to Firestore and SharedPreferences.
  /// It then navigates to the `HomeScreen` after successful sign-in.
  /// If there is no internet connection, it displays a snackbar with an error message.
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
              await signInProvider
                  .getUserDataFromFirestore(signInProvider.uid!)
                  .then((value) => signInProvider
                  .saveDataToSharedPreferences()
                  .then((value) => signInProvider.setSignIn().then((value) {
                googleController.success();
                handleAfterSignIn();
              })));
            } else {
              // user does not exist
              signInProvider.saveDataToFirestore().then((value) =>
                  signInProvider
                      .saveDataToSharedPreferences()
                      .then((value) => signInProvider.setSignIn().then((value) {
                    googleController.success();
                    handleAfterSignIn();
                  })));
            }
          });
        }
      });
    }
  }

  /// Handles user authentication with Facebook.
  /// It uses `SignInProvider` and `InternetProvider` to check the internet connection and sign in with Facebook.
  /// It also checks whether the user exists or not and saves the user data to Firestore and SharedPreferences.
  /// It then navigates to the `HomeScreen` after successful sign-in.
  /// If there is no internet connection, it displays a snackbar with an error message.
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
          openSnackbar(
              context, signInProvider.errorCode.toString(), Colors.red);
          facebookController.reset();
        } else {
          // checking whether user exists or not
          signInProvider.checkUserExists().then((value) async {
            if (value == true) {
              // user exists
              await signInProvider
                  .getUserDataFromFirestore(signInProvider.uid!)
                  .then((value) => signInProvider
                  .saveDataToSharedPreferences()
                  .then((value) => signInProvider.setSignIn().then((value) {
                facebookController.success();
                handleAfterSignIn();
              })));
            } else {
              // user does not exist
              signInProvider.saveDataToFirestore().then((value) =>
                  signInProvider
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

  /// Handles user authentication with email and password.
  /// It uses `FirebaseAuth` to sign in with email and password.
  /// It then navigates to the `HomeScreen` after successful sign-in.
  /// If there is no user found for the email or the password is wrong, it displays a snackbar with an error message.
  /// If the sign-in is successful, it returns the user data.
  /// If the sign-in is unsuccessful, it returns null.
  Future<User?> handleEmailSignIn() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim()
      );
      return credential.user;

    } catch (e) {
      if (e.toString() == 'user-not-found') {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
                'No user found for that email.'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (e.toString() == 'wrong-password') {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
                'Wrong password provided for that user.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  /// Shows a modal with options for phone authentication.
  /// It uses `PhoneRegisterScreen` and `PhoneLoginScreen` to navigate to the respective screens.
  /// It also resets the `phoneController` to close the modal.
  void _showPhoneAuthOptionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Phone Account Option",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  nextScreenReplace(
                      context, const PhoneRegisterScreen());
                  phoneController.reset(); // Close the modal
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.app_registration, size: 20, color: Colors.white),
                    SizedBox(width: 10),
                    Text("Register", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  nextScreenReplace(
                      context, PhoneLoginScreen());
                  phoneController.reset(); // Close the modal
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.login, size: 20, color: Colors.white),
                    SizedBox(width: 10),
                    Text("Login", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  /// Handles navigation after successful sign-in.
  handleAfterSignIn() {
    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      nextScreenReplace(context, const HomeScreen());
    });
  }
}

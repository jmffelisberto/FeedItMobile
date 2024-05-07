import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multilogin2/provider/internet_provider.dart';
import 'package:multilogin2/provider/sign_in_provider.dart';
import 'package:multilogin2/screens/home_screen.dart';
import 'package:multilogin2/utils/snack_bar.dart';
import 'package:provider/provider.dart';
import '../utils/config.dart';
import '../utils/next_screen.dart';
import 'login_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({Key? key}) : super(key: key);

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final formKey = GlobalKey<FormState>();
  // controller -> phone, email, name, otp code
  TextEditingController phoneController = TextEditingController();
  //TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController otpCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () {
              // Navigate back to the previous screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image(
                      image: AssetImage(Config.app_icon), height: 50, width: 50),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Phone Login",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Name cannot be empty";
                      }
                      return null;
                    },
                    controller: nameController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.account_circle),
                        hintText: "John Doe",
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.red)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey))),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  /*TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Email address cannot be empty";
                    }
                    return null;
                  },
                  controller: emailController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email),
                      hintText: "something@mail.com",
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey))),
                ),
                const SizedBox(
                    height: 10,
                  ),*/
                  TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Phone Number cannot be empty";
                      }
                      return null;
                    },
                    controller: phoneController,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.phone),
                        hintText: "+1 123456789",
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.red)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey))),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      login(context, phoneController.text.trim());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text("Register"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Future login(BuildContext context, String mobile) async {
    final signInProvider = context.read<SignInProvider>();
    final internetProvider = context.read<InternetProvider>();
    await internetProvider.checkInternetConnection();

    if (internetProvider.hasInternet == false) {
      openSnackbar(context, "Check your internet connection", Colors.red);
    } else {
      if (formKey.currentState!.validate()) {
        FirebaseAuth.instance.verifyPhoneNumber(
            phoneNumber: mobile,
            verificationCompleted: (AuthCredential credential) async {
              await FirebaseAuth.instance.signInWithCredential(credential);
            },
            verificationFailed: (FirebaseAuthException e) {
              openSnackbar(context, e.toString(), Colors.red);
            },
            codeSent: (String verificationId, int? forceResendingToken) {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Enter Code"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: otpCodeController,
                            decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.code),
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                    const BorderSide(color: Colors.red)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                    const BorderSide(color: Colors.grey)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                    const BorderSide(color: Colors.grey))),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final code = otpCodeController.text.trim();
                              AuthCredential authCredential =
                              PhoneAuthProvider.credential(
                                  verificationId: verificationId,
                                  smsCode: code);
                              User user = (await FirebaseAuth.instance
                                  .signInWithCredential(authCredential))
                                  .user!;
                              // save the values
                              signInProvider.phoneNumberUser(user,
                                  nameController.text);
                              // checking whether user exists,
                              signInProvider.checkUserExists().then((value) async {
                                if (value == true) {
                                  // user exists
                                  await signInProvider
                                      .getUserDataFromFirestore(signInProvider.uid)
                                      .then((value) => signInProvider
                                      .saveDataToSharedPreferences()
                                      .then((value) =>
                                      signInProvider.setSignIn().then((value) {
                                        nextScreenReplace(context,
                                            const HomeScreen());
                                      })));
                                } else {
                                  // user does not exist
                                  await signInProvider.saveDataToFirestore().then((value) =>
                                      signInProvider.saveDataToSharedPreferences().then(
                                              (value) =>
                                              signInProvider.setSignIn().then((value) {
                                                nextScreenReplace(context,
                                                    const HomeScreen());
                                              })));
                                }
                              });
                            },
                            child: const Text("Confirm"),
                          )
                        ],
                      ),
                    );
                  });
            },
            codeAutoRetrievalTimeout: (String verification) {});
      }
    }
  }
}
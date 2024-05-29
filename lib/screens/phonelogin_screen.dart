import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../provider/sign_in_provider.dart';
import '../utils/next_screen.dart';
import 'home_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  @override
  _PhoneLoginScreenState createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController otpCodeController = TextEditingController();
  final RoundedLoadingButtonController sendCodeController = RoundedLoadingButtonController();
  final RoundedLoadingButtonController verifyCodeController = RoundedLoadingButtonController();
  String verificationId = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Login with Phone",
          style: GoogleFonts.exo2(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phone Number:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                hintText: 'Enter your phone number',
              ),
            ),
            SizedBox(height: 16),
            RoundedLoadingButton(
              onPressed: () => _sendCode(context),
              controller: sendCodeController,
              color: Colors.blue,
              successColor: Colors.green,
              errorColor: Colors.red,
              child: Text('Send Code', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 32),
            Text(
              'OTP Code:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: otpCodeController,
              decoration: InputDecoration(
                hintText: 'Enter the OTP code',
              ),
            ),
            SizedBox(height: 16),
            RoundedLoadingButton(
              onPressed: () => _verifyCode(context),
              controller: verifyCodeController,
              color: Colors.blue,
              successColor: Colors.green,
              errorColor: Colors.red,
              child: Text('Verify Code', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }


  void _sendCode(BuildContext context) async {
    String phone = phoneController.text.trim();
    sendCodeController.start();
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          _fetchUserData(context);
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message!)));
          sendCodeController.error();
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            this.verificationId = verificationId;
          });
          sendCodeController.success();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            this.verificationId = verificationId;
          });
          sendCodeController.success();
        },
      );
    } catch (e) {
      print('Error sending code: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sending code: $e')));
      sendCodeController.error();
    }
  }

  void _verifyCode(BuildContext context) async {
    String code = otpCodeController.text.trim();
    verifyCodeController.start();
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      );
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      _fetchUserData(context);
      verifyCodeController.success();
    } catch (e) {
      print('Error verifying code: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error verifying code: $e')));
      verifyCodeController.error();
    }
  }

  void _fetchUserData(BuildContext context) async {
    try {
      final signInProvider = context.read<SignInProvider>();
      await signInProvider.fetchUserDataByPhone(context);
    } catch (e) {
      print('Error fetching user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching user data: $e')));
    }
  }
}

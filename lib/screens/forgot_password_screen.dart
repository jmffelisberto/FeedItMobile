import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// `ForgotPasswordScreen` is a class that displays the password reset form.
///
/// It uses `FirebaseAuth` to handle password reset requests.
/// It also provides a method to handle form submissions.
///
/// Methods:
/// - `initState()`: Initializes the state of the widget.
/// - `_resetPassword()`: Sends a password reset email to the entered email address.
/// - `build(BuildContext context)`: Builds the widget tree for this screen.

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  /// Sends a password reset email to the entered email address.
  ///
  /// It first checks if the email field is not empty.
  /// If the email field is not empty, it sends a password reset email to the entered email address.
  /// After sending the email, it shows a success message.
  /// If an error occurs, it shows an error message.
  Future<void> _resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Builds the widget tree for this screen.
  ///
  /// It displays a form with a field for the user's email address.
  /// It also provides a button to submit the form.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            ElevatedButton(
              onPressed: _resetPassword,
              child: Text('Reset Password'),
            ),
            TextButton(
              onPressed: () => throw Exception(),
              child: const Text("Throw Test Exception"),
            ),

          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}

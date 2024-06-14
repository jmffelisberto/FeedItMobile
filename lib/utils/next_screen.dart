import 'package:flutter/material.dart';

/// Navigates to the next screen by pushing it onto the navigation stack.
///
/// The `context` parameter is the build context from which the navigation originates.
/// The `page` parameter is the widget that defines the next screen.
void nextScreen(BuildContext context, Widget page) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

/// Navigates to the next screen by replacing the current screen on the navigation stack.
///
/// The `context` parameter is the build context from which the navigation originates.
/// The `page` parameter is the widget that defines the next screen.
void nextScreenReplace(BuildContext context, Widget page) {
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => page));
}
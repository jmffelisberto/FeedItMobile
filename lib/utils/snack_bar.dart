import 'package:flutter/material.dart';

/// Opens a Snackbar with the specified message and color.
///
/// The `context` parameter is the build context from which the Snackbar originates.
/// The `snackMessage` parameter is the message to be displayed in the Snackbar.
/// The `color` parameter is the background color of the Snackbar.
void openSnackbar(BuildContext context, String snackMessage, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: color,
      action: SnackBarAction(
        label: "OK",
        textColor: Colors.white,
        onPressed: () {},
      ),
      content: Text(
        snackMessage,
        style: const TextStyle(fontSize: 14),
      )));
}
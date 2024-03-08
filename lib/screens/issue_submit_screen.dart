import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multilogin2/screens/home_screen.dart';
import 'package:multilogin2/utils/issue.dart';
import 'package:multilogin2/utils/next_screen.dart';

class SubmitIssueScreen extends StatefulWidget {
  @override
  _SubmitIssueScreenState createState() => _SubmitIssueScreenState();
}

class _SubmitIssueScreenState extends State<SubmitIssueScreen> {
  late TextEditingController _subjectController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitIssue() {
    String subject = _subjectController.text.trim();
    String description = _descriptionController.text.trim();

    if (subject.isNotEmpty && description.isNotEmpty) {
      Issue issue = Issue(subject: subject, description: description);
      submitIssue(issue);
      // Clear the text fields after submitting
      _subjectController.clear();
      _descriptionController.clear();
      // Optionally, you can show a confirmation dialog or navigate to another screen
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Issue Submitted'),
          content: Text('Your issue has been submitted successfully!'),
          actions: [
            TextButton(
              onPressed: () => nextScreenReplace(context, const HomeScreen()),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // Show an error message if any of the fields are empty
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Please fill in all fields.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Issue'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _subjectController,
              decoration: InputDecoration(labelText: 'Subject'),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitIssue,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

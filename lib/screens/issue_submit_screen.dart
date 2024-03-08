import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:multilogin2/screens/home_screen.dart';
import 'package:multilogin2/utils/issue.dart';
import 'package:multilogin2/utils/next_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  void _submitIssue() async {
    String subject = _subjectController.text.trim();
    String description = _descriptionController.text.trim();

    if (subject.isNotEmpty && description.isNotEmpty) {
      Issue issue = Issue(subject: subject, description: description);
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // Device is offline, store data locally
        await _storeLocally(issue);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('No connection available!'),
            content: Text('Your issue has been stored locally, and will be submitted as soon as you get a connection.'),
            actions: [
              TextButton(
                onPressed: () => nextScreenReplace(context, const HomeScreen()),
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Device is online, submit data to Firestore
        await submitIssueToFirestore(issue);
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Could not submit issue!'),
          content: Text('An unexpected error occurred. Please try again later!'),
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


  Future<void> _storeLocally(Issue issue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Store the issue locally using shared_preferences or SQLite
    // Example using shared_preferences
    List<String> localIssues = prefs.getStringList('local_issues') ?? [];
    localIssues.add(issue.toMap().toString());
    await prefs.setStringList('local_issues', localIssues);
  }

  Future<void> submitIssueToFirestore(Issue issue) async {
    try {
      await FirebaseFirestore.instance.collection('issues').add(issue.toMap());
      print('Issue submitted successfully');
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
    } catch (e) {
      print('Error submitting issue: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Could not submit issue!'),
          content: Text('An unexpected error occured. Sorry, again later!'),
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

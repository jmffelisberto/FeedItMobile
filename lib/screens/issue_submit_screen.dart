import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multilogin2/screens/home_screen.dart';
import 'package:multilogin2/screens/your_issues_screen.dart';
import 'package:multilogin2/utils/issue.dart';
import 'package:multilogin2/utils/next_screen.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubmitIssueScreen extends StatefulWidget {
  @override
  _SubmitIssueScreenState createState() => _SubmitIssueScreenState();
}

class _SubmitIssueScreenState extends State<SubmitIssueScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _tagController;
  late String _selectedTag;
  final List<String> _tagOptions = ['Work', 'Leisure', 'Other'];
  final RoundedLoadingButtonController submitController =
  RoundedLoadingButtonController();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _tagController = TextEditingController();
    _selectedTag = _tagOptions.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _submitIssue() async {
    String title = _titleController.text.trim();
    String description = _descriptionController.text.trim();
    String tag = _selectedTag.trim();

    if (title.isNotEmpty && description.isNotEmpty && tag.isNotEmpty) {
      // Fetch the current user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Fetch author details from Firestore using the UID

        Issue issue = Issue(
          title: title,
          description: description,
          createdAt: Timestamp.now(),
          tag: tag,
          authorName: user.displayName,
          authorProfilePicture: user.photoURL,
          uid: user.uid,
        );

        var connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          // Device is offline, store data locally
          await _storeLocally(issue);
          await Future.delayed(Duration(milliseconds: 500));
          submitController.success();
          nextScreenReplace(context, LocalIssuesScreen(initialTabIndex: 0));
        } else {
          // Device is online, submit data to Firestore
          submitController.success();
          await submitIssueToFirestore(issue);
        }
      } else {
        print('User not logged in');
        await Future.delayed(Duration(milliseconds: 500));
        submitController.error();
      }
    } else {
      await Future.delayed(Duration(milliseconds: 500));
      submitController.error();
    }
  }


  Future<void> submitIssueToFirestore(Issue issue) async {
    try {
      await FirebaseFirestore.instance.collection('issues').add(issue.toJson());
      print('Issue submitted successfully');
      await Future.delayed(Duration(milliseconds: 500));
      nextScreenReplace(context, LocalIssuesScreen(initialTabIndex: 1));
    } catch (e) {
      print('Error submitting issue: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Could not submit issue!'),
          content: Text('An unexpected error occured. Please try again later!'),
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
    // Serialize the issue object into a JSON string
    Map<String, dynamic> jsonIssue = issue.toJson();
    if (issue.createdAt != null) {
      jsonIssue['createdAt'] = issue.createdAt!.millisecondsSinceEpoch;
    }
    // Store the JSON string in shared preferences
    List<String> localIssues = prefs.getStringList('local_issues') ?? [];
    localIssues.add(jsonEncode(jsonIssue));
    await prefs.setStringList('local_issues', localIssues);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Submit Issue",
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Subject'),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 5,
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedTag,
                onChanged: (value) {
                  setState(() {
                    _selectedTag = value!;
                  });
                },
                items: _tagOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Tag'),
              ),
              SizedBox(height: 20),
              RoundedLoadingButton(
                controller: submitController,
                successColor: Colors.green,
                errorColor: Colors.red,
                onPressed: () async {
                  submitController.start();
                  await Future.delayed(Duration(milliseconds: 500));
                  _submitIssue();
                },
                width: MediaQuery.of(context).size.width * 0.30,
                elevation: 0,
                borderRadius: 25,
                color: Colors.grey,
                child: Wrap(
                  children: const [
                    Icon(
                      FontAwesomeIcons.boxOpen,
                      size: 20,
                      color: Colors.black,
                    ),
                    SizedBox(width: 15),
                    Text(
                      "Submit",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

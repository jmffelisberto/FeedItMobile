import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multilogin2/screens/home_screen.dart';
import 'package:multilogin2/screens/your_issues_screen.dart';
import 'package:multilogin2/utils/issue.dart';
import 'package:multilogin2/utils/next_screen.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SubmitIssueScreen extends StatefulWidget {
  @override
  _SubmitIssueScreenState createState() => _SubmitIssueScreenState();
}

class _SubmitIssueScreenState extends State<SubmitIssueScreen> {
  late TextEditingController _subjectController;
  late TextEditingController _descriptionController;
  final RoundedLoadingButtonController submitController = RoundedLoadingButtonController();


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
      Issue issue = Issue(subject: subject, description: description, createdAt: Timestamp.now(), uid: FirebaseAuth.instance.currentUser!.uid);
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

  Future<void> _storeLocally(Issue issue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Serialize the issue object into a JSON string
    Map<String, dynamic> jsonIssue = issue.toJson(); // Convert to JSON map
    if (issue.createdAt != null) {
      // Only store createdAt if it's not null
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
        // Handle the back button press here
        // Navigate back to the previous page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        return false; // Prevent the default back button behavior
      },
      child:  Scaffold(
        appBar: AppBar(
          title: Text(
            "Submit Issue",
            style: GoogleFonts.exo2(),
          ),
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
                      SizedBox(
                        width: 15,
                      ),
                      Text("Submit",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w500)
                      ),
                    ],
                  )
              ),

            ],
          ),
        ),
      )
    );
  }
}

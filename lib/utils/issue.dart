import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Issue {
  final String subject;
  final String description;

  Issue({required this.subject, required this.description});

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'description': description,
    };
  }

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      subject: json['subject'],
      description: json['description'],
    );
  }

  static Future<void> submitLocalIssues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? localIssuesJson = prefs.getStringList('local_issues');
    if (localIssuesJson != null) {
      List<Issue> localIssues = localIssuesJson
          .map((json) => Issue.fromJson(jsonDecode(json)))
          .toList();
      for (Issue issue in localIssues) {
        await submitIssueToFirebase(issue);
      }
      await prefs.remove('local_issues');
    }
  }

  static Future<void> submitIssueToFirebase(Issue issue) async {
    try {
      await FirebaseFirestore.instance.collection('issues').add(issue.toJson());
      print('Issue submitted successfully');
    } catch (e) {
      print('Error submitting issue: $e');
    }
  }

  static Future<bool> hasInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  static void checkInternetConnectivityPeriodically() {
    const duration = Duration(seconds: 3); // Adjust the duration as needed
    Timer.periodic(duration, (Timer timer) async {
      var isConnected = await hasInternetConnection();
      if (isConnected) {
        await submitLocalIssues();
        timer.cancel();
      }
    });
  }
}

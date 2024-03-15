import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multilogin2/screens/home_screen.dart';
import 'package:multilogin2/utils/issue.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalIssuesScreen extends StatefulWidget {
  @override
  _LocalIssuesScreenState createState() => _LocalIssuesScreenState();
}

class _LocalIssuesScreenState extends State<LocalIssuesScreen> {
  List<Issue> _localIssues = [];
  List<Issue> _cloudIssues = []; // Placeholder for cloud issues

  @override
  void initState() {
    super.initState();
    _loadLocalIssues();
    // Fetch cloud issues
    _fetchCloudIssues(); // You need to implement this method
  }

  Future<void> _loadLocalIssues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? localIssuesJson = prefs.getStringList('local_issues');
    if (localIssuesJson != null) {
      print('Local issues JSON: $localIssuesJson');
      setState(() {
        _localIssues = localIssuesJson.map((json) {
          Map<String, dynamic> parsedJson = jsonDecode(json);
          return Issue.fromJson(parsedJson);
        }).toList();
      });
    }
  }

  // Placeholder for fetching cloud issues
  Future<void> _fetchCloudIssues() async {
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('issues').get();

      List<Issue> cloudIssues = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Issue.fromJson(data);
      }).toList();
      setState(() {
        _cloudIssues = cloudIssues;
      });

      print('Cloud issues fetched successfully');
    } catch (e) {
      print('Error fetching cloud issues: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text('Issues'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
          ),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Local Issues'),
              Tab(text: 'Cloud Issues'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Local Issues Tab
            _localIssues.isEmpty
                ? Center(
              child: Text('No local issues found'),
            )
                : ListView.builder(
              itemCount: _localIssues.length,
              itemBuilder: (context, index) {
                final issue = _localIssues[index];
                return ListTile(
                  title: Text(issue.subject),
                  subtitle: Text(issue.description),
                );
              },
            ),
            // Cloud Issues Tab
            _cloudIssues.isEmpty
                ? Center(
              child: Text('No cloud issues found'),
            )
                : ListView.builder(
              itemCount: _cloudIssues.length,
              itemBuilder: (context, index) {
                final issue = _cloudIssues[index];
                return ListTile(
                  title: Text(issue.subject),
                  subtitle: Text(issue.description),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
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

  @override
  void initState() {
    super.initState();
    _loadLocalIssues();
  }

  Future<void> _loadLocalIssues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? localIssuesJson = prefs.getStringList('local_issues');
    if (localIssuesJson != null) {
      print('Local issues JSON: $localIssuesJson');
      setState(() {
        _localIssues = localIssuesJson.map((json) {
          // Parse JSON string into a Map<String, dynamic>
          Map<String, dynamic> parsedJson = jsonDecode(json);
          // Create an Issue object from the parsed JSON
          return Issue.fromJson(parsedJson);
        }).toList();
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Local Issues'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to the home screen and replace the current screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
      ),

      body: _localIssues.isEmpty
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
    );
  }
}

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multilogin2/main.dart';
import 'package:multilogin2/provider/issue_service_provider.dart';
import 'package:multilogin2/screens/home_screen.dart';
import 'package:multilogin2/utils/issue.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalIssuesScreen extends StatefulWidget {
  final int initialTabIndex;

  LocalIssuesScreen({Key? key, this.initialTabIndex = 0}) : super(key: key);

  @override
  _LocalIssuesScreenState createState() => _LocalIssuesScreenState();
}

class _LocalIssuesScreenState extends State<LocalIssuesScreen> {
  List<Issue> _localIssues = [];
  List<Issue> _cloudIssues = [];
  late ConnectivityService _connectivityService;

  @override
  void initState() {
    super.initState();
    _loadLocalIssues();
    _loadCloudIssues();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _selectTab(widget.initialTabIndex);
    });
    _connectivityService = ConnectivityService(fetchCloudIssues: _fetchCloudIssues);
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }

  void _selectTab(int index) {
    DefaultTabController.of(context)?.animateTo(index);
  }

  Future<void> _loadLocalIssues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? localIssuesJson = prefs.getStringList('local_issues');
    if (localIssuesJson != null) {
      setState(() {
        _localIssues = localIssuesJson.map((json) => Issue.fromJson(jsonDecode(json))).toList();
      });
    }
    else _localIssues = [];
  }

  void _fetchCloudIssues() async {
    await Issue.submitLocalIssues(); // Submit local issues to the cloud
    await _loadCloudIssues(); // Fetch cloud issues to refresh the UI
    await eliminateLocalInstances(); // Remove local issues from SharedPreferences
    await _loadLocalIssues(); // Reload local issues to reflect changes
  }

  Future<void> _loadCloudIssues() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('issues').orderBy('createdAt', descending: true).get();
      List<Issue> cloudIssues = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Timestamp createdAt = data['createdAt'];
        return Issue(
          subject: data['subject'],
          description: data['description'],
          createdAt: createdAt,
        );
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
      length: 2,
      initialIndex: widget.initialTabIndex,
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
                ? Center(child: Text('No local issues found'))
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
                ? Center(child: Text('No cloud issues found'))
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


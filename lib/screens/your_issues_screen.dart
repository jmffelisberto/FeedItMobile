import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart'; // Import connectivity package
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

class _LocalIssuesScreenState extends State<LocalIssuesScreen> with TickerProviderStateMixin {
  List<Issue> _localIssues = [];
  List<Issue> _cloudIssues = [];
  late ConnectivityService _connectivityService;
  late AnimationController _animationController;
  bool _isSubmittingLocalIssues = false;

  bool _hasConnection = false; // Default to true assuming initial connection

  @override
  void initState() {
    super.initState();
    _loadLocalIssues();
    _loadCloudIssues();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _selectTab(widget.initialTabIndex);
    });

    // Initialize the connectivity service
    _connectivityService = ConnectivityService(onConnectionRestored: () {
      if (_localIssues.isNotEmpty) {
        _fetchCloudIssues();
      }
      setState(() {
        _hasConnection = true;
      });
    });


    // Initialize the animation controller for the rotating icon
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2), // Adjust the duration as needed
    )..repeat(); // Repeat the animation indefinitely
  }


  @override
  void dispose() {
    _connectivityService.dispose();
    _animationController.dispose();
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
    // Set _isSubmittingLocalIssues to true to trigger the rotating icon
    _isSubmittingLocalIssues = true;
    setState(() {});

    // Submit local issues to the cloud
    await Issue.submitLocalIssues();

    // Fetch cloud issues to refresh the UI
    await _loadCloudIssues();

    // Remove local issues from SharedPreferences
    await eliminateLocalInstances();

    // Reload local issues to reflect changes
    await _loadLocalIssues();

    // Check connectivity and update _hasConnection accordingly
    bool hasConnection = await _connectivityService.checkConnectivity();
    setState(() {
      _hasConnection = hasConnection;
    });

    // Set _isSubmittingLocalIssues to false to stop the rotating icon
    _isSubmittingLocalIssues = false;
    setState(() {});
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
      child: DefaultTabController(
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
            actions: [
              // Display no connection icon if there's no connection
              if (!_hasConnection)
                IconButton(
                  icon: Icon(Icons.signal_wifi_off),
                  onPressed: () {},
                ),
              // Display rotating icon if there's connection and local issues are being submitted
              if (_isSubmittingLocalIssues)
                RotationTransition(
                  turns: _animationController,
                  child: Icon(Icons.sync),
                ),
            ],
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
      ),
    );
  }
}

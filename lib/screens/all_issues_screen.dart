import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multilogin2/provider/issue_service_provider.dart';
import 'package:multilogin2/screens/issue_detail_screen.dart';
import 'package:multilogin2/utils/issue.dart';

class AllIssuesPage extends StatefulWidget {
  @override
  _AllIssuesPageState createState() => _AllIssuesPageState();
}

class _AllIssuesPageState extends State<AllIssuesPage> with TickerProviderStateMixin {
  List<Issue> _cloudIssues = [];
  List<Issue> _localIssues = [];
  late ConnectivityService _connectivityService;
  late AnimationController _animationController;
  bool _isSubmittingLocalIssues = false;

  bool _hasConnection = false; // Default to true assuming initial connection

  @override
  void initState() {
    super.initState();
    _loadCloudIssues();

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

  Future<void> _loadCloudIssues() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('issues').orderBy('createdAt', descending: true).get();
      List<Issue> cloudIssues = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('Data from Firestore: $data'); // Print the data retrieved from Firestore
        return Issue(
            title: data['title'] ?? '', // Use default value if 'title' is null
            description: data['description'] ?? '', // Use default value if 'description' is null
            tag: data['tag'] ?? '', // Use default value if 'tag' is null
            createdAt: data['createdAt'],
            uid: data['uid'] ?? ''
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

  void _fetchCloudIssues() async {
    // Set _isSubmittingLocalIssues to true to trigger the rotating icon
    setState(() {});

    // Submit local issues to the cloud
    await Issue.submitLocalIssues();

    // Fetch cloud issues to refresh the UI
    await _loadCloudIssues();

    // Check connectivity and update _hasConnection accordingly
    bool hasConnection = await _connectivityService.checkConnectivity();
    setState(() {
      _hasConnection = hasConnection;
    });

    // Set _isSubmittingLocalIssues to false to stop the rotating icon
    _isSubmittingLocalIssues = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Issues"),
      ),
      body: _cloudIssues.isEmpty
          ? Center(child: Text('No cloud issues found'))
          : ListView.builder(
        itemCount: _cloudIssues.length,
        itemBuilder: (context, index) {
          final issue = _cloudIssues[index];
          return GestureDetector(
            onTap: () {
              // Navigate to the issue detail page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IssueDetailPage(issue: issue),
                ),
              );
            },
            child: Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(issue.title),
                        Row(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: _buildTagContainer(issue.tag),
                            ),
                          ],
                        ),
                        Text(
                          getTimeElapsed(issue.createdAt),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Icon(FontAwesomeIcons.angleRight),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  // Function to build tag container with specific color based on tag
  Widget _buildTagContainer(String tag) {
    Color tagColor = _getTagColor(tag);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tagColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        tag,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  // Function to get tag color based on tag name
  Color _getTagColor(String tag) {
    switch (tag.toLowerCase()) {
      case 'work':
        return Colors.orange;
      case 'leisure':
        return Colors.yellow;
    // Add more cases for other tags and their respective colors
      default:
        return Colors.grey;
    }
  }

  // Function to display time elapsed since issue submission
  String getTimeElapsed(Timestamp? createdAt) {
    if (createdAt == null) return ''; // Handle null createdAt

    final now = DateTime.now();
    final createdAtDateTime = createdAt.toDate();
    final difference = now.difference(createdAtDateTime);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min${difference.inMinutes == 1 ? '' : 's'}. ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    }
  }
}

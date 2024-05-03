import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
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

// Function to fetch the author's profile picture URL
  Future<String?> fetchAuthorProfilePicture(String uid) async {
    try {
      // Access the "users" collection in Firestore and fetch the document with the given UID
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?; // Cast to Map<String, dynamic>
      // Check if the document exists and contains a "name" field
      if (userSnapshot.exists && userSnapshot.data() != null && userData?['image_url'] != null) {
        // Return the author's name if available
        return userData?['image_url'];
      }
      // Return null if the document doesn't exist or doesn't contain a name field
      return null;
    } catch (e) {
      // Handle any errors that occur during the fetch operation
      print('Error fetching author photo: $e');
      return null;
    }
  }

// Function to fetch the author's name
  Future<String?> fetchAuthorName(String uid) async {
    try {
      // Access the "users" collection in Firestore and fetch the document with the given UID
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?; // Cast to Map<String, dynamic>
      // Check if the document exists and contains a "name" field
      if (userSnapshot.exists && userSnapshot.data() != null && userData?['name'] != null) {
        // Return the author's name if available
        return userData?['name'];
      }
      // Return null if the document doesn't exist or doesn't contain a name field
      return null;
    } catch (e) {
      // Handle any errors that occur during the fetch operation
      print('Error fetching author name: $e');
      return null;
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
        title: Text(
          "All Issues",
          style: GoogleFonts.exo2(),
        ),
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
                    Text(
                      issue.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ListTile(
                      leading: FutureBuilder<String?>(
                        future: fetchAuthorProfilePicture(issue.uid),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return CircleAvatar(
                              backgroundImage: NetworkImage(snapshot.data!),
                            );
                          } else {
                            return CircleAvatar(); // Placeholder avatar or loading indicator
                          }
                        },
                      ),
                      title: FutureBuilder<String?>(
                        future: fetchAuthorName(issue.uid),
                        builder: (context, snapshot) {
                          //print(issue.uid);
                          //print(snapshot.data.toString());
                          if (snapshot.hasData) {
                            return Text(snapshot.data!);
                          } else {
                            return Text('Loading...'); // Placeholder text or loading indicator
                          }
                        },
                      ),
                      subtitle: Row(
                        children: [
                          _buildTagContainer(issue.tag),
                          SizedBox(width: 8),
                          Text(
                            getTimeElapsed(issue.createdAt),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      trailing: Icon(FontAwesomeIcons.angleRight),
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

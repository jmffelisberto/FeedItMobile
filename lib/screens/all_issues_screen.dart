import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multilogin2/screens/issue_detail_screen.dart';
import 'package:multilogin2/utils/issue.dart';

import '../provider/issue_service_provider.dart';

class AllIssuesPage extends StatefulWidget {
  @override
  _AllIssuesPageState createState() => _AllIssuesPageState();
}

class _AllIssuesPageState extends State<AllIssuesPage> with TickerProviderStateMixin {
  List<Issue> _cloudIssues = [];
  List<Issue> _localIssues = [];
  List<Issue> _filteredIssues = [];
  List<String> _tags = [];
  String _selectedTag = 'All'; // Default value for filtering
  late ConnectivityService _connectivityService;
  late AnimationController _animationController;
  bool _isSubmittingLocalIssues = false;

  bool _hasConnection = false; // Default to true assuming initial connection

  // Cache for author details
  Map<String, Map<String, String?>> _authorDetailsCache = {};

  @override
  void initState() {
    super.initState();
    _loadCloudIssues();
    _connectivityService = ConnectivityService(onConnectionRestored: () {
      setState(() {
        _hasConnection = true;
      });
    });
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();
  }

  Future<void> _loadCloudIssues() async {
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('issues').orderBy('createdAt', descending: true).get();
      _cloudIssues = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Issue(
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          tag: data['tag'] ?? '',
          createdAt: data['createdAt'],
          image: data['image'] ?? '',
          uid: data['uid'] ?? '',
        );
      }).toList();

      await _cacheAuthorDetails();
      setState(() {
        _filteredIssues = List.from(_cloudIssues); // Initialize filtered issues with all issues
        _extractTags(); // Extract unique tags from issues
      });
      print('Cloud issues fetched successfully');
    } catch (e) {
      print('Error fetching cloud issues: $e');
    }
  }

  Future<void> _cacheAuthorDetails() async {
    for (var issue in _cloudIssues) {
      if (!_authorDetailsCache.containsKey(issue.uid)) {
        String? name = await fetchAuthorName(issue.uid);
        String? imageUrl = await fetchAuthorProfilePicture(issue.uid);
        _authorDetailsCache[issue.uid] = {'name': name, 'image_url': imageUrl};
      }
    }
  }

  void _extractTags() {
    Set<String> uniqueTags = Set.from(_cloudIssues.map((issue) => issue.tag));
    _tags = ['All', ...uniqueTags.toList()]; // Add 'All' option to the beginning
  }

  void _filterIssuesByTag(String tag) {
    setState(() {
      _selectedTag = tag;
      if (tag == 'All') {
        _filteredIssues = List.from(_cloudIssues);
      } else {
        _filteredIssues = _cloudIssues.where((issue) => issue.tag == tag).toList();
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "All Issues",
          style: GoogleFonts.exo2(),
        ),
        actions: [
          DropdownButton<String>(
            value: _selectedTag,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedTag = newValue;
                });
                _filterIssuesByTag(newValue);
              }
            },
            items: _tags.map<DropdownMenuItem<String>>((String tag) {
              return DropdownMenuItem<String>(
                value: tag,
                child: Text(tag),
              );
            }).toList(),
          ),
        ],
      ),
      body: _filteredIssues.isEmpty
          ? Center(child: Text('No issues found'))
          : ListView.builder(
        itemCount: _filteredIssues.length,
        itemBuilder: (context, index) {
          final issue = _filteredIssues[index];
          final authorDetails = _authorDetailsCache[issue.uid];
          final profilePictureUrl = authorDetails?['image_url'] ?? '';
          final authorName = authorDetails?['name'] ?? 'Unknown';

          return GestureDetector(
            onTap: () {
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
                      leading: CircleAvatar(
                        backgroundImage: profilePictureUrl.isNotEmpty
                            ? NetworkImage(profilePictureUrl)
                            : AssetImage('assets/default_profile.png') as ImageProvider,
                      ),
                      title: Text(authorName),
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
      return '${difference.inMinutes} min${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    }
  }
}

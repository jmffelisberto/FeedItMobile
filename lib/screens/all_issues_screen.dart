import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multilogin2/provider/analytics_service.dart';
import 'package:multilogin2/screens/issue_detail_screen.dart';
import 'package:multilogin2/utils/issue.dart';

import '../provider/issue_service_provider.dart';

/// `AllIssuesPage` is a class that displays all the issues fetched from Firestore.
///
/// It uses `ConnectivityService` to check for internet connectivity and `AnalyticsService` to log events.
/// It also provides several methods to fetch and filter issues, fetch author details, and handle user interactions.
///
/// Methods:
/// - `initState()`: Initializes the state of the widget. It loads the cloud issues and starts the connectivity service.
/// - `_loadCloudIssues()`: Fetches the issues from Firestore and stores them in `_cloudIssues`.
/// - `_cacheAuthorDetails()`: Caches the author details for each issue.
/// - `_extractTags()`: Extracts the unique tags from the issues.
/// - `_filterIssuesByTag(String tag)`: Filters the issues by the specified tag.
/// - `fetchAuthorProfilePicture(String uid)`: Fetches the profile picture URL of the author with the specified UID.
/// - `fetchAuthorName(String uid)`: Fetches the name of the author with the specified UID.
/// - `build(BuildContext context)`: Builds the widget tree for this screen.
/// - `_buildTagContainer(String tag)`: Builds a container for the specified tag with a specific color based on the tag.
/// - `_getTagColor(String tag)`: Returns a color based on the specified tag.
/// - `getTimeElapsed(Timestamp? createdAt)`: Returns a string representing the time elapsed since the issue was created.

class AllIssuesPage extends StatefulWidget {
  @override
  _AllIssuesPageState createState() => _AllIssuesPageState();
}

class _AllIssuesPageState extends State<AllIssuesPage> with TickerProviderStateMixin {
  List<Issue> _cloudIssues = [];
  List<Issue> _filteredIssues = [];
  List<String> _tags = [];
  String _selectedTag = 'All'; // Default value for filtering
  late ConnectivityService _connectivityService;
  late AnimationController _animationController;

  bool _hasConnection = false; // Default to true assuming initial connection

  final AnalyticsService _analyticsService = AnalyticsService();

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

  /// Fetches the issues from Firestore and stores them in `_cloudIssues`.
  /// Also caches the author details for each issue and extracts the unique tags from the issues.
  /// Finally, initializes the `_filteredIssues` list with all issues.
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

  /// Caches the author details for each issue.
  /// The author details include the author's name and profile picture URL.
  /// The author details are stored in the `_authorDetailsCache` map with the author's UID as the key.
  Future<void> _cacheAuthorDetails() async {
    for (var issue in _cloudIssues) {
      if (!_authorDetailsCache.containsKey(issue.uid)) {
        String? name = await fetchAuthorName(issue.uid);
        String? imageUrl = await fetchAuthorProfilePicture(issue.uid);
        _authorDetailsCache[issue.uid] = {'name': name, 'image_url': imageUrl};
      }
    }
  }

  /// Extracts the unique tags from the issues and stores them in the `_tags` list.
  /// The `_tags` list is used to populate the dropdown menu for filtering issues by tag.
  void _extractTags() {
    Set<String> uniqueTags = Set.from(_cloudIssues.map((issue) => issue.tag));
    _tags = ['All', ...uniqueTags.toList()]; // Add 'All' option to the beginning
  }

  /// Filters the issues by the specified tag.
  /// The filtered issues are stored in the `_filteredIssues` list.
  /// If the tag is 'All', all issues are displayed.
  /// Otherwise, only the issues with the specified tag are displayed.
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

  /// Fetches the profile picture URL of the author with the specified UID.
  /// Returns the profile picture URL if available, otherwise returns null.
  /// If an error occurs during the fetch operation, the error is printed and null is returned.
  /// The author's profile picture URL is fetched from the 'users' collection in Firestore.
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

  /// Fetches the name of the author with the specified UID.
  /// Returns the author's name if available, otherwise returns null.
  /// If an error occurs during the fetch operation, the error is printed and null is returned.
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
      return null;
    } catch (e) {
      print('Error fetching author name: $e');
      return null;
    }
  }

  /// Builds the widget tree for this screen.
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
              _analyticsService.logCustomEvent(eventName: 'inspect_issue', parameters: {'issue_title': issue.title});
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
                            : const AssetImage('assets/default_profile.png') as ImageProvider,
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

  /// Builds a container for the specified tag with a specific color based on the tag.
  /// The tag container is used to display the tag of an issue with a colored background.
  /// The color of the container is determined based on the tag name.
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

  /// Returns a color based on the specified tag.
  /// The color is determined based on the tag name.
  /// The color is used to display the tag of an issue with a colored background.
  Color _getTagColor(String tag) {
    switch (tag.toLowerCase()) {
      case 'work':
        return Colors.orange;
      case 'leisure':
        return Colors.red;
      case 'health':
        return Colors.green;
      case 'finance':
        return Colors.blue;
      case 'event':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  /// Returns a string representing the time elapsed since the issue was created.
  /// The time elapsed is calculated based on the difference between the current time and the creation time of the issue.
  /// The time elapsed is displayed in a human-readable format, such as 'just now', '5 minutes ago', 'yesterday', etc.
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multilogin2/utils/issue.dart';

/// `IssueDetailPage` is a class that displays the details of a specific issue.
///
/// It uses `FirebaseFirestore` to fetch the author's details and `ImageProvider` to display the author's profile picture.
/// It also provides several methods to fetch author details, format timestamps, and build tag containers.
///
/// Methods:
/// - `initState()`: Initializes the state of the widget. It fetches the author's details.
/// - `_fetchAuthorDetails()`: Fetches the author's name and profile picture URL.
/// - `fetchAuthorProfilePicture(String uid)`: Fetches the profile picture URL of the author with the specified UID.
/// - `fetchAuthorName(String uid)`: Fetches the name of the author with the specified UID.
/// - `_buildTagContainer(String tag)`: Builds a container for the specified tag with a specific color based on the tag.
/// - `formatTimestamp(Timestamp? timestamp)`: Returns a string representing the formatted timestamp.
/// - `_getMonthAbbreviation(int month)`: Returns a 3-letter abbreviation of the specified month.
/// - `build(BuildContext context)`: Builds the widget tree for this screen.

class IssueDetailPage extends StatefulWidget {
  final Issue issue;

  const IssueDetailPage({Key? key, required this.issue}) : super(key: key);

  @override
  _IssueDetailPageState createState() => _IssueDetailPageState();
}

class _IssueDetailPageState extends State<IssueDetailPage> {
  String? _authorName;
  String? _profilePictureUrl;

  @override
  void initState() {
    super.initState();
    _fetchAuthorDetails();
  }

  /// Fetches the author's details.
  /// It fetches the author's name and profile picture URL using the `fetchAuthorName` and `fetchAuthorProfilePicture` methods.
  Future<void> _fetchAuthorDetails() async {
    String? name = await fetchAuthorName(widget.issue.uid);
    String? imageUrl = await fetchAuthorProfilePicture(widget.issue.uid);
    setState(() {
      _authorName = name;
      _profilePictureUrl = imageUrl;
    });
  }

  /// Fetches the profile picture URL of the author with the specified UID.
  /// Returns the profile picture URL if it exists, otherwise returns `null`.
  Future<String?> fetchAuthorProfilePicture(String uid) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;
      if (userSnapshot.exists && userData?['image_url'] != null) {
        return userData?['image_url'];
      }
      return null;
    } catch (e) {
      print('Error fetching author photo: $e');
      return null;
    }
  }

  /// Fetches the name of the author with the specified UID.
  /// Returns the name if it exists, otherwise returns `null`.
  Future<String?> fetchAuthorName(String uid) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;
      if (userSnapshot.exists && userData?['name'] != null) {
        return userData?['name'];
      }
      return null;
    } catch (e) {
      print('Error fetching author name: $e');
      return null;
    }
  }

  /// Builds a container for the specified tag with a specific color based on the tag.
  Widget _buildTagContainer(String tag) {
    Color color;
    switch (tag) {
      case 'Work':
        color = Colors.orange;
        break;
      case 'Leisure':
        color = Colors.yellow;
        break;
    // Add more cases for other tags as needed
      default:
        color = Colors.grey; // Default color
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tag,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  /// Returns a string representing the formatted timestamp.
  /// The timestamp is formatted as `day month at hours:minutes`.
  /// Example: `15 Jan at 12:30`
  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';

    final dateTime = timestamp.toDate();

    // Format day
    final day = dateTime.day;

    // Format month in 3-letter abbreviation
    final month = _getMonthAbbreviation(dateTime.month);

    // Format hours with leading zero if necessary
    final hours = dateTime.hour.toString().padLeft(2, '0');

    // Format minutes with leading zero if necessary
    final minutes = dateTime.minute.toString().padLeft(2, '0');

    return '$day $month at $hours:$minutes';
  }

  /// Returns a 3-letter abbreviation of the specified month.
  String _getMonthAbbreviation(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  /// Builds the widget tree for this screen.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Issue Details",
          style: GoogleFonts.exo2(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.issue.title,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(
                    "by",
                    style: TextStyle(fontSize: 10),
                  ),
                  SizedBox(width: 12),
                  CircleAvatar(
                    radius: 14,
                    backgroundImage: _profilePictureUrl != null && _profilePictureUrl!.isNotEmpty
                        ? NetworkImage(_profilePictureUrl!)
                        : AssetImage('assets/default_profile.png') as ImageProvider,
                  ),
                  SizedBox(width: 3),
                  Text(
                    _authorName ?? 'Unknown',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description:',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        widget.issue.description,
                        style: TextStyle(fontSize: 18),
                      ),
                      if (widget.issue.image != '' && widget.issue.image != null) SizedBox(height: 20),
                      if (widget.issue.image != '' && widget.issue.image != null)
                        Image.network(
                          widget.issue.image!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            }
                          },
                          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                            return Text('Error loading image');
                          },
                        ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildTagContainer(widget.issue.tag),
                          Text(
                            formatTimestamp(widget.issue.createdAt),
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

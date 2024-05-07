import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multilogin2/utils/issue.dart';

class IssueDetailPage extends StatelessWidget {
  final Issue issue;

  const IssueDetailPage({Key? key, required this.issue}) : super(key: key);

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    issue.title,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 5), // Reduced spacing
                Text(
                  "by",
                  style: TextStyle(fontSize: 10), // Reduced font size
                ),
                SizedBox(width: 12), // Reduced spacing
                CircleAvatar(
                  radius: 14, // Reduced size
                  backgroundImage: NetworkImage(issue.authorProfilePicture ?? ''),
                ),
                SizedBox(width: 3), // Reduced spacing
                Text(
                  issue.authorName ?? '',
                  style: TextStyle(fontSize: 14), // Reduced font size
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
                      issue.description,
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTagContainer(issue.tag), // Display the styled tag
                        Text(
                          formatTimestamp(issue.createdAt),
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
    );
  }
}

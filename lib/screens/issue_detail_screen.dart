import 'package:flutter/material.dart';
import 'package:multilogin2/utils/issue.dart';

class IssueDetailPage extends StatelessWidget {
  final Issue issue;

  const IssueDetailPage({Key? key, required this.issue}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Issue Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              issue.title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Description: ${issue.description}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Tag: ${issue.tag}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Created At: ${issue.createdAt?.toDate()}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}

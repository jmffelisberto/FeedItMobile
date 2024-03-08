import 'package:cloud_firestore/cloud_firestore.dart';

class Issue {
  final String subject;
  final String description;

  Issue({required this.subject, required this.description});

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'description': description
    };
  }
}

void submitIssue(Issue issue) async {
  try {
    await FirebaseFirestore.instance.collection('issues').add(issue.toMap());
    print('Issue submitted successfully');
  } catch (e) {
    print('Error submitting issue: $e');
  }
}

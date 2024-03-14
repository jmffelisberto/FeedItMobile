import 'package:cloud_firestore/cloud_firestore.dart';

class Issue {
  final String subject;
  final String description;

  Issue({required this.subject, required this.description});

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'description': description,
    };
  }

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      subject: json['subject'],
      description: json['description'],
    );
  }
}

void submitIssue(Issue issue) async {
  try {
    await FirebaseFirestore.instance.collection('issues').add(issue.toJson());
    print('Issue submitted successfully');
  } catch (e) {
    print('Error submitting issue: $e');
  }
}

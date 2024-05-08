import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'image_uploader.dart';

class Issue {
  final String title;
  final String description;
  final String tag;
  String? image;
  String? imagePath; //for local issues
  final Timestamp? createdAt;
  final String? authorName;
  final String? authorProfilePicture;
  final String uid;

  Issue({
    required this.title,
    required this.description,
    required this.tag,
    this.image,
    this.imagePath,
    this.createdAt,
    this.authorName,
    this.authorProfilePicture,
    required this.uid
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'title': title,
      'description': description,
      'tag': tag,
      'uid': uid,
    };
    if (image != null) {
      json['image'] = image;
    }
    if (createdAt != null) {
      json['createdAt'] = createdAt;
    }
    if (authorName != null) {
      json['authorName'] = authorName; // Add author's name field
    }
    if (authorProfilePicture != null) {
      json['authorProfilePicture'] = authorProfilePicture; // Add author's profile picture field
    }
    return json;
  }

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      title: json['title'],
      description: json['description'],
      tag: json['tag'],
      image: json['image'],
      createdAt: json['createdAt'] != null ? Timestamp.fromMillisecondsSinceEpoch(json['createdAt']) : null,
      authorName: json['authorName'], // Add author's name field
      authorProfilePicture: json['authorProfilePicture'], // Add author's profile picture field
      uid: json['uid'],
    );
  }

  static Future<void> submitLocalIssues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? localIssuesJson = prefs.getStringList('local_issues');
    ImageUploader uploader = ImageUploader();

    if (localIssuesJson != null) {
      // Create a copy of the list to iterate over
      List<String> localIssuesJsonCopy = List.from(localIssuesJson);

      for (String issueJson in localIssuesJsonCopy) {
        // Deserialize the issue JSON string
        Map<String, dynamic> jsonIssue = jsonDecode(issueJson);
        Issue issue = Issue.fromJson(jsonIssue);

        // Check if the issue has an image path
        String? imagePath = jsonIssue['imagePath'];
        if (imagePath != null && imagePath.isNotEmpty) {
          // Upload the image to Firebase Storage
          String imageUrl = await uploader.uploadImageToStorage(imagePath);
          // Update the issue object with the image URL
          issue.image = imageUrl;
          issue.imagePath = null;
        }

        // Submit the updated issue to Firestore
        await submitIssueToFirebase(issue);

        // Remove the local issue from SharedPreferences
        localIssuesJson.remove(issueJson);
      }

      // Update SharedPreferences after processing all local issues
      await prefs.setStringList('local_issues', localIssuesJson);
    }
  }



  static Future<void> submitIssueToFirebase(Issue issue) async {
    try {
      await FirebaseFirestore.instance.collection('issues').add(issue.toJson());
      print('Issue submitted successfully');
    } catch (e) {
      print('Error submitting issue: $e');
    }
  }

  static Future<bool> hasInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  static void checkInternetConnectivityPeriodically() {
    const duration = Duration(seconds: 3);
    Timer.periodic(duration, (Timer timer) async {
      var isConnected = await hasInternetConnection();
      if (isConnected) {
        await submitLocalIssues();
        timer.cancel();
      }
    });
  }
}

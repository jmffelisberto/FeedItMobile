import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:multilogin2/provider/analytics_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'image_uploader.dart';

/// `Issue` is a class that represents an issue in the application.
///
/// It provides several properties to store the details of an issue, such as its title, description, tag, image, creation time, and the UID of the user who created it.
/// It also provides methods to convert an `Issue` object to and from a JSON object.
/// Additionally, it provides methods to submit local issues to Firebase Firestore, submit an issue to Firebase Firestore, check if there is an internet connection, and check the internet connectivity periodically.
///
/// Properties:
/// - `title`: The title of the issue.
/// - `description`: The description of the issue.
/// - `tag`: The tag of the issue.
/// - `image`: The URL of the image associated with the issue.
/// - `imagePath`: The local path of the image associated with the issue (for local issues).
/// - `createdAt`: The time when the issue was created.
/// - `uid`: The UID of the user who created the issue.
///
/// Methods:
/// - `toJson()`: Converts this `Issue` object to a JSON object.
/// - `fromJson(Map<String, dynamic> json)`: Creates an `Issue` object from a JSON object.
/// - `submitLocalIssues()`: Submits local issues to Firebase Firestore.
/// - `submitIssueToFirebase(Issue issue)`: Submits an issue to Firebase Firestore.
/// - `hasInternetConnection()`: Checks if there is an internet connection.
/// - `checkInternetConnectivityPeriodically()`: Checks the internet connectivity periodically.

class Issue {
  final String title;
  final String description;
  final String tag;
  String? image;
  String? imagePath; //for local issues
  final Timestamp? createdAt;
  final String uid;

  Issue({
    required this.title,
    required this.description,
    required this.tag,
    this.image,
    this.imagePath,
    this.createdAt,
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
    return json;
  }

  /// Creates an `Issue` object from a JSON object.
  /// The JSON object should have the following keys:
  /// - `title`: The title of the issue.
  /// - `description`: The description of the issue.
  /// - `tag`: The tag of the issue.
  /// - `image`: The URL of the image associated with the issue.
  /// - `createdAt`: The time when the issue was created.
  /// - `uid`: The UID of the user who created the issue.
  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      title: json['title'],
      description: json['description'],
      tag: json['tag'],
      image: json['image'],
      createdAt: json['createdAt'] != null ? Timestamp.fromMillisecondsSinceEpoch(json['createdAt']) : null,
      uid: json['uid'],
    );
  }

  /// Submits local issues to Firebase Firestore.
  /// This method retrieves the local issues from SharedPreferences, deserializes them, and submits them to Firebase Firestore.
  /// If an issue has an associated image, the image is uploaded to Firebase Storage, and the issue object is updated with the image URL before submission.
  /// After submitting an issue, it is removed from SharedPreferences.
  static Future<void> submitLocalIssues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? localIssuesJson = prefs.getStringList('local_issues');
    ImageUploader uploader = ImageUploader();
    final AnalyticsService _analyticsService = AnalyticsService();

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
          _analyticsService.logCustomEvent(eventName: 'issue_with_image', parameters: null);
          // Upload the image to Firebase Storage
          String imageUrl = await uploader.uploadImageToStorage(imagePath);
          // Update the issue object with the image URL
          issue.image = imageUrl;
          issue.imagePath = null;
        }

        // Submit the updated issue to Firestore
        await submitIssueToFirebase(issue);
        _analyticsService.logCustomEvent(eventName: 'issue_submit_no_connection', parameters: {'tag': issue.tag});

        // Remove the local issue from SharedPreferences
        localIssuesJson.remove(issueJson);
      }

      // Update SharedPreferences after processing all local issues
      await prefs.setStringList('local_issues', localIssuesJson);
    }
  }



  /// Submits an issue to Firebase Firestore.
  /// This method submits the provided issue to Firebase Firestore.
  /// If the issue has an associated image, the image is uploaded to Firebase Storage, and the issue object is updated with the image URL before submission.
  static Future<void> submitIssueToFirebase(Issue issue) async {
    try {
      await FirebaseFirestore.instance.collection('issues').add(issue.toJson());
      print('Issue submitted successfully here.');
    } catch (e) {
      print('Error submitting issue: $e');
    }
  }

  /// Checks if there is an internet connection.
  static Future<bool> hasInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Checks the internet connectivity periodically.
  static void checkInternetConnectivityPeriodically() {
    const duration = Duration(seconds: 3);
    Timer.periodic(duration, (Timer timer) async {
      var isConnected = await hasInternetConnection();
      if (isConnected) {
        timer.cancel();
      }
    });
  }
}

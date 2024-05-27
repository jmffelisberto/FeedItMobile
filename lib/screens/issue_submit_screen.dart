import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multilogin2/screens/home_screen.dart';
import 'package:multilogin2/screens/your_issues_screen.dart';
import 'package:multilogin2/utils/issue.dart';
import 'package:multilogin2/utils/next_screen.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import '../utils/image_uploader.dart';

class SubmitIssueScreen extends StatefulWidget {
  const SubmitIssueScreen({Key? key}) : super(key: key);

  @override
  _SubmitIssueScreenState createState() => _SubmitIssueScreenState();
}

class _SubmitIssueScreenState extends State<SubmitIssueScreen> {
  late TextEditingController _titleController = TextEditingController();
  late TextEditingController _descriptionController = TextEditingController();
  late TextEditingController _tagController = TextEditingController();
  late String _selectedTag;
  final List<String> _tagOptions = ['Work', 'Leisure', 'Other'];
  final RoundedLoadingButtonController submitController = RoundedLoadingButtonController();
  File? _imageFile;
  ImageUploader uploader = ImageUploader();
  bool hasInternetConnection = true;


  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _tagController = TextEditingController();
    _selectedTag = _tagOptions.first;
    checkInternetConnection();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      hasInternetConnection = connectivityResult != ConnectivityResult.none;
    });
  }

  Future<void> pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _storeLocally(Issue issue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Serialize the issue object into a JSON string
    Map<String, dynamic> jsonIssue = issue.toJson();
    //print("The image file path is: " + _imageFile.toString());
    String imagePath = _imageFile != null ? path.basename(_imageFile!.path) : '';
    jsonIssue['imagePath'] = imagePath;
    if (issue.createdAt != null) {
      jsonIssue['createdAt'] = issue.createdAt!.millisecondsSinceEpoch;
    }
    // Store the JSON string in shared preferences
    List<String> localIssues = prefs.getStringList('local_issues') ?? [];
    localIssues.add(jsonEncode(jsonIssue));
    await prefs.setStringList('local_issues', localIssues);
  }

  void _submitIssue() async {
    String title = _titleController.text.trim();
    String description = _descriptionController.text.trim();
    String tag = _selectedTag.trim();
    ImageUploader uploader = ImageUploader();

    if (title.isNotEmpty && description.isNotEmpty && tag.isNotEmpty) {
      // Fetch the current user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Fetch author details from Firestore using the UID
        Issue issue = Issue(
          title: title,
          description: description,
          createdAt: Timestamp.now(),
          tag: tag,
          uid: user.uid,
        );

        var connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult != ConnectivityResult.none) {
          // Device is online, submit data to Firestore
          submitController.start();
          String imagePath = _imageFile != null ? _imageFile!.path : '';
          issue.image = await uploader.uploadImageToStorage(imagePath);
          try {
            submitController.success();
            await submitIssueToFirestore(issue);
          } catch (e) {
            print('Error submitting issue: $e');
            submitController.error();
          }
        } else {
          // Device is offline
          await _storeLocally(issue);
          submitController.error();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LocalIssuesScreen(initialTabIndex: 0)),
          );
        }
      } else {
        print('User not logged in');
        submitController.error();
      }
    } else {
      submitController.error();
    }
  }


  Future<void> submitIssueToFirestore(Issue issue) async {
    try {
      await FirebaseFirestore.instance.collection('issues').add(issue.toJson());
      print('Issue submitted successfully');
      await Future.delayed(Duration(milliseconds: 500));
      nextScreenReplace(context, LocalIssuesScreen(initialTabIndex: 1));
    } catch (e) {
      print('Error submitting issue: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Could not submit issue!'),
          content: Text('An unexpected error occured. Please try again later!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment(0.0, 0.40),
              colors: [Colors.black, Colors.white],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 80),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image(
                        image: AssetImage(Config.loba_icon_white),
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 40),
                      Text(
                        "Submit New Issue",
                        style: GoogleFonts.exo2(fontSize: 25, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "What's going on?",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      SizedBox(height: 20),
                      if (!hasInternetConnection) // Show icon and message if there's no internet connection
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width, // Set the width to match the screen width
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.yellow, // Change color as needed
                                borderRadius: BorderRadius.circular(10), // Set border radius to round the corners
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center, // Center the icon and text horizontally
                                crossAxisAlignment: CrossAxisAlignment.center, // Center the icon and text vertically
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16.0), // Add left padding for the icon
                                    child: Icon(
                                      FontAwesomeIcons.exclamationTriangle, // Corrected icon name
                                      color: Colors.red,
                                    ),
                                  ),
                                  SizedBox(width: 16), // Add SizedBox for padding
                                  Flexible( // Use Flexible instead of Expanded
                                    child: Text(
                                      "Turn on mobile data and reload the page to submit an issue with an image",
                                      style: TextStyle(color: Colors.black, fontSize: 12),
                                      maxLines: 2, // Allow the text to have maximum 2 lines
                                      overflow: TextOverflow.ellipsis, // Handle text overflow
                                    ),
                                  ),
                                  SizedBox(width: 16), // Add SizedBox for padding
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(60),
                          topRight: Radius.circular(60),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _titleController,
                                    decoration: InputDecoration(
                                      hintText: 'Issue Title',
                                      hintStyle: TextStyle(color: Colors.grey),
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      contentPadding: EdgeInsets.all(15),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.transparent),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.transparent),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                DropdownButton<String>(
                                  value: _selectedTag,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedTag = value!;
                                    });
                                  },
                                  items: _tagOptions.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.black,
                                    size: 30,
                                  ),
                                  elevation: 8,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                  underline: Container(
                                    height: 2,
                                    color: Colors.black,
                                  ),
                                  isExpanded: false,
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Stack(
                              children: [
                                TextFormField(
                                  controller: _descriptionController,
                                  decoration: InputDecoration(
                                    hintText: 'Description',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    contentPadding: EdgeInsets.all(15),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.transparent),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.transparent),
                                    ),
                                  ),
                                  maxLines: 8,
                                ),
                                Positioned(
                                  left: 5,
                                  bottom: 5,
                                  child: FutureBuilder(
                                    future: Connectivity().checkConnectivity(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        // Future is still loading, display a loading indicator or placeholder
                                        return CircularProgressIndicator(); // or any other widget
                                      } else if (snapshot.connectionState == ConnectionState.done) {
                                        // Future has completed, check the result
                                        if (snapshot.data == ConnectivityResult.none) {
                                          // No internet connection, do not display the IconButton
                                          return SizedBox.shrink(); // Empty SizedBox to occupy space but not render anything
                                        } else {
                                          // Internet connection available, display the IconButton
                                          return IconButton(
                                            icon: Icon(Icons.image),
                                            onPressed: () {
                                              pickImageFromGallery();
                                            },
                                          );
                                        }
                                      } else {
                                        // Handle other ConnectionState if necessary
                                        return SizedBox.shrink();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => HomeScreen()),
                                    );
                                  },
                                  icon: Icon(Icons.arrow_back),
                                  color: Colors.black,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 16.0), // Adjust left padding as needed
                                    child: RoundedLoadingButton(
                                      controller: submitController,
                                      successColor: Colors.green,
                                      errorColor: Colors.red,
                                      onPressed: () async {
                                        submitController.start();
                                        await Future.delayed(Duration(milliseconds: 500));
                                        _submitIssue();
                                      },
                                      width: double.infinity, // Occupy all available width
                                      elevation: 0,
                                      borderRadius: 10,
                                      color: Colors.black,
                                      child: Wrap(
                                        children: const [
                                          Icon(
                                            Icons.subdirectory_arrow_right_outlined,
                                            size: 20,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            "Submit Issue",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        return false; // Prevent the default back button behavior
      },
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multilogin2/provider/sign_in_provider.dart';
import 'package:multilogin2/screens/issue_submit_screen.dart';
import 'package:multilogin2/screens/your_issues_screen.dart';
import 'package:provider/provider.dart';
import 'package:multilogin2/screens/login_screen.dart';
import 'package:multilogin2/utils/next_screen.dart';
import '../provider/analytics_service.dart';
import '../utils/config.dart';
import 'all_issues_screen.dart';
import 'edit_profile_screen.dart';

/// Builds the widget tree for this screen.
///
/// It displays a form with a field for the user's email address.
/// It also provides a button to submit the form.

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();

  Future getData() async {
    final sp = context.read<SignInProvider>();
    sp.getDataFromSharedPreferences();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final sp = context.read<SignInProvider>();
      sp.getDataFromSharedPreferences().then((_) {
        if (sp.uid == null) {
          // If UID is still null, force a logout
          sp.userSignOut();
          nextScreenReplace(context, const LoginScreen());
        }
      });
    });
  }

  Stream<DocumentSnapshot> getUserStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .snapshots();
  }

  /// Builds the widget tree for this screen.
  ///
  /// It displays the user's profile picture, name, and email or phone number.
  /// It also displays buttons to navigate to the All Issues, Submit Issue, Your Issues, and Sign Out screens.
  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SignInProvider>();
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {},
              icon: Image.asset(
                Config.loba_icon_black,
                height: 30,
                width: 30,
              ),
            ),
            title: Text("Dashboard", style: GoogleFonts.exo2()),
            centerTitle: true,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    StreamBuilder<DocumentSnapshot>(
                      stream: getUserStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return SizedBox(
                            width: 120,
                            height: 120,
                            child: Icon(Icons.error),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data == null) {
                          return const SizedBox(
                            width: 120,
                            height: 120,
                            child: Icon(Icons.account_circle, size: 120),
                          );
                        }

                        String profilePictureUrl = snapshot.data!['image_url'] ?? '';

                        return SizedBox(
                          width: 120,
                          height: 120,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              backgroundImage: profilePictureUrl.isNotEmpty
                                  ? NetworkImage(profilePictureUrl)
                                  : AssetImage('assets/default_profile.png') as ImageProvider,
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.yellow,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditAccountScreen(), // Navigate to the EditAccountScreen
                              ),
                            );
                          },
                          child: Icon(
                            FontAwesomeIcons.pencil,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "${sp.name}",
                  style: GoogleFonts.exo2(
                    fontSize: 24, // Adjust the font size as needed
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),
                Text(
                  sp.provider == 'PHONE' ? FirebaseAuth.instance.currentUser?.phoneNumber ?? '' : sp.email ?? '',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w100),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 5,
                    ),
                    if (sp.provider == "FACEBOOK")
                      Icon(
                        FontAwesomeIcons.facebook,
                        color: Colors.blue,
                      ),
                    if (sp.provider == "GOOGLE")
                      Icon(
                        FontAwesomeIcons.google,
                        color: Colors.red,
                      ),
                    if (sp.provider == "PHONE")
                      Icon(
                        FontAwesomeIcons.phone,
                        color: Colors.green,
                      ),
                    if (sp.provider == 'EMAIL')
                      Icon(
                        Icons.email,
                        color: Colors.black,
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _analyticsService.logCustomEvent(eventName: 'read_issues_feed', parameters: null);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AllIssuesPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.zero,
                              bottomLeft: Radius.zero,
                              bottomRight: Radius.zero,
                            ),
                          ),
                        ),
                        child: const Text("All Issues", style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          nextScreenReplace(context, SubmitIssueScreen());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // Background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.zero,
                              topRight: Radius.circular(20), // Top right rounded corner
                              bottomLeft: Radius.zero,
                              bottomRight: Radius.zero,
                            ),
                          ),
                        ),
                        child: const Text("Submit Issue", style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _analyticsService.logCustomEvent(eventName: 'read_own_issues', parameters: null);
                          nextScreenReplace(context, LocalIssuesScreen());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // Background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.zero,
                              topRight: Radius.zero,
                              bottomLeft: Radius.circular(20), // Bottom left rounded corner
                              bottomRight: Radius.zero,
                            ),
                          ),
                        ),
                        child: const Text("Your Issues", style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          sp.userSignOut();
                          nextScreenReplace(context, const LoginScreen());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange, // Background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.zero,
                              topRight: Radius.zero,
                              bottomLeft: Radius.zero,
                              bottomRight: Radius.circular(20), // Bottom right rounded corner
                            ),
                          ),
                        ),
                        child: const Text("Sign Out", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
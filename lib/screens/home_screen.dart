import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multilogin2/provider/sign_in_provider.dart';
import 'package:multilogin2/screens/issue_submit_screen.dart';
import 'package:multilogin2/screens/your_issues_screen.dart';
import 'package:provider/provider.dart';
import 'package:multilogin2/screens/login_screen.dart';
import 'package:multilogin2/utils/next_screen.dart';

import '../utils/config.dart';
import 'all_issues_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future getData() async {
    final sp = context.read<SignInProvider>();
    sp.getDataFromSharedPreferences();
  }

  @override
  void initState() {  //for fetching user data purposes
    super.initState();
    getData();        //here
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SignInProvider>();
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {}, // Change the onPressed logic as needed
              icon: Image.asset(
                Config.loba_icon_black, // Replace this with the path to your logo asset
                height: 30, // Adjust the height of the logo as needed
                width: 30, // Adjust the width of the logo as needed
              ), // You can replace this with your small logo icon
            ),
            title: Text("Dashboard", style: GoogleFonts.exo2()),
            centerTitle: true,// Change the title as needed
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60), // Half of the width/height for a perfect circle
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage("${sp.imageUrl}"),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                        child: const Icon(
                          FontAwesomeIcons.pencil,
                          color: Colors.black,
                          size: 20,
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
                  sp.provider == 'PHONE' ? sp.uid ?? '' : sp.email ?? '',
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
                    if (sp.provider == "EMAIL")
                      Icon(
                        Icons.email,
                        color: Colors.black,
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16), // Add padding to the margins of the screen
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16, // Add vertical spacing between buttons
                    crossAxisSpacing: 16, // Add horizontal spacing between buttons
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AllIssuesPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20), // Top left rounded corner
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
                        onPressed: () { //change here
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
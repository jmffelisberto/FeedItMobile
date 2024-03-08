import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multilogin2/provider/sign_in_provider.dart';
import 'package:multilogin2/screens/issue_submit_screen.dart';
import 'package:provider/provider.dart';
import 'package:multilogin2/screens/login_screen.dart';
import 'package:multilogin2/utils/next_screen.dart';

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
    // change read to watch!!!!
    final sp = context.watch<SignInProvider>();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage("${sp.imageUrl}"),
              radius: 50,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "${sp.name}",
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "${sp.email}",
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w100),
            ),
            const SizedBox(
              height: 15,
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
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black12, // Change the color here
                ),
                onPressed: () {
                  sp.userSignOut();
                  nextScreenReplace(context, const LoginScreen());
                },
                child: const Text("Sign Out",
                    style: TextStyle(
                      color: Colors.white70,
                    ))),
            const SizedBox(
              height: 5,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent, // Change the color here
                ),
                onPressed: () {
                  nextScreenReplace(context, SubmitIssueScreen());
                },
                child: const Text("Submit an Issue",
                    style: TextStyle(
                      color: Colors.black,
                    )))
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:multilogin2/provider/sign_in_provider.dart';
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
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("PROVIDER:"),
                const SizedBox(
                  width: 5,
                ),
                Text("${sp.provider}".toUpperCase(),
                    style: const TextStyle(color: Colors.red)),
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
                    )))
          ],
        ),
      ),
    );
  }
}
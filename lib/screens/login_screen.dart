import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:multilogin2/utils/config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen ({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();
  final RoundedLoadingButtonController googleController = RoundedLoadingButtonController();
  final RoundedLoadingButtonController facebookController = RoundedLoadingButtonController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding:
            const EdgeInsets.only(left: 40, right: 40, top: 90, bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image(
                      image: AssetImage(Config.app_icon),
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Welcome to FlutterFirebase",
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 20),
                    Text("Learn Authentication with Provider",
                      style: TextStyle(fontSize: 15, color: Colors.grey[600]))
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RoundedLoadingButton(
                      controller: googleController,
                      successColor: Colors.red,
                      onPressed: () {},
                      width: MediaQuery.of(context).size.width * 0.80,
                      elevation: 0,
                      borderRadius: 25,
                      color: Colors.red,
                      child: Wrap(
                        children: const [
                          Icon(
                            FontAwesomeIcons.google,
                            size: 20,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text("Sign in with Google",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500)
                          ),
                        ],
                      )
                  ),
                  RoundedLoadingButton(
                      controller: facebookController,
                      successColor: Colors.blue,
                      onPressed: () {},
                      width: MediaQuery.of(context).size.width * 0.80,
                      elevation: 0,
                      borderRadius: 25,
                      color: Colors.blue,
                      child: Wrap(
                        children: const [
                          Icon(
                            FontAwesomeIcons.facebook,
                            size: 20,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text("Sign in with Facebook",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500)
                          ),
                        ],
                      )
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
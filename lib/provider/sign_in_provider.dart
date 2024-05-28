import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:multilogin2/utils/next_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/home_screen.dart';

class SignInProvider extends ChangeNotifier {

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FacebookAuth facebookAuth = FacebookAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();



  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  bool _hasError = false;
  bool get hasError => _hasError;
  String? _errorCode;
  String? get errorCode => _errorCode;
  String? _provider;
  String? get provider => _provider;
  String? _uid;
  String? get uid => _uid;
  String? _email;
  String? get email => _email;
  String? _imageUrl;
  String? get imageUrl => _imageUrl;
  String? _name;
  String? get name => _name;

  void updateName(String newName) {
    _name = newName;
    notifyListeners();
  }

  void updateImage(String newimageUrl) {
    _imageUrl = newimageUrl;
    notifyListeners();
  }

  void updateEmail(String? newEmail) {
    _email = newEmail;
    notifyListeners();
  }

  void updateUid(String? newUid) {
    _uid = newUid;
    notifyListeners();
  }

  void updateProvider(String? newProvider) {
    _provider = newProvider;
    notifyListeners();
  }

  void updateErrorCode(String? newErrorCode) {
    _errorCode = newErrorCode;
    notifyListeners();
  }

  void setHasError(bool value) {
    _hasError = value;
    notifyListeners();
  }

  SignInProvider(){
    checkSignInUser();
  }

  Future checkSignInUser() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool("signed_in") ?? false;
    notifyListeners();
    if (_isSignedIn) {
      await getDataFromSharedPreferences();
    }//changed
  }

  Future setSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.setBool("signed_in", true);
    _isSignedIn = true;
    notifyListeners();
  }

  // sign in with google
  Future signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount =
    await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      // executing our authentication
      try {
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        // signing to firebase user instance
        final User userDetails =
        (await firebaseAuth.signInWithCredential(credential)).user!;

        // now save all values
        _name = userDetails.displayName;
        _email = userDetails.email;
        _imageUrl = userDetails.photoURL;
        _provider = "GOOGLE";
        _uid = userDetails.uid;
        notifyListeners();
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case "account-exists-with-different-credential":
            _errorCode =
              "You already have an account with us. Use correct provider";
            _hasError = true;
            notifyListeners();
            break;

          case "null":
            _errorCode =
              "Some unexpected error while trying to sign in";
            _hasError = true;
            notifyListeners();
            break;
          default:
            _errorCode = e.toString();
            _hasError = true;
            notifyListeners();
        }
      }
    } else {
      _hasError = true;
      notifyListeners();
    }
  }

  // sign in with facebook
  Future signInWithFacebook() async {
    final LoginResult result = await facebookAuth.login();
    // getting the profile
    final graphResponse = await http.get(Uri.parse(
        'https://graph.facebook.com/v2.12/me?fields=name,picture,first_name,last_name,email&access_token=${result.accessToken!.token}'));

    final profile = jsonDecode(graphResponse.body);

    if (result.status == LoginStatus.success) {
      try {
        final OAuthCredential credential =
        FacebookAuthProvider.credential(result.accessToken!.token);
        await firebaseAuth.signInWithCredential(credential);
        // saving the values
        _name = profile['name'];
        _email = profile['email'];
        _imageUrl = profile!['picture']['data']['url'];
        _uid = firebaseAuth.currentUser!.uid;
        _hasError = false;
        _provider = "FACEBOOK";
        notifyListeners();
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case "account-exists-with-different-credential":
            _errorCode =
            "You already have an account with us. Use correct provider";
            _hasError = true;
            notifyListeners();
            break;

          case "null":
            _errorCode = "Some unexpected error while trying to sign in";
            _hasError = true;
            notifyListeners();
            break;
          default:
            _errorCode = e.toString();
            _hasError = true;
            notifyListeners();
        }
      }
    } else {
      _hasError = true;
      notifyListeners();
    }
  }



  // ENTRY FOR CLOUDFIRESTORE
  Future<void> getUserDataFromFirestore(String uid) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();
      if (snapshot.exists) {
        _uid = snapshot['uid'];
        _name = snapshot['name'];
        _email = snapshot['email'];
        _imageUrl = snapshot['image_url'];
        _provider = snapshot['provider'];
        notifyListeners();
        print("User data retrieved from Firestore: $_name, $_email, $_provider");
      } else {
        print("No user found in Firestore with UID: $uid");
      }
    } catch (e) {
      print("Error getting user data from Firestore: $e");
    }
  }

  Future<void> saveDataToFirestore() async {
    try {
      final DocumentReference r = FirebaseFirestore.instance.collection("users").doc(uid);
      await r.set({
        "name": _name,
        "email": _email,
        "uid": _uid,
        "image_url": _imageUrl,
        "provider": _provider,
      });
      notifyListeners();
      print("User data saved to Firestore");
    } catch (e) {
      print("Error saving data to Firestore: $e");
    }
  }

  //shared preferences gets & sets
  Future<void> saveDataToSharedPreferences() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    await s.setString('name', _name!);
    await s.setString('email', _email!);
    await s.setString('uid', _uid!);
    await s.setString('provider', _provider!);
    await s.setString('image_url', _imageUrl!);
    notifyListeners();
    print("User data saved to SharedPreferences");
  }

  Future<void> getDataFromSharedPreferences() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _name = s.getString('name');
    _email = s.getString('email');
    _imageUrl = s.getString('image_url');
    _uid = s.getString('uid');
    _provider = s.getString('provider');
    notifyListeners();
    print("User data retrieved from SharedPreferences: $_name, $_email, $_provider");
  }


  // checkUser exists or not in cloudfirestore
  Future<bool> checkUserExists() async {
    DocumentSnapshot snap =
    await FirebaseFirestore.instance.collection('users').doc(_uid).get();
    if (snap.exists) {
      print("EXISTING USER");
      return true;
    } else {
      print("NEW USER");
      return false;
    }
  }

  // signout
  Future userSignOut() async {
    await firebaseAuth.signOut;
    await googleSignIn.signOut();
    //await facebookAuth.logOut(); --com este comentário funciona

    _isSignedIn = false;
    notifyListeners();
    // clear all storage information
    clearStoredData();
  }

  Future clearStoredData() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.clear();
  }

  void phoneNumberUser(User user, name, email) {
    _name = name;
    _email = email;
    _imageUrl =
    "https://winaero.com/blog/wp-content/uploads/2017/12/User-icon-256-blue.png";
    _uid = FirebaseAuth.instance.currentUser!.uid;
    _provider = "PHONE";
    notifyListeners();
  }

  void fetchUserDataByPhone() async {
    try {
      User user = FirebaseAuth.instance.currentUser!;
      _name = user.displayName;
      _email = user.email;
      _imageUrl = user.photoURL;
      _uid = user.uid;
      _provider = "PHONE";
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  void setUser(Map<String, dynamic> snapshot) {
    _name = snapshot['name'];
    _email = snapshot['email'];
    _imageUrl = snapshot['image_url'];
    _uid = snapshot['uid'];
    _provider = snapshot['provider'];
    notifyListeners();
  }

  Future<void> emailAndPassword({required String email, required String password, required String name}) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Set user data
      _uid = userCredential.user!.uid;
      _email = email;
      _name = name;
      _imageUrl = 'https://winaero.com/blog/wp-content/uploads/2017/12/User-icon-256-blue.png';
      _provider = "EMAIL";
      _hasError = false;
      _errorCode = null;

      // Notify listeners
      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();

      // Notify listeners
      notifyListeners();
    }
  }

  Future<void> handleEmailSignIn(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;

      // Fetch user data from Firestore based on UID
      await getUserDataFromFirestore(uid!);

      // Save user data to SharedPreferences
      saveDataToSharedPreferences();
      // Navigate to the home screen
    } catch (e) {
      if (e.toString() == 'user-not-found') {
        throw ('No user found for that email.');
      } else if (e.toString() == 'wrong-password') {
        throw ('Wrong password provided for that user.');
      } else {
        throw ('An error occurred. Please try again later.');
      }
    }
  }
}

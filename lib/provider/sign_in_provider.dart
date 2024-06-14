import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:multilogin2/provider/analytics_service.dart';
import 'package:multilogin2/utils/next_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/home_screen.dart';

/// `SignInProvider` is a class that handles user sign-in operations.
///
/// It uses `FirebaseAuth`, `FacebookAuth`, `GoogleSignIn`, and `AnalyticsService` to handle different sign-in methods.
/// It also provides several getters and setters to access and update the user's information.
///
/// Methods:
/// - `SignInProvider()`: Constructor that checks if the user is already signed in.
/// - `checkSignInUser()`: Checks if the user is already signed in.
/// - `setSignIn()`: Sets the user as signed in.
/// - `signInWithGoogle()`: Signs in the user with Google.
/// - `signInWithFacebook()`: Signs in the user with Facebook.
/// - `getUserDataFromFirestore(String uid)`: Fetches the user's data from Firestore.
/// - `saveDataToFirestore()`: Saves the user's data to Firestore.
/// - `saveDataToSharedPreferences()`: Saves the user's data to SharedPreferences.
/// - `getDataFromSharedPreferences()`: Retrieves the user's data from SharedPreferences.
/// - `checkUserExists()`: Checks if the user exists in Firestore.
/// - `userSignOut()`: Signs out the user.
/// - `clearStoredData()`: Clears the stored data.
/// - `phoneNumberUser(User user, name, email)`: Sets the user's information for phone number sign-in.
/// - `fetchUserDataByPhone(BuildContext context)`: Fetches the user's data by phone.
/// - `setUser(Map<String, dynamic> snapshot)`: Sets the user's information.
/// - `emailAndPassword({required String email, required String password, required String name})`: Signs up the user with email and password.
/// - `handleEmailSignIn(String email, String password)`: Signs in the user with email and password.
class SignInProvider extends ChangeNotifier {

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FacebookAuth facebookAuth = FacebookAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final AnalyticsService _analyticsService = AnalyticsService();



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

  /// Check if the user is already signed in
  /// This method checks if the user is already signed in by checking the `signed_in` key in SharedPreferences.
  /// If the user is signed in, it calls the `getDataFromSharedPreferences()` method to retrieve the user's information.
  /// If the user is not signed in, it does nothing.
  Future checkSignInUser() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool("signed_in") ?? false;
    notifyListeners();
    if (_isSignedIn) {
      await getDataFromSharedPreferences();
    }//changed
  }

  /// Set the user as signed in
  /// This method sets the user as signed in by setting the `signed_in` key in SharedPreferences to `true`.
  /// It also updates the `_isSignedIn` variable and notifies the listeners.
  /// This method is called after the user successfully signs in.
  /// It is used to keep the user signed in even after the app is closed.
  Future setSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.setBool("signed_in", true);
    _isSignedIn = true;
    notifyListeners();
  }

  /// Sign in with Google
  /// This method signs in the user with Google.
  /// It uses the `googleSignIn` and `firebaseAuth` instances to authenticate the user.
  /// If the sign-in is successful, it saves the user's information to the provider's variables.
  /// If the sign-in is unsuccessful, it sets the `hasError` variable to `true`.
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
        _analyticsService.logLogin('google');
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

  /// Sign in with Facebook
  /// This method signs in the user with Facebook.
  /// It uses the `facebookAuth` instance to authenticate the user.
  /// If the sign-in is successful, it saves the user's information to the provider's variables.
  /// If the sign-in is unsuccessful, it sets the `hasError` variable to `true`.
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
        _analyticsService.logLogin('facebook');
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



  /// Fetch user data from Firestore
  /// This method fetches the user's data from Firestore based on the user's UID.
  /// It uses the `FirebaseFirestore` instance to access the `users` collection and fetch the user's document.
  /// If the document exists, it saves the user's information to the provider's variables.
  /// If the document does not exist, it prints a message to the console.
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

  /// Save user data to Firestore
  /// This method saves the user's data to Firestore.
  /// It uses the `FirebaseFirestore` instance to access the `users` collection and save the user's document.
  /// If the data is saved successfully, it prints a message to the console.
  /// If there is an error saving the data, it prints an error message to the console.
  /// This method is called after the user signs in with a new account.
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

  /// Save user data to SharedPreferences
  /// This method saves the user's data to SharedPreferences.
  /// It uses the `SharedPreferences` instance to save the user's information.
  /// If the data is saved successfully, it prints a message to the console.
  /// If there is an error saving the data, it prints an error message to the console.
  /// This method is called after the user signs in with a new account.
  /// It is used to keep the user signed in even after the app is closed.
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

  /// Get user data from SharedPreferences
  /// This method retrieves the user's data from SharedPreferences.
  /// It uses the `SharedPreferences` instance to get the user's information.
  /// If the data is retrieved successfully, it prints a message to the console.
  /// If there is an error retrieving the data, it prints an error message to the console.
  /// This method is called when the app is opened to check if the user is already signed in.
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


  /// Check if the user exists
  /// This method checks if the user exists in Firestore based on the user's UID.
  /// It uses the `FirebaseFirestore` instance to access the `users` collection and fetch the user's document.
  /// If the document exists, it returns `true`.
  /// If the document does not exist, it returns `false`.
  /// This method is called when the user signs in with a new account to check if the user already exists.
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

  /// Sign out the user
  /// This method signs out the user by calling the `signOut` method on the `firebaseAuth` instance.
  /// It also calls the `signOut` method on the `googleSignIn` instance to sign out the user from Google.
  /// It logs the sign-out event using the `AnalyticsService` instance.
  /// It sets the `_isSignedIn` variable to `false` and notifies the listeners.
  /// This method is called when the user signs out from the app.
  Future userSignOut() async {
    await firebaseAuth.signOut;
    await googleSignIn.signOut();
    _analyticsService.logSignOut();
    _isSignedIn = false;
    notifyListeners();
    // clear all storage information
    clearStoredData();
  }

  /// Clear stored data
  /// This method clears the stored data from SharedPreferences.
  /// It uses the `SharedPreferences` instance to clear all the stored data.
  /// This method is called when the user signs out from the app.
  Future clearStoredData() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.clear();
  }

  /// Set the user's information for phone number sign-in
  /// It saves the user's information to the provider's variables.
  void phoneNumberUser(User user, name, email) {
    _name = name;
    _email = email;
    _imageUrl =
    "https://winaero.com/blog/wp-content/uploads/2017/12/User-icon-256-blue.png";
    _uid = FirebaseAuth.instance.currentUser!.uid;
    _provider = "PHONE";
    notifyListeners();
  }

  /// Fetch user data by phone
  /// This method fetches the user's data from Firestore based on the user's phone number.
  /// It uses the `FirebaseFirestore` instance to access the `users` collection and fetch the user's document.
  /// If the document exists, it saves the user's information to the provider's variables.
  /// If the document does not exist, it sets the `hasError` variable to `true`.
  /// This method is called when the user signs in with a phone number.
  Future<void> fetchUserDataByPhone(BuildContext context) async {
    try {
      // Get the current user's UID
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No user currently logged in');
      }

      String uid = currentUser.uid;

      // Access the "users" collection in Firestore and fetch the document with the given UID
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

        // Set user data
        _name = userData['name'];
        _email = userData['email'];
        _imageUrl = userData['image_url'];
        _uid = userData['uid'];
        _provider = "PHONE";

        notifyListeners();

        // Save data to SharedPreferences
        await saveDataToSharedPreferences();

        // Navigate to the home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        print("User not found");
        throw Exception('User not found');
      }
    } catch (e) {
      print("Error fetching user data: $e");
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
      throw e;
    }
  }


  /// Set user data
  /// This method sets the user's information based on the snapshot data.
  /// It saves the user's information to the provider's variables.
  /// It notifies the listeners to update the UI.
  void setUser(Map<String, dynamic> snapshot) {
    _name = snapshot['name'];
    _email = snapshot['email'];
    _imageUrl = snapshot['image_url'];
    _uid = snapshot['uid'];
    _provider = snapshot['provider'];
    notifyListeners();
  }

  /// Sign up with email and password
  /// This method signs up the user with email and password.
  /// It uses the `FirebaseAuth` instance to create a new user with the given email and password.
  /// If the sign-up is successful, it saves the user's information to the provider's variables.
  /// If the sign-up is unsuccessful, it sets the `hasError` variable to `true`.
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
      _analyticsService.logSignUp();
      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();

      // Notify listeners
      notifyListeners();
    }
  }

  /// Sign in with email and password
  /// This method signs in the user with email and password.
  /// It uses the `FirebaseAuth` instance to sign in the user with the given email and password.
  /// If the sign-in is successful, it fetches the user's data from Firestore based on the UID.
  /// If the sign-in is unsuccessful, it throws an error message.
  Future<void> handleEmailSignIn(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      // Fetch user data from Firestore based on UID
      await getUserDataFromFirestore(uid!);
      setSignIn();
      // Save user data to SharedPreferences
      saveDataToSharedPreferences();
      _analyticsService.logLogin('email');
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

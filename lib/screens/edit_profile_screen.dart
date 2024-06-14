import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../provider/sign_in_provider.dart';
import '../utils/image_uploader.dart';

/// `EditAccountScreen` is a class that displays the user profile editing form.
///
/// It uses `SignInProvider` to handle user profile updates and `ImagePicker` to handle profile picture selection.
/// It also provides several methods to handle user interactions, form submissions, and image selection.
///
/// Methods:
/// - `initState()`: Initializes the state of the widget. It sets the initial value of the name field to the current name.
/// - `_getImage(ImageSource source)`: Opens the image picker and sets the selected image as the profile picture.
/// - `_updateProfile()`: Updates the user's profile with the entered name and selected image.
/// - `build(BuildContext context)`: Builds the widget tree for this screen.
class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({Key? key}) : super(key: key);

  @override
  _EditAccountScreenState createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  File? _image;

  /// Initializes the state of the widget. It sets the initial value of the name field to the current name.
  @override
  void initState() {
    super.initState();
    final sp = context.read<SignInProvider>();
    _nameController.text = sp.name!; // Set the initial value to the current name
  }

  /// Opens the image picker and sets the selected image as the profile picture.
  ///
  /// [source] is the source of the image, which can be either `ImageSource.gallery` or `ImageSource.camera`.
  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      final uploader = ImageUploader();
      final imageUrl = await uploader.uploadImageToStorage(File(pickedFile.path).path);

      setState(() {
        _image = File(imageUrl);
      });
    }
  }

  /// Updates the user's profile with the entered name and selected image.
  ///
  /// It first checks if the name field is not empty and if an image has been selected.
  /// If the name field is not empty, it updates the user's name.
  /// If an image has been selected, it updates the user's profile picture.
  /// After updating the user's profile, it saves the changes to Firestore and navigates back to the previous screen.
  Future<void> _updateProfile() async {
    try {
      final sp = context.read<SignInProvider>();
      if (_nameController.text.isNotEmpty) {
        sp.updateName(_nameController.text);
      }
      if (_image != null) {
        sp.updateImage(_image!.path);
      }
      sp.updateEmail(sp.email);
      sp.updateProvider(sp.provider);
      sp.updateUid(sp.uid);
      await sp.saveDataToFirestore();

      await Future.delayed(Duration(seconds: 2));

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Profile updated successfully'),
        duration: Duration(seconds: 2),
      ));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update profile. Please try again later.'),
        duration: Duration(seconds: 2),
      ));
    }
  }


  /// Builds the widget tree for this screen.
  ///
  /// It displays a form with fields for the user's name and profile picture.
  /// It also provides a button to save the changes.
  @override
  Widget build(BuildContext context) {
    var sp = context.read<SignInProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile", style: GoogleFonts.exo2()),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile picture section
            Center(
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              leading: Icon(Icons.photo_library),
                              title: Text('Choose from Gallery'),
                              onTap: () {
                                _getImage(ImageSource.gallery);
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.photo_camera),
                              title: Text('Take a Photo'),
                              onTap: () {
                                _getImage(ImageSource.camera);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: CircleAvatar(
                  radius: 80,
                  backgroundImage: _image != null
                      ? NetworkImage(_image!.path) // Use selected image if available
                      : sp.imageUrl != null
                      ? NetworkImage(sp.imageUrl!) // Use user's profile picture URL if available
                      : const NetworkImage('https://winaero.com/blog/wp-content/uploads/2017/12/User-icon-256-blue.png') as ImageProvider, // Use default image if both are null
                ),
              ),
            ),

            SizedBox(height: 20),

            // Name text field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: sp.name
              ),
            ),

            SizedBox(height: 20),

            // Save button
            Center(
              child:
              ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.zero, // Remove o padding interno
              ),
              onPressed: _updateProfile,
              child: SizedBox(
                width: 140,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save, color: Colors.white),
                    SizedBox(width: 10),
                    Text('Save Changes', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),),

          ],
        ),
      ),
    );
  }
}

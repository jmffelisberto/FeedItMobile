import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../provider/sign_in_provider.dart';
import '../utils/image_uploader.dart';

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({Key? key}) : super(key: key);

  @override
  _EditAccountScreenState createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  File? _image;

  @override
  void initState() {
    super.initState();
    final sp = context.read<SignInProvider>();
    _nameController.text = sp.name!; // Set the initial value to the current name
  }


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
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

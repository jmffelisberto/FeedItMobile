import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ImageUploader {
  Future<String> uploadImageToStorage(String imagePath) async {
    // Generate a unique image name
    String imageName = DateTime.now().millisecondsSinceEpoch.toString();

    // Create a reference to the Firebase Storage bucket
    Reference storageReference = FirebaseStorage.instance.ref().child('images/$imageName');

    // Create a File object from the image path
    File? imageFile = File(imagePath);

    try {
      // Upload the image file to Firebase Storage
      UploadTask uploadTask = storageReference.putFile(imageFile);

      // Await the completion of the upload task
      TaskSnapshot snapshot = await uploadTask;

      // Get the download URL of the uploaded image
      String imageUrl = await snapshot.ref.getDownloadURL();

      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return ''; // Return an empty string if there's an error
    }
  }
}

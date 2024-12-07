// import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart';

// class FirebaseStorageService {
//   final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

//   Future<String?> uploadFile(String path, File file) async {
//     /// Path is the location where the file will be stored in Firebase Storage
//     /// File is the file that will be uploaded
//     try {
//       final ref = _firebaseStorage.ref().child(path);
//       await ref.putFile(file);
//       final url = await ref.getDownloadURL();
//       return url;
//     } catch (e) {
//       print(e);
//       return null;
//     }
//   }
// }
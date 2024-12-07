import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:p2p/services/firebase_service.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController groupDescriptionController =
      TextEditingController();
  final FirebaseService firebaseService = FirebaseService();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String? _imageUrl;
  bool isLoading = false;

  Future<void> _pickImage() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
        isLoading = true;
      });
      String randomGroupPictureId =
          DateTime.now().millisecondsSinceEpoch.toString();
      _imageUrl = await firebaseService.storageService
          .uploadImage(randomGroupPictureId, pickedImage.path);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: groupNameController,
              decoration: const InputDecoration(
                labelText: 'Enter Room Name',
              ),
            ),
            TextField(
              controller: groupDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Enter Room Description',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),
            if (_image != null)
              isLoading
                  ? const Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        CircularProgressIndicator(),
                        Text("Uploading Image to cloudinary Please wait..."),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    )
                  : SizedBox(
                      height: Get.height * 0.5,
                      child: Image.file(File(_image!.path))),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (isLoading) {
                  Get.snackbar('Error', 'Please wait for image to upload');
                  return;
                }
                if (_imageUrl == null) {
                  Get.snackbar('Error', 'Please pick an image');
                  return;
                }
                if (groupNameController.text.isEmpty) {
                  Get.snackbar('Error', 'Please enter a group name');
                  return;
                }
                if (groupDescriptionController.text.isEmpty) {
                  Get.snackbar('Error', 'Please enter a group description');
                  return;
                }

                await firebaseService.createGroup(
                  groupNameController.text,
                  groupDescriptionController.text,
                  _imageUrl!,
                );
                Get.back();
              },
              child: const Text('Create Room'),
            ),
          ],
        ),
      ),
    );
  }
}

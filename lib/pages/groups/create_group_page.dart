import 'dart:io';
import 'dart:math';

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
  final TextEditingController groupInvitationCodeController =
      TextEditingController(text: 'faizan'); // Default value

  final FirebaseService firebaseService = FirebaseService();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String? _imageUrl =
      "https://res.cloudinary.com/drjns19ay/image/upload/v1733682381/1733682006047.png";
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
      final imgUrl = await firebaseService.storageService
          .uploadImage(randomGroupPictureId, pickedImage.path);
      if (imgUrl == null) {
        return;
      }
      _imageUrl = imgUrl;
      setState(() {
        isLoading = false;
      });
    }
  }

  String getRandomText(int length) {
    const characters =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();

    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => characters.codeUnitAt(random.nextInt(characters.length)),
      ),
    );
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar with edit icon
            Align(
              alignment: Alignment.center,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _image != null
                        ? FileImage(File(_image!.path)) as ImageProvider
                        : const AssetImage('assets/default.png'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Room Name',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: groupNameController,
              decoration: InputDecoration(
                hintText: 'Enter Room Name',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(
                    color: Colors.blueAccent,
                    width: 2.0,
                  ),
                ),
              ),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            const Text(
              'Room Description',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: groupDescriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter Room Description',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(
                    color: Colors.blueAccent,
                    width: 2.0,
                  ),
                ),
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Group Invitation Code',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      controller: groupInvitationCodeController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Group Invitation Code',
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        groupInvitationCodeController.text = getRandomText(6);
                      },
                      icon: const Icon(Icons.loop, color: Colors.blueAccent)),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.blueAccent),
                    onPressed: () {
                      // Logic to copy the code
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Invitation Code Copied!'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () async {
                  if (isLoading) {
                    Get.snackbar(
                        'Please wait', 'Uploading image to cloudinary');
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
                    _imageUrl ?? '',
                  );
                  Get.back();
                },
                child: const Text('Create Room'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

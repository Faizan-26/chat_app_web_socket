import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:p2p/services/cloudinary_service.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CloudinaryService storageService = CloudinaryService();

  Future<void> createGroup(
      String name, String description, String pictureUrl) async {
    final user = _auth.currentUser;
    final groupId = _firestore.collection('groups').doc().id;

    await _firestore.collection('groups').doc(groupId).set({
      'name': name,
      'group_id': groupId,
      'picture': pictureUrl,
      'description': description,
      'join_code': 'faizan',
      'members': [user!.uid],
      'admin': user.uid,
    });
  }

  Future<List<Map<String, dynamic>>> getGroups() async {
    final snapshot = await _firestore.collection('groups').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<bool> joinGroup(String groupId, String joinCode) async {
    final user = _auth.currentUser;
    // check if join code is correct
    final snapshot = await _firestore.collection('groups').doc(groupId).get();
    if (snapshot.data()!['join_code'] != joinCode) {
      print("${snapshot.data()} AND $joinCode Are not same");
      return false;
    }

    await _firestore.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayUnion([user!.uid]),
    });
    return true;
  }

  Future<void> leaveGroup(String groupId) async {
    final user = _auth.currentUser;
    await _firestore.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayRemove([user!.uid]),
    });
  }

  Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
    final snapshot = await _firestore.collection('groups').doc(groupId).get();
    return snapshot.data()!['members'];
  }

  // isuser admin
  Future<bool> isUserAdmin(String groupId) async {
    final user = _auth.currentUser;
    final snapshot = await _firestore.collection('groups').doc(groupId).get();
    return snapshot.data()!['admin'] == user!.uid;
  }

  Future<bool> isUserMember(String groupId) async {
    final user = _auth.currentUser;
    final snapshot = await _firestore.collection('groups').doc(groupId).get();
    return snapshot.data()!['members'].contains(user!.uid);
  }

  Stream<List<Map<String, dynamic>>> streamGroups() {
    return _firestore
        .collection('groups')
        .snapshots()
        .distinct()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  

  // change description of groups
  Future<void> updateGroupDescription(
      String groupId, String description) async {
    await _firestore.collection('groups').doc(groupId).update({
      'description': description,
    });
  }

  Future<void> updateGroupName(String groupId, String name) async {
    await _firestore.collection('groups').doc(groupId).update({
      'name': name,
    });
  }

  Future<void> updateGroupPicture(String groupId, String picturePath) async {
    // upload picture to storage from phone path
    final pictureUrl = await storageService.uploadImage(groupId, picturePath);
    if (pictureUrl == null) {
      throw Exception('Failed to upload picture');
    }

    // update group picture in firestore
    await _firestore.collection('groups').doc(groupId).update({
      'picture': pictureUrl,
    });
  }
}

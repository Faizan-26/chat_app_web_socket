// import 'dart:typed_data';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:file_picker/file_picker.dart';

// class GroupChatController {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final Map<String, RTCPeerConnection> _peerConnections = {};
//   final Map<String, RTCDataChannel> _dataChannels = {};
//   final String userId;

//   GroupChatController(this.userId);

// // ICE Servers are
//   Map<String, dynamic> configuration = {
//     'iceServers': [
//       {
//         'urls': [
//           'stun:stun1.l.google.com:19302',
//           'stun:stun2.l.google.com:19302'
//         ]
//       }
//     ]
//   };

//   // Create a new chat group with a random ID
//   Future<String> createGroup() async {
//     final groupId = _firestore.collection('groups').doc().id;
//     await _firestore.collection('groups').doc(groupId).set({
//       'groupId': groupId,
//       'createdBy': userId,
//       'members': [],
//     });
//     return groupId;
//   }

//   // Fetch all available groups
//   Stream<List<Map<String, dynamic>>> getGroups() {
//     return _firestore.collection('groups').snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) => doc.data()).toList();
//     });
//   }

//   // Join a group
//   Future<void> joinGroup(String groupId) async {
//     await _firestore.collection('groups').doc(groupId).update({
//       'members': FieldValue.arrayUnion([userId])
//     });

//     // Listen for signaling updates
//     _firestore.collection('groups').doc(groupId).snapshots().listen((snapshot) {
//       final data = snapshot.data();
//       if (data != null) {
//         _handleSignaling(groupId, data);
//       }
//     });
//   }

//   // Handle signaling for offers, answers, and ICE candidates
//   Future<void> _handleSignaling(
//       String groupId, Map<String, dynamic> data) async {
//     final Map<String, dynamic>? offers = data['offers'];
//     final Map<String, dynamic>? candidates = data['candidates'];

//     if (offers != null) {
//       offers.forEach((peerId, offer) async {
//         if (peerId != userId && !_peerConnections.containsKey(peerId)) {
//           await _createPeerConnection(groupId, peerId, isOffer: false);
//           await _setRemoteDescription(peerId, offer);
//           await _createAnswer(groupId, peerId);
//         }
//       });
//     }

//     if (candidates != null) {
//       candidates.forEach((peerId, candidate) async {
//         await _addIceCandidate(peerId, candidate);
//       });
//     }
//   }

//   // Create peer connection
//   Future<void> _createPeerConnection(String groupId, String peerId,
//       {bool isOffer = true}) async {
//     final pc = await createPeerConnection(configuration);

//     pc.onIceCandidate = (RTCIceCandidate candidate) {
//       _firestore.collection('groups').doc(groupId).update({
//         'candidates.$userId': candidate.toMap(),
//       });
//     };

//     pc.onDataChannel = (RTCDataChannel dataChannel) {
//       _dataChannels[peerId] = dataChannel;
//       dataChannel.onMessage = (RTCDataChannelMessage message) {
//         _handleIncomingMessage(peerId, message);
//       };
//     };

//     if (isOffer) {
//       final dataChannel =
//           await pc.createDataChannel('chat', RTCDataChannelInit());
//       _dataChannels[peerId] = dataChannel;
//       dataChannel.onMessage = (RTCDataChannelMessage message) {
//         _handleIncomingMessage(peerId, message);
//       };
//       await _createOffer(groupId, peerId, pc);
//     }

//     _peerConnections[peerId] = pc;
//   }

//   // Create SDP offer
//   Future<void> _createOffer(
//       String groupId, String peerId, RTCPeerConnection pc) async {
//     final offer = await pc.createOffer();
//     await pc.setLocalDescription(offer);

//     await _firestore.collection('groups').doc(groupId).update({
//       'offers.$userId': offer.toMap(),
//     });
//   }

//   // Create SDP answer
//   Future<void> _createAnswer(String groupId, String peerId) async {
//     final pc = _peerConnections[peerId];
//     if (pc != null) {
//       final answer = await pc.createAnswer();
//       await pc.setLocalDescription(answer);

//       await _firestore.collection('groups').doc(groupId).update({
//         'answers.$userId': answer.toMap(),
//       });
//     }
//   }

//   // Set remote SDP description
//   Future<void> _setRemoteDescription(
//       String peerId, Map<String, dynamic> sdp) async {
//     final pc = _peerConnections[peerId];
//     if (pc != null) {
//       final description = RTCSessionDescription(sdp['sdp'], sdp['type']);
//       await pc.setRemoteDescription(description);
//     }
//   }

//   // Add ICE candidate
//   Future<void> _addIceCandidate(
//       String peerId, Map<String, dynamic> candidate) async {
//     final pc = _peerConnections[peerId];
//     if (pc != null) {
//       final iceCandidate = RTCIceCandidate(
//         candidate['candidate'],
//         candidate['sdpMid'],
//         candidate['sdpMLineIndex'],
//       );
//       await pc.addCandidate(iceCandidate);
//     }
//   }

//   // Handle incoming messages
//   void _handleIncomingMessage(String peerId, RTCDataChannelMessage message) {
//     if (message.isBinary) {
//       // Handle file
//       print("Received file from $peerId");
//     } else {
//       // Handle text message
//       print("Received message from $peerId: ${message.text}");
//     }
//   }

//   // Send a message to all peers
//   void sendMessage(String message) {
//     for (var channel in _dataChannels.values) {
//       channel.send(RTCDataChannelMessage(message));
//     }
//   }

//   // Share a file with all peers
//   Future<void> shareFile() async {
//     final result = await FilePicker.platform.pickFiles();
//     if (result != null && result.files.single.bytes != null) {
//       final Uint8List fileBytes = result.files.single.bytes!;
//       for (var channel in _dataChannels.values) {
//         channel.send(RTCDataChannelMessage.fromBinary(fileBytes));
//       }
//     }
//   }

//   Future<void> dispose() async {
//     for (var pc in _peerConnections.values) {
//       await pc.close();
//     }
//     _peerConnections.clear();
//     _dataChannels.clear();
//   }
// }

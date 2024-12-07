// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:get/get.dart';
// import 'auth_controller.dart';
// import '../models/group_model.dart';
// import 'package:uuid/uuid.dart';

// class PeerConnectionManager {
//   RTCPeerConnection? _peerConnection;
//   RTCDataChannel? _dataChannel;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final Map<String, RTCPeerConnection> _peerConnections = {};
//   // final String _userId = const Uuid().v4(); // Unique ID for this user
//   // user id from the auth controller
//   final String _userId = Get.find<AuthController>().userId;
//   Function(String)? onMessageReceived;
//   final Map<String, RTCDataChannel> _dataChannels = {};
//   Function(bool)? onConnectionStatusChanged;

//   Future<void> createPeerToPeerConnection() async {
//     final configuration = {
//       'iceServers': [
//         {'url': 'stun:stun.l.google.com:19302'},
//       ],
//     };

//     final constraints = {
//       'mandatory': {
//         'OfferToReceiveAudio': true,
//         'OfferToReceiveVideo': true,
//       },
//       'optional': [],
//     };

//     _peerConnection = await createPeerConnection(configuration,
//         constraints); // Create a peer connection with the given configuration and constraints.

//     _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
//       // Handle ICE candidate
//       // Send candidate to remote peer
//       print("ICE candidate received: ${candidate.candidate}");
//     };

//     _peerConnection?.onAddStream = (MediaStream stream) {
//       // Handle remote stream
//       print("Remote stream added: ${stream.id}");
//     };

//     _dataChannel = await _peerConnection?.createDataChannel(
//         'dataChannel', RTCDataChannelInit());
//     _dataChannel?.onMessage = (RTCDataChannelMessage message) {
//       // Handle data channel message
//       // check message.type to determine the type of message
//       if (message.isBinary) {
//         // Handle binary message means it is a file
//         print("Binary message received");
//       } else {
//         // Handle text message means it is a text message
//         print("Text message received: ${message.text}");
//         onMessageReceived?.call(message.text);
//       }
//     };
//   }

//   Future<void> createOffer() async {
//     if (_peerConnection == null) return;

//     final offer = await _peerConnection!.createOffer();
//     await _peerConnection!.setLocalDescription(offer);

//     // Send offer.sdp and offer.type to remote peer
//     print("Offer created: ${offer.sdp}");
//   }

//   Future<void> createAnswer() async {
//     if (_peerConnection == null) return;

//     final answer = await _peerConnection!.createAnswer();
//     await _peerConnection!.setLocalDescription(answer);

//     // Send answer.sdp and answer.type to remote peer
//     print("Answer created: ${answer.sdp}");
//   }

//   Future<void> setRemoteDescription(String sdp, String type) async {
//     if (_peerConnection == null) {
//       print("IMP peer connection is null");
//       return;
//     }

//     print("IMP setRemoteDescription called");
//     print("IMP sdp: $sdp");
//     print("IMP type: $type");

//     final description = RTCSessionDescription(sdp, type);
//     await _peerConnection!.setRemoteDescription(description);
//     print("IMP Remote description set: $type");
//   }

//   void addCandidate(RTCIceCandidate candidate) {
//     // This function is used to add ICE candidates to the peer connection.
//     _peerConnection?.addCandidate(candidate);
//     print("IMPP ICE candidate added: ${candidate.candidate}");
//   }

//   Future<String> createGroup(String groupName) async {
//     final docRef = await _firestore.collection('groups').add({
//       'name': groupName,
//       'members': [],
//       'peers': {},
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//     print("IMPP Group created with ID: ${docRef.id}");
//     return docRef.id;
//   }

//   Future<void> joinGroup(String groupId) async {
//     final groupDoc = await _firestore.collection('groups').doc(groupId).get();
//     if (!groupDoc.exists) {
//       print("IMPP Group does not exist: $groupId");
//       return;
//     }

//     await _firestore.collection('groups').doc(groupId).update({
//       'members': FieldValue.arrayUnion([_userId]),
//       'peers.$_userId': {'offer': null, 'answer': null, 'candidates': []},
//     });
//     print("IMPP Joined group: $groupId");

//     // Listen for changes in the group's peers
//     _firestore.collection('groups').doc(groupId).snapshots().listen((snapshot) {
//       final groupData = snapshot.data();
//       if (groupData != null) {
//         final peers = Map<String, dynamic>.from(groupData['peers'] ?? {});
//         peers.remove(_userId); // Remove self

//         // Notify UI about the connection status
//         onConnectionStatusChanged?.call(peers.isNotEmpty);
//         print("IMPP Connection status changed: ${peers.isNotEmpty}");

//         // For each peer, establish a connection if not already connected
//         for (String peerId in peers.keys) {
//           if (!_peerConnections.containsKey(peerId)) {
//             _connectToPeer(peerId, groupId);
//           }
//         }
//       }
//     });
//   }

//   Future<void> _connectToPeer(String peerId, String groupId) async {
//     final groupDoc = await _firestore.collection('groups').doc(groupId).get();
//     if (!groupDoc.exists) {
//       print("IMPP Group does not exist: $groupId");
//       return;
//     }

//     final configuration = {
//       'iceServers': [
//         {'url': 'stun:stun.l.google.com:19302'},
//       ],
//     };
//     final constraints = {
//       'mandatory': {
//         'OfferToReceiveAudio': true,
//         'OfferToReceiveVideo': true,
//       },
//       'optional': [],
//     };
//     final pc = await createPeerConnection(configuration, constraints);
//     _peerConnections[peerId] = pc;

//     // Handle incoming data channels from remote peers
//     pc.onDataChannel = (RTCDataChannel dataChannel) {
//       dataChannel.onMessage = (RTCDataChannelMessage message) {
//         if (message.isBinary) {
//           print("IMPP Binary message received from peer: $peerId");
//         } else {
//           print(
//               "IMPP Text message received from peer: $peerId - ${message.text}");
//           onMessageReceived?.call(message.text);
//         }
//       };
//       _dataChannels[peerId] = dataChannel;
//       print("IMPP Data channel received from peer: $peerId");
//     };

//     // Handle ICE candidates
//     pc.onIceCandidate = (candidate) {
//       _firestore.collection('groups').doc(groupId).update({
//         'peers.$_userId.candidates': FieldValue.arrayUnion([candidate.toMap()]),
//       });
//       print("IMPP ICE candidate sent to Firestore: ${candidate.candidate}");
//     };

//     // Remove duplicate snapshot listeners to prevent conflicts
//     // Consolidate offer and answer handling into a single listener

//     _firestore
//         .collection('groups')
//         .doc(groupId)
//         .snapshots()
//         .listen((snapshot) async {
//       final groupData = snapshot.data();
//       if (groupData != null) {
//         final peers = Map<String, dynamic>.from(groupData['peers'] ?? {});
//         final peerData = peers[peerId];
//         if (peerData != null) {
//           // Handle Offer
//           if (peerData['offer'] != null) {
//             final offer = RTCSessionDescription(
//               peerData['offer']['sdp'],
//               peerData['offer']['type'],
//             );
//             if (pc.signalingState ==
//                     RTCSignalingState.RTCSignalingStateStable ||
//                 pc.signalingState ==
//                     RTCSignalingState.RTCSignalingStateHaveRemoteOffer) {
//               await pc.setRemoteDescription(offer);
//               print("IMP Offer received and set for peer: $peerId");

//               final answer = await pc.createAnswer();
//               await pc.setLocalDescription(answer);
//               _firestore.collection('groups').doc(groupId).update({
//                 'peers.$_userId.answer': answer.toMap(),
//               });
//               print("IMP Answer created and sent for peer: $peerId");
//             }
//           }

//           // Handle Answer
//           if (peerData['answer'] != null) {
//             final answer = RTCSessionDescription(
//               peerData['answer']['sdp'],
//               peerData['answer']['type'],
//             );
//             await pc.setRemoteDescription(answer);
//             print("IMP Answer received and set for peer: $peerId");
//           }

//           // Add received ICE candidates
//           if (peerData['candidates'] != null) {
//             final candidates = List<dynamic>.from(peerData['candidates']);
//             for (var cand in candidates) {
//               final candidate = RTCIceCandidate(
//                 cand['candidate'],
//                 cand['sdpMid'],
//                 cand['sdpMLineIndex'],
//               );
//               await pc.addCandidate(candidate);
//               print("IMP ICE candidate added from peer: $peerId");
//             }
//           }
//         }
//       }
//     });

//     // Create offer and set local description
//     final offer = await pc.createOffer();
//     print("IMPP Offer created for peer $peerId: ${offer.sdp}");
//     await pc.setLocalDescription(offer);
//     print("IMPP Offer created for peer $peerId: ${offer.sdp}");

//     // Send offer to peer via Firestore
//     _firestore.collection('groups').doc(groupId).update({
//       'peers.$_userId.offer': offer.toMap(),
//     });
//     print("IMPP Offer sent to Firestore for peer $peerId");

//     // Create data channel if initiating the connection
//     if (_userId.compareTo(peerId) < 0) {
//       final dataChannel =
//           await pc.createDataChannel('dataChannel', RTCDataChannelInit());
//       dataChannel.onMessage = (RTCDataChannelMessage message) {
//         if (message.isBinary) {
//           print("IMPP Binary message received from peer: $peerId");
//         } else {
//           print(
//               "IMPP Text message received from peer: $peerId - ${message.text}");
//           onMessageReceived?.call(message.text);
//         }
//       };
//       _dataChannels[peerId] = dataChannel;
//       print("IMPP Data channel created with peer: $peerId");
//     }

//     print("IMPP Connection established with peer: $peerId");
//   }

//   Future<void> leaveGroup(String groupId) async {
//     final groupDoc = await _firestore.collection('groups').doc(groupId).get();
//     if (!groupDoc.exists) {
//       print("IMPP Group does not exist: $groupId");
//       return;
//     }
//     String userId = Get.find<AuthController>().userId;

//     // Remove user from group members
//     await _firestore.collection('groups').doc(groupId).update({
//       'members': FieldValue.arrayRemove([userId]),
//       'peers.$userId': FieldValue.delete(),
//     });
//     print("IMPP User $userId removed from group: $groupId");

//     // Close and remove all peer connections
//     for (var pc in _peerConnections.values) {
//       pc.close();
//       print("IMPP Peer connection closed");
//     }
//     _peerConnections.clear();

//     // Close the main peer connection and data channel
//     _peerConnection?.close();
//     _peerConnection = null;
//     _dataChannel?.close();
//     _dataChannel = null;
//     print("IMPP Main peer connection and data channel closed");
//     print("IMPP Left group: $groupId");
//   }

//   void dispose() {
//     print("IMPP Disposing PeerConnectionManager");
//     leaveGroup('groupId').then((_) {
//       _peerConnection?.close();
//       _peerConnection = null;
//       _dataChannel?.close();
//       _dataChannel = null;
//       for (var pc in _peerConnections.values) {
//         pc.close();
//         print("IMPP Peer connection closed");
//       }
//       _peerConnections.clear();
//     });
//   }

//   void sendMessage(String groupId, String message) {
//     for (var dataChannel in _dataChannels.values) {
//       dataChannel.send(RTCDataChannelMessage(message));
//       print("IMPP Message sent to peer: ${dataChannel.label} - $message");
//     }
//     onMessageReceived?.call(message);
//   }

//   Stream<Group> getGroupStream(String groupId) {
//     return _firestore.collection('groups').doc(groupId).snapshots().map((doc) {
//       return Group.fromDocument(doc);
//     });
//   }

//   Future<void> onGroupSelected(String groupId) async {
//     await joinGroup(groupId);
//   }

//   int getConnectedPeersCount() {
//     return _dataChannels.length;
//   }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';

// class WebRTCMessageApp extends StatefulWidget {
//   const WebRTCMessageApp({super.key});

//   @override
//   State<WebRTCMessageApp> createState() => _WebRTCMessageAppState();
// }

// class _WebRTCMessageAppState extends State<WebRTCMessageApp> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   RTCPeerConnection? _peerConnection;
//   RTCDataChannel? _dataChannel;
//   final String _roomId = "exampleRoom";
//   bool isCaller = true; // Add this flag to determine the role

//   @override
//   void initState() {
//     super.initState();
//     _initializePeerConnection();
//     if (isCaller) {
//       _createOffer(); // Caller creates the offer
//       _listenForRemoteAnswer();
//     } else {
//       _handleRemoteOffer(); // Callee handles the incoming offer
//     }
//     _listenForRemoteCandidates(); // Both peers listen for ICE candidates
//   }

//   /// Initializes the WebRTC peer connection and sets up listeners.
//   Future<void> _initializePeerConnection() async {
//     try {
//       // Peer connection configuration
//       final Map<String, dynamic> config = {
//         'iceServers': [
//           {'urls': 'stun:stun.l.google.com:19302'},
//         ],
//       };

//       // Create peer connection
//       _peerConnection = await createPeerConnection(config);

//       // Handle ICE candidates
//       _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
//         _firestore
//             .collection('rooms/$_roomId/iceCandidates')
//             .add(candidate.toMap());
//       };

//       // Listen for remote ICE candidates
//       _listenForRemoteCandidates();

//       // Listen for remote SDP answer
//       _listenForRemoteAnswer();

//       // Caller creates the data channel
//       if (isCaller) {
//         _dataChannel = await _peerConnection?.createDataChannel(
//           'chat',
//           RTCDataChannelInit(),
//         );
//         _setupDataChannel(_dataChannel!);
//       } else {
//         // Callee handles incoming data channels
//         _peerConnection?.onDataChannel = (RTCDataChannel channel) {
//           _setupDataChannel(channel);
//         };
//       }

//       print('Peer connection initialized.');
//     } catch (e) {
//       print('Error initializing peer connection: $e');
//     }
//   }

//   /// Sets up the data channel and its events.
//   void _setupDataChannel(RTCDataChannel channel) {
//     _dataChannel = channel;
//     _dataChannel?.onMessage = (RTCDataChannelMessage message) {
//       _showReceivedMessage(message.text);
//     };

//     _dataChannel?.onDataChannelState = (RTCDataChannelState state) {
//       print('Data channel state: $state');
//     };
//   }

//   /// Listens for remote ICE candidates from Firestore.
//   void _listenForRemoteCandidates() {
//     _firestore.collection('rooms/$_roomId/iceCandidates').snapshots().listen(
//       (snapshot) {
//         for (var doc in snapshot.docs) {
//           final data = doc.data();
//           final candidate = RTCIceCandidate(
//             data['candidate'],
//             data['sdpMid'],
//             data['sdpMLineIndex'],
//           );
//           _peerConnection?.addCandidate(candidate);
//         }
//       },
//     );
//   }

//   /// Listens for remote SDP answer from Firestore.
//   void _listenForRemoteAnswer() {
//     _firestore.doc('rooms/$_roomId').snapshots().listen((docSnapshot) async {
//       if (docSnapshot.exists) {
//         final data = docSnapshot.data() as Map<String, dynamic>;
//         if (data['answer'] != null) {
//           await _peerConnection?.setRemoteDescription(
//             RTCSessionDescription(data['answer'], 'answer'),
//           );
//         }
//       }
//     });
//   }

//   /// Handles a remote offer and creates an answer.
//   void _handleRemoteOffer() {
//     _firestore.doc('rooms/$_roomId').snapshots().listen((docSnapshot) async {
//       if (docSnapshot.exists &&
//           await _peerConnection?.getRemoteDescription() == null) {
//         final data = docSnapshot.data() as Map<String, dynamic>;
//         if (data['offer'] != null) {
//           final offer = RTCSessionDescription(
//             data['offer']['sdp'],
//             data['offer']['type'],
//           );
//           await _peerConnection?.setRemoteDescription(offer);

//           // Create an answer
//           final answer = await _peerConnection?.createAnswer();
//           await _peerConnection
//               ?.setLocalDescription(answer ?? RTCSessionDescription('', ''));

//           // Send the answer back to Firestore
//           await _firestore.doc('rooms/$_roomId').update({
//             'answer': {'sdp': answer?.sdp, 'type': answer?.type},
//           });

//           print('Answer created and sent to Firestore.');
//         }
//       }
//     });
//   }

//   /// Creates an SDP offer and sends it to Firestore.
//   Future<void> _createOffer() async {
//     try {
//       final offer = await _peerConnection?.createOffer();
//       if (offer != null) {
//         await _peerConnection?.setLocalDescription(offer);

//         await _firestore.doc('rooms/$_roomId').set({
//           'offer': {'sdp': offer.sdp, 'type': offer.type},
//         });

//         print('Offer created and sent to Firestore.');
//       }
//     } catch (e) {
//       print('Error creating offer: $e');
//     }
//   }

//   /// Sends a message through the data channel.
//   Future<void> _sendMessage(String message) async {
//     if (_dataChannel != null &&
//         _dataChannel!.state == RTCDataChannelState.RTCDataChannelOpen) {
//       _dataChannel?.send(RTCDataChannelMessage(message));
//       print('Message sent: $message');
//     } else {
//       print('Data channel is not open! Current state: ${_dataChannel?.state}');
//     }
//   }

//   /// Displays received messages using a snackbar.
//   void _showReceivedMessage(String message) {
//     if (context.mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Message from peer: $message'),
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _dataChannel?.close();
//     _peerConnection?.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('WebRTC Messaging')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: _createOffer,
//               child: const Text('Create Offer'),
//             ),
//             ElevatedButton(
//               onPressed: () => _sendMessage('Hello!'),
//               child: const Text('Send Message'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

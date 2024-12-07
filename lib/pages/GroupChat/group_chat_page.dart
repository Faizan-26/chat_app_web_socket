// import 'package:flutter/material.dart';
// import '../../controller/peer_connection_managment.dart';
// import '../../models/group_model.dart';

// class GroupChatPage extends StatefulWidget {
//   final Group group;

//   const GroupChatPage({required this.group, super.key});

//   @override
//   GroupChatPageState createState() => GroupChatPageState();
// }

// class GroupChatPageState extends State<GroupChatPage> {
//   final PeerConnectionManager _peerConnectionManager = PeerConnectionManager();
//   final TextEditingController _messageController = TextEditingController();
//   final List<String> _messages = [];
//   bool _isLoading = true;
//   bool _hasPeers = false;

//   @override
//   void initState() {
//     super.initState();
//     _peerConnectionManager.joinGroup(widget.group.id);
//     _peerConnectionManager.onMessageReceived = (message) {
//       setState(() {
//         _messages.add(message);
//       });
//     };
//     _peerConnectionManager.onConnectionStatusChanged = (hasPeers) {
//       setState(() {
//         _isLoading = false;
//         _hasPeers = hasPeers;
//       });
//     };
//   }

//   @override
//   void dispose() {
//     _peerConnectionManager.leaveGroup(
//       widget.group.id,
//     );
//     _peerConnectionManager.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.group.name),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : !_hasPeers
//               ? const Center(child: Text('No active peers in the group'))
//               : Column(
//                   children: [
//                     Expanded(
//                       child: ListView.builder(
//                         itemCount: _messages.length,
//                         itemBuilder: (context, index) {
//                           return ListTile(
//                             title: Text(_messages[index]),
//                           );
//                         },
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: TextField(
//                               controller: _messageController,
//                               decoration: const InputDecoration(
//                                 hintText: 'Enter message',
//                               ),
//                             ),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.send),
//                             onPressed: () {
//                               final message = _messageController.text;
//                               _peerConnectionManager.sendMessage(
//                                   widget.group.id, message);
//                               _messageController.clear();
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//     );
//   }
// }

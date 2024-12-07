// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/group_model.dart';
// import '../pages/GroupChat/group_chat_page.dart';

// class GroupList extends StatelessWidget {
//   const GroupList({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         ElevatedButton(
//           onPressed: () {
//             _showJoinRoomDialog(context);
//           },
//           child: const Text('Join Room with ID'),
//         ),
//         Expanded(
//           child: StreamBuilder<QuerySnapshot>(
//             stream: FirebaseFirestore.instance.collection('groups').snapshots(),
//             builder: (context, snapshot) {
//               if (!snapshot.hasData) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               final groups = snapshot.data!.docs.map((doc) => Group.fromDocument(doc)).toList();

//               return ListView.builder(
//                 itemCount: groups.length,
//                 itemBuilder: (context, index) {
//                   final group = groups[index];
//                   return ListTile(
//                     leading: const Icon(Icons.person),
//                     title: Text(group.name),
//                     subtitle: Text('Members: ${group.members.length}'),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => GroupChatPage(group: group),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   void _showJoinRoomDialog(BuildContext context) {
//     final TextEditingController _roomIdController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Enter Room ID'),
//           content: TextField(
//             controller: _roomIdController,
//             decoration: const InputDecoration(hintText: 'Room ID'),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () async {
//                 final roomId = _roomIdController.text;
//                 final doc = await FirebaseFirestore.instance.collection('groups').doc(roomId).get();
//                 if (doc.exists) {
//                   final group = Group.fromDocument(doc);
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => GroupChatPage(group: group),
//                     ),
//                   );
//                 } else {
//                   // Show error
//                 }
//               },
//               child: const Text('Join'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

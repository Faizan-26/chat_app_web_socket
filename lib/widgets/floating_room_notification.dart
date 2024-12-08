// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:p2p/services/websocket_service.dart';

// class FloatingRoomNotification extends StatelessWidget {
//   final WebSocketService _webSocketService = Get.find();

//   // FloatingRoomNotification({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       if (_webSocketService.fileNotifications.isEmpty) {
//         return const SizedBox.shrink();
//       }

//       return Positioned(
//         top: 50,
//         right: 10,
//         child: Column(
//           children: _webSocketService.fileNotifications.map((notification) {
//             return Card(
//               child: ListTile(
//                 title: Text('Incoming file: ${notification['filename']}'),
//                 subtitle: Text('From: ${notification['sender']}'),
//                 trailing: IconButton(
//                   icon: const Icon(Icons.close),
//                   onPressed: () {
//                     _webSocketService.fileNotifications.remove(notification);
//                   },
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       );
//     });
//   }
// }

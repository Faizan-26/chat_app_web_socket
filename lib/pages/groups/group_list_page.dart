import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p2p/global/gloval_service.dart';
import 'package:p2p/services/firebase_service.dart';
import 'group_chat_page.dart';

class GroupListPage extends StatefulWidget {
  const GroupListPage({super.key});

  @override
  GroupListPageState createState() => GroupListPageState();
}

class GroupListPageState extends State<GroupListPage> {
  final FirebaseService firebaseService = FirebaseService();

  TextEditingController joinCodeController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    joinCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firebaseService.streamGroups(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No groups available'));
          } else {
            final groups = snapshot.data!;
            return ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                print('group: ${groups[index]}');
                return groupListTile(context, groups[index], firebaseService,
                    joinCodeController);
              },
            );
          }
        },
      ),
    );
  }
}

Widget groupListTile(BuildContext context, Map<String, dynamic> group,
    FirebaseService firebaseService, TextEditingController joinCodeController) {
  print(group);
  return ListTile(
    leading: CachedNetworkImage(
      imageUrl: group['picture'],
      placeholder: (context, url) => const SizedBox(
        height: 30,
        width: 30,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          strokeCap: StrokeCap.round,
        ),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    ),
    title: Text(
      group['name'],
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
    trailing: const Icon(Icons.arrow_forward_ios),
    onTap: () async {
      // check if user have joined that group
      bool isMemeber = await firebaseService.isUserMember(group['group_id']);
      if (!isMemeber) {
        // show join code dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Enter Join Code'),
              content: TextField(
                controller: joinCodeController,
                decoration: const InputDecoration(
                  labelText: 'Join Code',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (joinCodeController.text.isEmpty) {
                      Get.snackbar("Invalid Code", "Join Code cannot be empty");
                      return;
                    }
                    try {
                      if (await firebaseService.joinGroup(
                        group['group_id'],
                        joinCodeController.text,
                      )) {
                        Get.back();
                        joinCodeController
                            .clear(); // Clear the text instead of disposing the controller
                        // Get.to(() => GroupChatPage(
                        //       groupName: group['name'],
                        //       groupId: group['group_id'],
                        //     ));
                      } else {
                        Get.snackbar('Error', 'Invalid join code');
                      }
                    } catch (e) {
                      print(e);
                      Get.back();
                      Get.snackbar('Exception', 'Invalid join code');
                      return;
                    }
                  },
                  child: const Text('Join'),
                ),
              ],
            );
          },
        );
        return;
      }
      // check if socket is connected
      if (!webSocketService.isConnected.value) {
        Get.snackbar("Error", "Not connected to socket server");
        return;
      }
      Get.to(
        GroupChatPage(
          groupName: group['name'],
          groupId: group['group_id'],
        ),
      );
    },
  );
}

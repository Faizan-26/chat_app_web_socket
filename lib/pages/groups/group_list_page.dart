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
  final TextEditingController joinCodeController = TextEditingController();

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
                return groupListTile(
                  context,
                  groups[index],
                  firebaseService,
                  joinCodeController,
                );
              },
            );
          }
        },
      ),
    );
  }
}

Widget groupListTile(
  BuildContext context,
  Map<String, dynamic> group,
  FirebaseService firebaseService,
  TextEditingController joinCodeController,
) {
  return InkWell(
    onTap: () async {
      // Check if the user is already a member
      bool isMember = await firebaseService.isUserMember(group['group_id']);
      if (!isMember) {
        showJoinDialog(context, group, firebaseService, joinCodeController);
        return;
      }
      // Check socket connection
      if (!webSocketService.isConnected.value) {
        Get.snackbar("Error", "Not connected to socket server");
        return;
      }
      navigateToGroupChat(context, group);
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: CachedNetworkImageProvider(group['picture']),
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  group['description'] ?? 'No description available',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall!.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    ),
  );
}

void showJoinDialog(
  BuildContext context,
  Map<String, dynamic> group,
  FirebaseService firebaseService,
  TextEditingController joinCodeController,
) {
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
                  joinCodeController.clear();
                  navigateToGroupChat(context, group);
                } else {
                  Get.snackbar('Error', 'Invalid join code');
                }
              } catch (e) {
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
}

void navigateToGroupChat(BuildContext context, Map<String, dynamic> group) {
  Get.to(
    GroupChatPage(
      groupName: group['name'],
      groupId: group['group_id'],
    ),
  );
}

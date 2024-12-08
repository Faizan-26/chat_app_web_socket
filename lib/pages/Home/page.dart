import 'package:flutter/material.dart';
import 'package:p2p/global/gloval_service.dart';
import 'package:p2p/pages/groups/create_group_page.dart';
import 'package:p2p/pages/groups/group_list_page.dart';
import '../../controller/auth_controller.dart';
// import web_socket_service.dart;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    webSocketService.initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Chat'),
        actions: [
          IconButton(
            onPressed: () => AuthController.instance.logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const GroupListPage(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateGroupPage(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Group'),
      ),
    );
  }
}

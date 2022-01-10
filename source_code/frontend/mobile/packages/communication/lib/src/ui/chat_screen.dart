import 'package:flutter/material.dart';
import 'package:shared/shared.dart' show idToProfilePicture, lightGray;

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 3,
        toolbarHeight: 60,
        backgroundColor: theme.scaffoldBackgroundColor,
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          child: Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Icon(Icons.navigate_before, size: 28),
                ),
              ),
              CircleAvatar(
                backgroundImage: NetworkImage(idToProfilePicture("")),
                radius: 24,
              ),
              SizedBox(width: 8),
              const Text(
                "Nicole Mason",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const Expanded(child: SizedBox()),
              InkWell(
                onTap: () {},
                child: Image.asset(
                  "assets/images/call.png",
                  package: "communication",
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(
          top: 16,
          bottom: 30,
          left: 16,
          right: 16,
        ),
        color: lightGray,
        child: Row(
          children: [
            InkWell(
              onTap: () {},
              child: Image.asset(
                "assets/images/image_icon.png",
                package: "communication",
                width: 35,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: TextField(
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  suffixIcon: Icon(
                    Icons.send,
                    color: theme.primaryColor,
                    size: 22,
                  ),
                  contentPadding: const EdgeInsets.all(11),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  isDense: true,
                  isCollapsed: true,
                  hintText: "Type a message here",
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ChatUsersData {
  final String currentUserId;
  final String remoteUserId;
  final String remoteUserName;

  ChatUsersData({
    required this.currentUserId,
    required this.remoteUserId,
    required this.remoteUserName,
  });
}

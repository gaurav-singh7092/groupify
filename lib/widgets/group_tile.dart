import 'package:flutter/material.dart';
import 'package:groupify/widgets/widgets.dart';

import '../pages/chat_page.dart';
class GroupTile extends StatefulWidget {
  final String userName;
  final String groupID;
  final String groupName;
  const GroupTile({Key? key, required this.userName, required this.groupID, required this.groupName}) : super(key: key);

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        nextScreen(context, ChatPage(
          groupID: widget.groupID,
          groupName: widget.groupName,
          userName: widget.userName,
        ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
              backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              widget.groupName.substring(0,1).toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 30,
              ),
            ),
          ),
          title: Text(
            widget.groupName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            "Join the conversation as ${widget.userName}",
            style: TextStyle(
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

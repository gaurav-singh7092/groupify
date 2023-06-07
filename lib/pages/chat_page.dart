import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:groupify/service/database_service.dart';
import 'package:groupify/widgets/message_tile.dart';
import 'package:groupify/widgets/widgets.dart';

import 'group_info.dart';
class ChatPage extends StatefulWidget {
  final String groupID;
  final String groupName;
  final String userName;
  ChatPage({Key? key, required this.groupID, required this.groupName, required this.userName}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  String admin = "";
  ScrollController scrollController = ScrollController();
  TextEditingController messageController = TextEditingController();
  @override
  void initState() {
    getChatandAdmin();
    super.initState();
  }
  getChatandAdmin() {
    DatabaseService().getChats(widget.groupID).then((val) {
      setState(() {
        chats = val;
      });
    });
    DatabaseService().getGroupAdmin(widget.groupID).then((value) {
      setState(() {
        admin = value;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          widget.groupName,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(onPressed: () {
            nextScreen(context, GroupInfo(
              groupID: widget.groupID,
              groupName: widget.groupName,
              adminName: admin,
            ));
          }, icon: const Icon(Icons.info))
        ],
      ),
      body: Stack(
        children: [
          // chat messages
          chatMessages(),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              color: Colors.grey[700],
              child: Row(
                children: [
                  Expanded(child: TextFormField(
                    controller: messageController,
                    style: const TextStyle(
                      color: Colors.white
                    ),
                    decoration: const InputDecoration(
                      hintText: "Send a message",
                      hintStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                    ),
                  )),
                  const SizedBox(width: 12,),
                  GestureDetector(
                    onTap: () {
                      scrollController.animateTo(scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
                      sendMessages();
                    },
                    child: Container(height: 50, width: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                      child: const Center(child: Icon(Icons.send,color: Colors.white,),),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData ?
        ListView.builder(
          controller: scrollController,
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context,index) {
            return MessageTile(message: snapshot.data.docs[index]['message'], sender: snapshot.data.docs[index]['sender'], isMe: widget.userName == snapshot.data.docs[index]['sender']);
          },
        )
        : Container();
      },
    );
  }
  sendMessages() {
    if(messageController.text.isNotEmpty) {
      Map<String,dynamic> chatMessage = {
        "message" : messageController.text,
        "sender" : widget.userName,
        "time" : DateTime.now().millisecondsSinceEpoch,
      };
      DatabaseService().sendMessage(widget.groupID, chatMessage);
      setState(() {
        messageController.clear();
      });
    }
  }
}

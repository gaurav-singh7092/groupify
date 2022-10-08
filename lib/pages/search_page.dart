import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groupify/helper/helper_function.dart';
import 'package:groupify/pages/chat_page.dart';
import 'package:groupify/service/database_service.dart';
import 'package:groupify/widgets/widgets.dart';
class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  QuerySnapshot? searchsnapshot;
  bool hasUserSearched = false;
  String userName = '';
  User? user;
  bool isJoined = false;
  @override
  void initState() {
    super.initState();
    getCurrentUserIdandName();
  }
  getCurrentUserIdandName() async{
    await HelperFunctions.getUserNameFromSF().then((value) {
      setState(() {
        userName = value!;
      });
    });
    user = FirebaseAuth.instance.currentUser;
  }
  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }
  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Search', style: TextStyle(
          fontSize: 27, fontWeight: FontWeight.bold, color: Colors.white,
        ),),
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Expanded(child: TextField(
                  controller: searchController,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  decoration: const InputDecoration(
                    hintText: "Search Groups...",
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.white,fontSize: 16,
                    )
                  ),
                ),
                ),
                GestureDetector(
                  onTap: () {
                    initiateSearchMethod();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(Icons.search,color: Colors.black,),
                  ),
                )
              ],
            ),
          ),
          isLoading ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),) : groupList(),
        ],
      ),
    );
  }
  initiateSearchMethod() async {
    if(searchController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      await DatabaseService().searchByName(searchController.text).then((snapshot) {
        setState(() {
          searchsnapshot = snapshot;
          isLoading = false;
          hasUserSearched = true;
        });
      });
    }
  }
  groupList() {
    return hasUserSearched ?
    ListView.builder(
      shrinkWrap: true,
      itemCount: searchsnapshot!.docs.length,
      itemBuilder: (context, index) {
        return groupTile(
          userName,
          searchsnapshot!.docs[index]['groupID'],
          searchsnapshot!.docs[index]['groupName'],
          searchsnapshot!.docs[index]['admin'],
        );
      },
    )
        : Container();
  }

  Widget groupTile(String userName, String groupId, String groupName, String admin) {
    // check whether user already exist in group
    joinedOrNot(userName,groupId,groupName,admin);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          groupName.substring(0,1).toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
          ),
        ),
      ),
      title: Text(groupName, style: const TextStyle(fontWeight: FontWeight.w600),),
      subtitle: Text("Admin : ${getName(admin)}"),
      trailing: InkWell(
        onTap: () async {
          await DatabaseService(uid: user!.uid).toggleGroupJoin(groupId, userName, groupName);
          if(isJoined) {
            setState(() {
              isJoined = !isJoined;
              showSnackBar(context, Colors.green, "Successfully joined the group");
            });
            Future.delayed(const Duration(seconds: 2), () {
              nextScreen(context,  ChatPage(groupID: groupId, groupName: groupName, userName: userName));
            });
          } else {
            setState(() {
              isJoined = !isJoined;
              showSnackBar(context, Colors.red, "Left the group $groupName");
            });
          }
        },
        child: isJoined ? Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black,
            border: Border.all(color: Colors.white, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: const Text("Joined", style: TextStyle(color: Colors.white),),
        ) : Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).primaryColor,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: const Text("Join", style: TextStyle(color: Colors.white),),
        )
      ),
    );
  }
  joinedOrNot(String userName, String groupId, String groupName, String admin) async{
    await DatabaseService(uid: user!.uid).isUserJoined(groupName, groupId, userName).then((value) {
      setState(() {
        isJoined = value;
      });
    });
  }
}

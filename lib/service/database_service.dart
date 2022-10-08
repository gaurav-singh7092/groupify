import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});
  // reference for our collections
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");
  // updating the user data
  Future savingUserData(String fullname, String email) async {
    return await userCollection.doc(uid).set({
      "fullname": fullname,
      "email": email,
      "groups": [],
      "profilePic": "",
      "uid": uid,
    });
  }
  // saving image link
  Future savingImage(String downloadURL) async{
    return await userCollection.doc(uid).update({
      "profilePic" : downloadURL,
    });
  }

  // getting user data
  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  Future getImage(String downloadUrl) async {
    QuerySnapshot snapshot = await userCollection.where("profilePic", isEqualTo: downloadUrl).get();
    return snapshot;
  }

  // get user groups
  getUserGroup() async {
    return userCollection.doc(uid).snapshots();
  }

  // creating a group
  Future createGroup(String userName, String id, String groupName) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "groupID": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });
    // update the members
    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupID": groupDocumentReference.id,
    });
    DocumentReference userDocumentRef = userCollection.doc(uid);
    return await userDocumentRef.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
  }

  // getting the Chats
  getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  Future getGroupAdmin(String groupId) async {
    DocumentReference d = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['admin'];
  }

  // get groups members
  getGroupMembers(groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  // search groups
  searchByName(String groupName) {
    return groupCollection.where('groupName', isEqualTo: groupName).get();
  }

  // function => bool
  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocumentRef = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentRef.get();
    List<dynamic> groups = await documentSnapshot['groups'];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  // toggling group join/exit
  Future toggleGroupJoin(
      String groupId, String userName, String groupName) async {
    DocumentReference userDocumentRef = userCollection.doc(uid);
    DocumentReference groupDocumentRef = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await userDocumentRef.get();
    List<dynamic> groups = await documentSnapshot['groups'];
    // if user has our group => then remove them or rather rejoin them
    if (groups.contains("${groupId}_$groupName")) {
      await userDocumentRef.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"]),
      });
      await userDocumentRef.update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"]),
      });
    } else {
      await userDocumentRef.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"]),
      });
      await userDocumentRef.update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      });
    }
  }

  // send message
  sendMessage(String groupId, Map<String,dynamic> chatMessageData) async{
    groupCollection.doc(groupId).collection("messages").add(chatMessageData);
    groupCollection.doc(groupId).update({
      "recentMessage" : chatMessageData['message'],
      "recentMessageSender" : chatMessageData['sender'],
      "recentMessageTime" : chatMessageData['time'].toString(),
    });
  }
}

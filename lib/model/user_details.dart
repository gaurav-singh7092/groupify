import 'package:firebase_auth/firebase_auth.dart';

class UserDetails {
  String? displayName;
  String? email;
  String? photoUrl;
  // constructer
  UserDetails({this.displayName, this.email, this.photoUrl});
  // we need to create map
  UserDetails.fromJSON(Map<String, dynamic> json) {
    displayName = json['displayName'];
    photoUrl = json['photoUrl'];
    email = json['email'];
  }
  Map<String,dynamic> toJson() {
    // object - data
    final Map<String,dynamic> data = new Map<String,dynamic>();
    data['displayName'] = this.displayName;
    data['email'] = this.email;
    data['photoUrl'] = this.photoUrl;
    return data;
  }
}
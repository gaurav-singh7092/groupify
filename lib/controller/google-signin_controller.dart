import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
class GoogleSignInController with ChangeNotifier{
  // object
  var _googleSignin = GoogleSignIn();
  GoogleSignInAccount? googleSignInAccount;
  // function for login
  login() async {
    this.googleSignInAccount = await _googleSignin.signIn();

    // call
    notifyListeners();
  }
  // function for logout
  logout() async {
    // empty the value after logout
    this.googleSignInAccount = await _googleSignin.signOut();
    // call
    notifyListeners();
  }
}
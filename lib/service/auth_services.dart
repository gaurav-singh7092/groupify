import 'package:flutter/material.dart';
import "package:firebase_auth/firebase_auth.dart";
import 'database_service.dart';
import 'package:groupify/helper/helper_function.dart';
class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  // login
  Future loginUser(String email, String password) async {
    try {
      User user = (await firebaseAuth.signInWithEmailAndPassword(email: email, password: password)).user!;
      if(user!=null) {
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // register
  Future registerUser(String fullname, String email, String password) async {
    try {
      User user = (await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password)).user!;
      if(user!=null) {
        // call our database service to update data
        await DatabaseService(uid: user.uid).savingUserData(fullname,email);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // signout
  Future signOut() async {
    try {
      await HelperFunctions.saveUserLoggedInStatus(false);
      await HelperFunctions.saveUserNameSF("");
      await HelperFunctions.saveUserEmailSF("");
      await firebaseAuth.signOut();
    } catch(e) {
      return null;
    }
  }

}
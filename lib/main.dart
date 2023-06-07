import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:groupify/helper/helper_function.dart';
import 'package:groupify/pages/home_page.dart';
import 'package:groupify/pages/auth/login_page.dart';
import 'package:groupify/shared/constants.dart';
import 'package:overlay_support/overlay_support.dart';
const AndroidNotificationChannel channel = AndroidNotificationChannel(
    "High importance channel",
    "High Importance Notification",
    importance: Importance.high,
    playSound: true);
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  if(kIsWeb) {
    await Firebase.initializeApp(options: FirebaseOptions(
        apiKey: constants.apiKey,
        appId: constants.appId,
        messagingSenderId: constants.messagingSenderId,
        projectId: constants.projectId));
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isSignedIn = false;
  @override
  void initState() {
    Timer(Duration(seconds: 2), () {
      FlutterNativeSplash.remove();
    });
    super.initState();
    getUserLoggedInStatus();
  }
  getUserLoggedInStatus() async {
    await HelperFunctions.getUserLoggedInStatus().then((value) {
      if(value != null) {
        setState(() {
          _isSignedIn = true;
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        theme: ThemeData(primaryColor: constants().primaryColor, scaffoldBackgroundColor: Colors.white),
        debugShowCheckedModeBanner: false,
        home: _isSignedIn ? const HomePage() : const LoginPage(),
      ),
    );
  }
}

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:groupify/helper/helper_function.dart';
import 'package:groupify/service/auth_services.dart';
import 'package:groupify/service/database_service.dart';
import 'package:groupify/widgets/widgets.dart';
import 'package:groupify/pages/auth/login_page.dart';
import 'package:groupify/pages/home_page.dart';
import 'package:image_picker/image_picker.dart';
class ProfilePage extends StatefulWidget {
  final String userName;
  final String email;
  const ProfilePage({Key? key, required this.email, required this.userName}) : super(key : key);
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // initializing Auth Service
  AuthService authService = AuthService();
  final formKey = GlobalKey<FormState>();
  File? image;
  String? downloadUrl;
  String? profileLink;
  @override
  void initState()  {
    // getUserPic();
    super.initState();
  }
  final imagePicker = ImagePicker();
  // image picker
  Future imagePickerGallery() async {
    //picking image from gallery
    final pick = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pick != null) {
        image = File(pick.path);
      } else {
        showSnackBar(context, Colors.red, "Image Invalid");
      }
    });
  }
  Future imagePickerCamera() async {
    //picking image from camera
    final pick = await imagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pick != null) {
        image = File(pick.path);
      } else {
        showSnackBar(context, Colors.red, "Image Invalid");
      }
    });
  }
  Future uploadImage() async {
    Reference ref = FirebaseStorage.instance.ref().child("images");
    await ref.putFile(image!);
    downloadUrl = await ref.getDownloadURL();
    QuerySnapshot snapshot = await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).savingImage(downloadUrl!);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Profile',style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: [
            Icon(Icons.account_circle, size: 150, color: Colors.grey[700],),
            const SizedBox(height: 15,),
            Text(
              widget.userName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            const SizedBox(height: 30,),
            const Divider(height: 2,),
            ListTile(
              onTap: () {
                nextScreen(context, const HomePage());
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.group),
              title: const Text("Groups", style: TextStyle(color: Colors.black),),
            ),
            ListTile(
              onTap: () async{
              },
              selected: true,
              selectedColor: Theme.of(context).primaryColor,
              selectedTileColor: Colors.grey.shade200,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.person),
              title: const Text("Profile", style: TextStyle(color: Colors.black),),
            ),
            ListTile(
              onTap: () async {
                showDialog(barrierDismissible: false, context: context, builder: (context) {
                  return AlertDialog(
                    title: const Text("Log Out"),
                    content: const Text("Are your sure to Log Out? "),
                    actions: [
                      IconButton(onPressed: () {
                        Navigator.pop(context);
                      }, icon: const Icon(Icons.cancel, color: Colors.red,)),
                      IconButton(onPressed: () async {
                        await authService.signOut();
                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginPage()),
                                (route) => false);
                      }, icon: const Icon(Icons.done, color: Colors.green,))
                    ],
                  );
                });
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.exit_to_app),
              title: const Text("Log Out", style: TextStyle(color: Colors.black),
              ),
            )
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  child: const Icon(
                    Icons.account_circle,
                    size: 120,
                  ),
                ),
                const SizedBox(height: 15,),
                ElevatedButton(onPressed: () async {
                  showDialog(context: context, builder: (context) {
                    return AlertDialog(
                      title: const Text("Upload Photo"),
                      content: const Text("Select from where to upload image "),
                      actions: [
                        TextButton(onPressed: () {
                          imagePickerCamera();
                          uploadImage();
                        }, child: Text("FROM CAMERA",style: TextStyle(color: Theme.of(context).primaryColor),)),
                        TextButton(onPressed: () {
                          imagePickerGallery();
                          uploadImage();
                        }, child: Text("FROM GALLERY",style: TextStyle(color: Theme.of(context).primaryColor),))
                      ],
                    );
                  });
                },
                  child: const Text("Upload Image"),
                ),
                const SizedBox(height: 15,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Full Name",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      widget.userName,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    )
                  ],
                ),
                const Divider(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Email",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      widget.email,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';
import 'package:flashchat/Draggablecard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
var userdetails;

final _auth = FirebaseAuth.instance;
User currentuser;

firebase_storage.FirebaseStorage storage =
    firebase_storage.FirebaseStorage.instance;
String url = "";

class ProfilePicset extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ProfilePicsetState();
}

class ProfilePicsetState extends State<ProfilePicset>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> scaleAnimation;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    getcurruser();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.elasticInOut);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  void getcurruser() async {
    final user = _auth.currentUser;

    if (user != null) {
      currentuser = user;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Material(
            color: Colors.transparent,
            child: ScaleTransition(
                scale: scaleAnimation,
                child: DraggableCard(
                  child: Container(
                    margin: EdgeInsets.all(20.0),
                    padding: EdgeInsets.all(15.0),
                    height: 180.0,
                    decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0))),
                    child: Column(children: <Widget>[
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(
                            top: 30.0, left: 20.0, right: 20.0),
                        child: Text(
                          "Click To Upload Profile Picture",
                          style: TextStyle(
                              color: Colors.lightBlueAccent, fontSize: 16.0),
                        ),
                      )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () async {
                              PickedFile pickedFile = await _picker.getImage(
                                  source: ImageSource.gallery);
                              if (pickedFile != null) {
                                final File file = File(pickedFile.path);
                                final File croppedFile =
                                    await ImageCropper.cropImage(
                                        sourcePath: file.path,
                                        aspectRatioPresets: [
                                          CropAspectRatioPreset.square,
                                          CropAspectRatioPreset.ratio3x2,
                                          CropAspectRatioPreset.original,
                                          CropAspectRatioPreset.ratio4x3,
                                          CropAspectRatioPreset.ratio16x9
                                        ],
                                        androidUiSettings: AndroidUiSettings(
                                            toolbarTitle: 'Cropper',
                                            toolbarColor:
                                                Colors.lightBlueAccent,
                                            toolbarWidgetColor: Colors.white,
                                            initAspectRatio:
                                                CropAspectRatioPreset.original,
                                            lockAspectRatio: false),
                                        iosUiSettings: IOSUiSettings(
                                          minimumAspectRatio: 1.0,
                                        ));

                                try {
                                  await firebase_storage
                                      .FirebaseStorage.instance
                                      .ref(
                                          'UserProfilePic/${currentuser.email}.png')
                                      .putFile(croppedFile);
                                } catch (e) {
                                  // e.g, e.code == 'canceled'
                                }
                                String downloadURL = await firebase_storage
                                    .FirebaseStorage.instance
                                    .ref(
                                        'UserProfilePic/${currentuser.email}.png')
                                    .getDownloadURL();
                                url = downloadURL;
                                currentuser.updatePhotoURL(url);
                                var userdetails = await _firestore
                                    .collection('userdetails')
                                    .get();
                                var k = _firestore.collection('userdetails');
                                if (userdetails != null) {
                                  for (var details in userdetails.docs) {
                                    if (currentuser.email ==
                                        details.get('email')) {
                                      k.doc(details.id).update({
                                        'profilepic': url,
                                      });
                                    }
                                  }
                                }

                                pickedFile = null;
                              }
                              Navigator.pop(context);
                            },
                            child: const Icon(
                              Icons.upload_file,
                              color: Colors.lightBlueAccent,
                              size: 50,
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              PickedFile pickedFile = await _picker.getImage(
                                  source: ImageSource.camera);
                              if (pickedFile != null) {
                                final File file = File(pickedFile.path);
                                final File croppedFile =
                                    await ImageCropper.cropImage(
                                        sourcePath: file.path,
                                        aspectRatioPresets: [
                                          CropAspectRatioPreset.square,
                                          CropAspectRatioPreset.ratio3x2,
                                          CropAspectRatioPreset.original,
                                          CropAspectRatioPreset.ratio4x3,
                                          CropAspectRatioPreset.ratio16x9
                                        ],
                                        androidUiSettings: AndroidUiSettings(
                                            toolbarTitle: 'Cropper',
                                            toolbarColor:
                                                Colors.lightBlueAccent,
                                            toolbarWidgetColor: Colors.white,
                                            initAspectRatio:
                                                CropAspectRatioPreset.original,
                                            lockAspectRatio: false),
                                        iosUiSettings: IOSUiSettings(
                                          minimumAspectRatio: 1.0,
                                        ));
                                try {
                                  await firebase_storage
                                      .FirebaseStorage.instance
                                      .ref(
                                          'UserProfilePic/${currentuser.email}.png')
                                      .putFile(croppedFile);
                                } catch (e) {
                                  // e.g, e.code == 'canceled'
                                }
                                String downloadURL = await firebase_storage
                                    .FirebaseStorage.instance
                                    .ref(
                                        'UserProfilePic/${currentuser.email}.png')
                                    .getDownloadURL();
                                url = downloadURL;
                                pickedFile = null;
                              }
                              Navigator.pop(context);
                            },
                            child: const Icon(
                              Icons.camera_enhance,
                              color: Colors.lightBlueAccent,
                              size: 50,
                            ),
                          ),
                        ],
                      ),
                    ]),
                  ),
                ))));
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashchat/MainProfileList.dart';
import 'package:flutter/material.dart';
import 'package:flashchat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:random_string/random_string.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_cropper/image_cropper.dart';

firebase_storage.FirebaseStorage storage =
    firebase_storage.FirebaseStorage.instance;
String url = "";

final _firestore = FirebaseFirestore.instance;
User currentuser;

final _auth = FirebaseAuth.instance;

class ChatScreen extends StatefulWidget {
  static String id = 'chatscreen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final textcontroller = TextEditingController();
  String messagetext;
  String url;
  final _picker = ImagePicker();
  @override
  void initState() {
    super.initState();

    getcurruser();
  }

  void getcurruser() async {
    final user = _auth.currentUser;

    if (user != null) {
      currentuser = user;
    }
  }

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        leading: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 10,
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Hero(
                  tag: '${Provider.of<MainList>(context, listen: false).user}',
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                        Provider.of<MainList>(context, listen: false)
                            .profilepic),
                    radius: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.white,
              ),
              onPressed: () async {
                //Implement logout functionality
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.remove('email');
                await _auth.signOut();

                Navigator.pop(context);
                // _auth.signOut();
                // Navigator.pop(context);
              }),
        ],
        title: Row(
          children: [
            SizedBox(
              width: 20,
            ),
            Text('${Provider.of<MainList>(context, listen: false).firstname}'),
          ],
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: textcontroller,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      onChanged: (value) {
                        //Do something with the user input.
                        messagetext = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      //Implement send functionality.

                      if (messagetext != null) {
                        now = DateTime.now();
                        textcontroller.clear();
                        _firestore.collection('messages').add({
                          'time': now,
                          'text': messagetext,
                          'user': currentuser.email,
                          'reciever':
                              Provider.of<MainList>(context, listen: false)
                                  .user,
                          'imageurl': "",
                          'firstname': currentuser.displayName,
                          'seen': false,
                        });
                        messagetext = null;
                      }
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                  TextButton(
                      onPressed: () async {
                        String random = randomString(10);
                        PickedFile pickedFile =
                            await _picker.getImage(source: ImageSource.camera);
                        if (pickedFile != null) {
                          final File file = File(pickedFile.path);
                          final File croppedFile = await ImageCropper.cropImage(
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
                                  toolbarColor: Colors.lightBlueAccent,
                                  toolbarWidgetColor: Colors.white,
                                  initAspectRatio:
                                      CropAspectRatioPreset.original,
                                  lockAspectRatio: false),
                              iosUiSettings: IOSUiSettings(
                                minimumAspectRatio: 1.0,
                              ));
                          try {
                            await firebase_storage.FirebaseStorage.instance
                                .ref('Images/$random.png')
                                .putFile(croppedFile);
                          } catch (e) {
                            // e.g, e.code == 'canceled'
                          }
                          String downloadURL = await firebase_storage
                              .FirebaseStorage.instance
                              .ref('Images/$random.png')
                              .getDownloadURL();
                          url = downloadURL;

                          _firestore.collection('messages').add({
                            'time': now,
                            'text': "",
                            'user': currentuser.email,
                            'reciever':
                                Provider.of<MainList>(context, listen: false)
                                    .user,
                            'imageurl': url,
                            'firstname': currentuser.displayName,
                            'seen': false,
                          });
                          pickedFile = null;
                        }
                      },
                      child: Icon(Icons.camera)),
                  TextButton(
                      onPressed: () async {
                        String random = randomString(10);
                        PickedFile pickedFile =
                            await _picker.getImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          final File file = File(pickedFile.path);
                          final File croppedFile = await ImageCropper.cropImage(
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
                                  toolbarColor: Colors.lightBlueAccent,
                                  toolbarWidgetColor: Colors.white,
                                  initAspectRatio:
                                      CropAspectRatioPreset.original,
                                  lockAspectRatio: false),
                              iosUiSettings: IOSUiSettings(
                                minimumAspectRatio: 1.0,
                              ));
                          try {
                            await firebase_storage.FirebaseStorage.instance
                                .ref('Images/$random.png')
                                .putFile(croppedFile);
                          } catch (e) {
                            // e.g, e.code == 'canceled'
                          }
                          String downloadURL = await firebase_storage
                              .FirebaseStorage.instance
                              .ref('Images/$random.png')
                              .getDownloadURL();
                          url = downloadURL;

                          _firestore.collection('messages').add({
                            'time': now,
                            'text': "",
                            'user': currentuser.email,
                            'reciever':
                                Provider.of<MainList>(context, listen: false)
                                    .user,
                            'imageurl': url,
                            'firstname': currentuser.displayName,
                            'seen': false,
                          });
                          pickedFile = null;
                        }
                      },
                      child: Icon(Icons.image)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatefulWidget {
  @override
  _MessageStreamState createState() => _MessageStreamState();
}

class _MessageStreamState extends State<MessageStream> {
  // Future<void> downloadFileExample() async {
  //   Directory appDocDir = await getApplicationDocumentsDirectory();
  //   File downloadToFile = File('${appDocDir.path}/download-logo.png');
  //
  //   try {
  //     await firebase_storage.FirebaseStorage.instance
  //         .ref('uploads/logo.png')
  //         .writeToFile(downloadToFile);
  //   } catch (e) {
  //     // e.g, e.code == 'canceled'
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('messages').orderBy('time').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            );
          }
          final messages = snapshot.data.docs.reversed;
          List<Widget> messageBubbles = [];
          for (var message in messages) {
            final messagetext = message.get('text');
            final username = message.get('user');
            final Timestamp time = message.get('time');
            final imageurl = message.get('imageurl');

            if (messagetext != null && messagetext.length != 0) {
              final messageBubble = MessageBubble(
                time: time.toDate().toLocal(),
                messagetext: messagetext,
                isme: username == currentuser.email,
                seen: message.get('seen'),
              );

              if ((message.get('user') == currentuser.email &&
                      message.get('reciever') ==
                          Provider.of<MainList>(context, listen: false).user) ||
                  message.get('user') ==
                          Provider.of<MainList>(context, listen: false).user &&
                      message.get('reciever') == currentuser.email) {
                // if () {
                //   print(message.id);
                //
                // }

                messageBubbles.add(messageBubble);
                if (username != currentuser.email &&
                    message.get('seen') == false) {
                  messageBubbles.add(UnreadMsgs());
                  var k = _firestore.collection('messages');
                  k.doc(message.id).update({
                    'seen': true,
                  });
                }
              }
            } else if (message.get('imageurl') != null &&
                    (message.get('user') == currentuser.email &&
                        message.get('reciever') ==
                            Provider.of<MainList>(context, listen: false)
                                .user) ||
                message.get('imageurl') != null &&
                    (message.get('user') ==
                            Provider.of<MainList>(context, listen: false)
                                .user &&
                        message.get('reciever') == currentuser.email)) {
              messageBubbles.add(Imagebubble(
                isme: username == currentuser.email,
                imageurl: imageurl,
                seen: message.get('seen'),
              ));
              if (username != currentuser.email &&
                  message.get('seen') == false) {
                messageBubbles.add(UnreadMsgs());
                var k = _firestore.collection('messages');
                k.doc(message.id).update({
                  'seen': true,
                });
              }
            }
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              children: messageBubbles,
            ),
          );
        });
  }
}

class Imagebubble extends StatelessWidget {
  Imagebubble({this.isme, this.imageurl, this.seen});
  final String imageurl;
  final bool isme;
  final bool seen;
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment:
              isme ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              height: 500,
              width: 300,
              child: Image.network(
                imageurl,
                fit: BoxFit.fill,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes
                          : null,
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: isme == true
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.done,
                  color: isme == true
                      ? seen == false
                          ? Colors.grey
                          : Colors.lightBlueAccent
                      : Colors.transparent,
                  size: 18,
                ),
                Icon(
                  Icons.done,
                  color: isme == true
                      ? seen == false
                          ? Colors.grey
                          : Colors.lightBlueAccent
                      : Colors.transparent,
                  size: 18,
                ),
              ],
            ),
          ],
        ));
  }
}

class UnreadMsgs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Material(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              elevation: 5,
              color: Colors.grey,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Text(
                  'Unread Messages',
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.time, this.messagetext, this.isme, this.seen});
  final bool isme;
  final messagetext;
  final time;
  final bool seen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isme ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            '${time.toString().substring(0, 16)}',
            style: TextStyle(
              fontSize: 10,
              color: Colors.black54,
            ),
          ),
          Material(
              borderRadius: BorderRadius.only(
                bottomLeft: isme ? Radius.circular(20) : Radius.circular(0),
                topLeft: Radius.circular(20),
                bottomRight: isme ? Radius.circular(0) : Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              elevation: 5,
              color: isme ? Colors.lightBlueAccent : Colors.blue,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Text(
                  '$messagetext',
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
              )),
          Row(
            mainAxisAlignment:
                isme == true ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Icon(
                Icons.done,
                color: isme == true
                    ? seen == false
                        ? Colors.grey
                        : Colors.lightBlueAccent
                    : Colors.transparent,
                size: 18,
              ),
              Icon(
                Icons.done,
                color: isme == true
                    ? seen == false
                        ? Colors.grey
                        : Colors.lightBlueAccent
                    : Colors.transparent,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

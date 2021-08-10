import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Searchuser.dart';
import 'package:flashchat/MainProfileList.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Chatprofiles.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;
User currentuser;
FlutterLocalNotificationsPlugin localNotifications;

class MainChatScreen extends StatefulWidget {
  static String id = 'mainchatscreen';
  @override
  _MainChatScreenState createState() => _MainChatScreenState();
}

class _MainChatScreenState extends State<MainChatScreen> {
  var messagedetails;
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
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              context: context, builder: (context) => Searchcontainer());
        },
        backgroundColor: Colors.lightBlueAccent,
        child: Icon(Icons.search),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(
              top: 50,
              bottom: 20,
              left: 10,
              right: 30,
            ),
            child: Row(
              children: [
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    height: 60.0,
                  ),
                ),
                Text(
                  "Flash chat",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 80,
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, 'userdetails');
                    },
                    child: Icon(
                      Icons.account_box_outlined,
                      color: Colors.white,
                    ))
              ],
            ),
          ),
          ProfileStream(),
        ],
      ),
    );
  }
}

class ProfileStream extends StatefulWidget {
  @override
  _ProfileStreamState createState() => _ProfileStreamState();
}

class _ProfileStreamState extends State<ProfileStream> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var androidInitialize =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    localNotifications = FlutterLocalNotificationsPlugin();
    var initialization = InitializationSettings(android: androidInitialize);
    localNotifications.initialize(initialization,
        onSelectNotification: notificationSelected);
  }

  Future notificationSelected(String payload) async {
    print(payload);
    // Provider.of<MainList>(context, listen: false).changefname(widget.name);
    // Provider.of<MainList>(context, listen: false).changeuser(widget.email);
    // Provider.of<MainList>(context, listen: false).changeurl(url);
    // Navigator.pushNamed(context, ChatScreen.id);
  }

  Future _showNotifications(String title, String body) async {
    var androidDetails = AndroidNotificationDetails('0', 'kaddu', 'paddu');
    await localNotifications.show(
        0, title, body, NotificationDetails(android: androidDetails),
        payload: title);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _firestore.collection('messages').orderBy('time').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            );
          }
          List<Chatprofiles> chatprofilelist =
              Provider.of<MainList>(context, listen: false).list;
          final messages = snapshot.data.docs.reversed;

          for (var message in messages) {
            int n = 1;
            final recievermail = message.get('reciever');
            if (recievermail == currentuser.email ||
                message.get('user') == currentuser.email) {
              for (int i = 0; i < chatprofilelist.length; i++) {
                if (chatprofilelist[i].email == message.get('user')) {
                  n = 0;
                  break;
                }
              }
              if (n == 1) {
                chatprofilelist.add(Chatprofiles(
                  name: "${message.get('firstname')}",
                  email: "${message.get('user')}",
                ));
              }
              if (message.get('seen') == false &&
                  message.get('reciever') == currentuser.email) {
                _showNotifications(
                    message.get('firstname'), message.get('text'));
              }
            }
          }

          return Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20.0),
                  topLeft: Radius.circular(20.0),
                ),
              ),
              child: ListView(
                children: chatprofilelist,
              ),
            ),
          );
        });
  }
}

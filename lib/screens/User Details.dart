import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:slimy_card/slimy_card.dart';
import 'ProfileSettingsBox.dart';

User currentuser;

final _auth = FirebaseAuth.instance;

class UserDetails extends StatefulWidget {
  static String id = 'userdetails';
  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
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
      body: Container(
        color: Colors.white60,
        padding: EdgeInsets.all(30),
        child: ListView(
          children: <Widget>[
            SlimyCard(
              color: Colors.lightBlueAccent,
              width: 400,
              topCardHeight: 400,
              bottomCardHeight: 200,
              borderRadius: 15,
              topCardWidget: Column(
                children: [
                  Text(
                    "USER DETAILS",
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontFamily: 'Pacifico'),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: currentuser.photoURL == null
                            ? NetworkImage(
                                "https://source.unsplash.com/1600x900/?nature,water")
                            : NetworkImage(currentuser.photoURL),
                        radius: 60,
                      ),
                      TextButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    ProfilePicset());
                          },
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                          ))
                    ],
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Text(
                    "${currentuser.displayName.toUpperCase()}",
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontFamily: 'Pacifico'),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "${currentuser.email}",
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontFamily: 'Pacifico'),
                  ),
                ],
              ),
              bottomCardWidget: Column(
                children: [
                  Text(
                    "Made with Love By NAVIDUL",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontFamily: 'Pacifico'),
                  ),
                ],
              ),
              slimeEnabled: true,
            ),
          ],
        ),
      ),
    );
  }
}

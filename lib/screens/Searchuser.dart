import 'package:flashchat/MainProfileList.dart';
import 'package:flutter/material.dart';
import 'package:flashchat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:provider/provider.dart';

final _firestore = FirebaseFirestore.instance;
String username;
bool showspinner = false;

class Searchcontainer extends StatefulWidget {
  @override
  _SearchcontainerState createState() => _SearchcontainerState();
}

class _SearchcontainerState extends State<Searchcontainer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: showspinner,
        child: Container(
          color: Color(0xff757575),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                )),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Search User",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.black,
                  ),
                ),
                TextField(
                  autofocus: true,
                  cursorColor: Colors.black,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black),
                  onChanged: (v) {
                    username = v;
                  },
                  decoration: buildInputDecoration(
                      text: "Enter User email", kcolor: Colors.black),
                ),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      showspinner = true;
                    });
                    var userdetails =
                        await _firestore.collection('userdetails').get();

                    setState(() {
                      showspinner = false;
                    });
                    int i = 0;
                    for (var usermail in userdetails.docs) {
                      if (username == usermail.get('email')) {
                        i = 1;
                        // print("successful ${usermail.get('firstname')}");
                        Provider.of<MainList>(context, listen: false)
                            .addtask("${usermail.get('firstname')}", username);
                        return Alert(
                          context: context,
                          type: AlertType.success,
                          title: "User Found ",
                          desc: "${usermail.get('firstname')}",
                          buttons: [
                            DialogButton(
                              child: Text(
                                "Add to Chat Screen",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              onPressed: () => Navigator.pop(context),
                              width: 220,
                            )
                          ],
                        ).show();
                      }
                    }
                    if (i == 0) {
                      return Alert(
                        context: context,
                        type: AlertType.error,
                        title: "User Not Found ",
                        desc:
                            "The user you searched  is not a user of flashchat kindly tell him/her to join this awesome app.",
                        buttons: [
                          DialogButton(
                            child: Text(
                              "Enjoy",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            onPressed: () => Navigator.pop(context),
                            width: 120,
                          )
                        ],
                      ).show();
                    }

                    Navigator.pop(context);
                  },
                  child: Text("Search User"),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

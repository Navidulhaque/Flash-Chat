import 'package:flutter/material.dart';
import 'package:flashchat/buttons.dart';
import 'package:flashchat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Mainchatscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationScreen extends StatefulWidget {
  static String id = 'registrationscreen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool showspinner = false;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String email;
  String password;
  String firstname;
  String lastname;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showspinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                style: TextStyle(color: Colors.black),
                onChanged: (value) {
                  //Do something with the user input.
                  firstname = value;
                },
                decoration: buildInputDecoration(
                    text: "Enter Your first name", kcolor: Colors.blueAccent),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                style: TextStyle(color: Colors.black),
                onChanged: (value) {
                  //Do something with the user input.
                  lastname = value;
                },
                decoration: buildInputDecoration(
                    text: "Enter Your Last name", kcolor: Colors.blueAccent),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: Colors.black),
                onChanged: (value) {
                  //Do something with the user input.
                  email = value;
                },
                decoration: buildInputDecoration(
                    text: "Enter Your Email", kcolor: Colors.blueAccent),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                style: TextStyle(color: Colors.black),
                cursorColor: Colors.black,
                obscureText: true,
                onChanged: (value) {
                  //Do something with the user input.
                  password = value;
                },
                decoration: buildInputDecoration(
                    text: "Enter Your Password", kcolor: Colors.blueAccent),
              ),
              SizedBox(
                height: 24.0,
              ),
              Buttonwidget(
                buttoncolor: Colors.blueAccent,
                text: 'Register',
                onpressed: () async {
                  setState(() {
                    showspinner = true;
                  });

                  try {
                    final newuser = await _auth.createUserWithEmailAndPassword(
                        email: email, password: password);

                    if (newuser != null) {
                      _firestore.collection('userdetails').add({
                        'firstname': firstname,
                        'lastname': lastname,
                        'userid': newuser.user.uid,
                        'email': email,
                      });
                      newuser.user.updateDisplayName(firstname);
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setString('email', email);
                      Navigator.pushNamed(context, MainChatScreen.id);
                    }
                    setState(() {
                      showspinner = false;
                    });
                  } catch (e) {
                    print(e);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

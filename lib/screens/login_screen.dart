import 'package:flutter/material.dart';
import 'package:flashchat/constants.dart';
import 'package:flashchat/buttons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'Mainchatscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  static String id = 'loginscreen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showspinner = false;
  final _auth = FirebaseAuth.instance;
  String email;
  String password;
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
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: Colors.black),
                onChanged: (value) {
                  //Do something with the user input.
                  email = value;
                },
                decoration: buildInputDecoration(
                    text: "Enter Your Email", kcolor: Colors.grey),
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
                    text: "Enter Your password", kcolor: Colors.grey),
              ),
              SizedBox(
                height: 24.0,
              ),
              Buttonwidget(
                text: "Log In",
                buttoncolor: Colors.grey,
                onpressed: () async {
                  setState(() {
                    showspinner = true;
                  });
                  try {
                    var user = await _auth.signInWithEmailAndPassword(
                        email: email, password: password);
                    if (user != null) {
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

import 'package:flutter/material.dart';
import 'package:flashchat/screens/Chatprofiles.dart';

class MainList extends ChangeNotifier {
  String _username;
  String _firstname;
  String _profileurl;

  String get user {
    return _username;
  }

  String get profilepic {
    return _profileurl;
  }

  String get firstname {
    return _firstname;
  }

  void changeurl(String newurl) {
    _profileurl = newurl;
    notifyListeners();
  }

  void changefname(String firstname) {
    _firstname = firstname;
    notifyListeners();
  }

  void changeuser(String newuser) {
    _username = newuser;
    notifyListeners();
  }

  List<Chatprofiles> _chatprofilelist = [
    Chatprofiles(
      name: "Navidul",
      email: "navidulhaque40it@gmail.com",
    ),
  ];

  List<Chatprofiles> get list {
    return _chatprofilelist;
  }

  void addtask(String title, String mail) {
    for (var k in _chatprofilelist) {
      if (k.email == mail) {
        return;
      }
    }

    _chatprofilelist.add(Chatprofiles(
      name: title,
      email: mail,
    ));
    notifyListeners();
  }
}

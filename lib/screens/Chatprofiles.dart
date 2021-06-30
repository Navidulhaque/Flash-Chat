import 'package:flashchat/MainProfileList.dart';
import 'package:flutter/material.dart';
import 'package:flashchat/screens/chat_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class Chatprofiles extends StatefulWidget {
  Chatprofiles({this.name, this.email});
  final String email;
  final String name;

  @override
  _ChatprofilesState createState() => _ChatprofilesState();
}

class _ChatprofilesState extends State<Chatprofiles> {
  String url = "https://source.unsplash.com/1600x900/?nature,water";
  @override
  void initState() {
    super.initState();
    checkurl();
  }

  void checkurl() async {
    try {
      final String durl = await firebase_storage.FirebaseStorage.instance
          .ref('UserProfilePic/${widget.email}.png')
          .getDownloadURL();
      setState(() {
        url = durl;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        "${widget.name}",
        style: TextStyle(
          color: Colors.black,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text("Click to Chat"),
      leading: GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return ImageDialog(imageurl: url);
              });
          print(url);
        },
        child: Hero(
          tag: '${widget.email}',
          child: CircleAvatar(
            backgroundImage: NetworkImage(url),
            radius: 35,
          ),
        ),
      ),
      onTap: () {
        Provider.of<MainList>(context, listen: false).changefname(widget.name);
        Provider.of<MainList>(context, listen: false).changeuser(widget.email);
        Provider.of<MainList>(context, listen: false).changeurl(url);
        Navigator.pushNamed(context, ChatScreen.id);
      },
    );
  }
}

class ImageDialog extends StatelessWidget {
  ImageDialog({this.imageurl});
  final String imageurl;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))),
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            image: DecorationImage(
                image: NetworkImage(imageurl), fit: BoxFit.cover)),
      ),
    );
  }
}

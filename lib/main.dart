import 'package:flutter/material.dart';
import 'package:flashchat/screens/welcome_screen.dart';
import 'package:flashchat/screens/login_screen.dart';
import 'package:flashchat/screens/registration_screen.dart';
import 'package:flashchat/screens/chat_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flashchat/screens/Mainchatscreen.dart';
import 'package:provider/provider.dart';
import 'MainProfileList.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flashchat/screens/User Details.dart';

var email;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  email = prefs.getString('email');
  return runApp(FlashChat());
}

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MainList(),
      child: MaterialApp(
        theme: ThemeData.light().copyWith(
          textTheme: TextTheme(
            bodyText2: TextStyle(color: Colors.black54),
          ),
        ),
        initialRoute: email == null ? WelcomeScreen.id : MainChatScreen.id,
        routes: {
          WelcomeScreen.id: (context) => WelcomeScreen(),
          LoginScreen.id: (context) => LoginScreen(),
          ChatScreen.id: (context) => ChatScreen(),
          RegistrationScreen.id: (context) => RegistrationScreen(),
          MainChatScreen.id: (context) => MainChatScreen(),
          UserDetails.id: (context) => UserDetails(),
        },
      ),
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:digihydro/mainpages/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'index_screen.dart';
import 'load_screen.dart';

//String? finalEmail;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.getInitialMessage();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var email = prefs.getString('email');
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //runApp(digihydro());
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.green,
    ),
    home: IndexScreen(),
    //home: email == null ? IndexScreen() : dashBoard(),
  ));
}

/*class digihydro extends StatefulWidget {
  @override
  loginScreen createState() => loginScreen();
}

class loginScreen extends State<digihydro> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      //home: email
      home: IndexScreen(),
    );
  }
}*/

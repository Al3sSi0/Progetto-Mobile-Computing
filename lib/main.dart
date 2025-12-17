import 'package:corner/structure.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart';
import 'package:corner/authenticate/authentication.dart';
import 'package:corner/services/auth.dart';


void main() async{
    WidgetsFlutterBinding.ensureInitialized();


    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white
    ));
    runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: AuthService().authStateChanges, 
        builder: (context, snapshot){
          if(snapshot.hasData){
            return Structure();
          }
          else{
            return Authentication();
          }
        }
      ));
  }
}
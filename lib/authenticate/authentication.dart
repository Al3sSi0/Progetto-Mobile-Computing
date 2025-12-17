import 'package:corner/structure.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:corner/services/auth.dart';

class Authentication extends StatefulWidget {
  const Authentication({super.key});

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool isLog = true;

  Future<void> signIn() async{
    try{
      await AuthService().signEmailPass(email: _email.text, password: _password.text);
    }on FirebaseAuthException catch(e){}
  }

  Future<void> createUser() async{
    try{
      await AuthService().createEmailPass(email: _email.text, password: _password.text);
    }on FirebaseAuthException catch(e){}
  }

  Future<void> anon() async{
    try{
      await AuthService().anon();
    }on FirebaseAuthException catch(e){}
  }

  




  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
         gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(255, 181, 211, 183),
              colore_sfondo1,
              colore_sfondo2,
            ]
          )
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 0.1*screenHeight,
                left: 0.1*screenWidth,
                right: 0.1*screenWidth,
                child: Card(
                  elevation: 5, 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), 
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
                      child: TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress, 
                        decoration: const InputDecoration(
                          border: InputBorder.none, 
                          icon: Icon(Icons.email_outlined, color: Colors.grey),
                          hintText: "Inserisci la tua email",
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
              ),
              ),
              Positioned(
                top: 0.2*screenHeight,
                left: 0.1*screenWidth,
                right: 0.1*screenWidth,
                child: Card(
                  elevation: 5, 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), 
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
                      child: TextField(
                        controller: _password,
                        obscureText: true,
                        keyboardType: TextInputType.emailAddress, 
                        decoration: const InputDecoration(
                          border: InputBorder.none, 
                          icon: Icon(Icons.password_outlined, color: Colors.grey),
                          hintText: "Inserisci la tua password",
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
              ),
              ),
              Positioned(
                top: 0.3*screenHeight,
                left: 0.2*screenWidth,
                right: 0.2*screenWidth,
                child: ElevatedButton
                  (onPressed: (){isLog? signIn() : createUser();},
                  
                  style: ElevatedButton.styleFrom(
                    elevation: 15, 
                    shadowColor: Colors.black,), 
                  child: Text(isLog? 'ACCEDI' : 'REGISTRATI',
                  style: TextStyle(
                  fontFamily: 'Instagram Sans',
                  fontWeight: FontWeight.bold,
                  color: colore_barra,
                  letterSpacing: 2.5,
                  ),), 
                  )
              ), 
              Positioned(top: 0.4*screenHeight,
                left: 0.15*screenWidth,
                right: 0,
                child: Text((isLog? 'NON HAI UN ACCOUNT?': 'HAI GIÀ UN ACCOUNT?'), style: TextStyle(
                  fontFamily: 'Instagram Sans',
                  fontWeight: FontWeight.bold,
                  color: colore_barra,
                  letterSpacing: 2,
                  ),),
               ),
             Positioned(top: 0.4*screenHeight,
                left: 0.65*screenWidth,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isLog=!isLog;
                    });
                  },
                  child: Text(isLog? 'REGISTRATI': 'ACCEDI', style: TextStyle(
                  fontFamily: 'Instagram Sans',
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                  letterSpacing: 2,
                  ),
                  ),
                )
          ),
          Positioned(
            top: 0.45*screenHeight,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
              onTap: (){anon();},
              child:Text('ENTRA COME OSPITE', style: TextStyle(
                    fontFamily: 'Instagram Sans',
                    fontWeight: FontWeight.w500,
                    color: const Color.fromARGB(255, 89, 85, 85),
                    letterSpacing: 2,
                    ),
                    ),
                        ),
            ))

          ]
        )
        ),
      )
    );
  }
}
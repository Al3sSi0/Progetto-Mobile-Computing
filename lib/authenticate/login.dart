import 'package:corner/structure.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:corner/authenticate/authentication.dart';
import 'package:corner/services/auth.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  Future<void> signIn() async{
    try{
      await AuthService().signEmailPass(email: _email.text, password: _password.text);
    }on FirebaseAuthException catch(e){}
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: colore_sfondo1,
     
      ),
      child:Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
         gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              const Color.fromARGB(207, 255, 255, 255),
              colore_sfondo1,
            ]
          )
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top:0.05*screenHeight,
              child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: colore_barra,
                  iconSize: 40,
                  onPressed: () {
                     Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => Authentication()),
                          );
                  },
                )),
              Positioned(
                top: 0.1*screenHeight,
                left: 0.2*screenWidth,
                right: 0,
                child: Image.asset('assets/images/login_image.png',
                height: 0.45*screenHeight,
                )),
              Positioned(top: 0.45*screenHeight,
                left: 0.1*screenWidth,
                right: 0.1*screenWidth,
                child: Card(
                  elevation: 5, 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), 
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
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
                top: 0.55*screenHeight,
                left: 0.1*screenWidth,
                right: 0.1*screenWidth,
                child: Card(
                  elevation: 5, 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), 
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
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
                top: 0.67*screenHeight,
                left: 0.25*screenWidth,
                right: 0.25*screenWidth,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colore_barra, 
                    elevation: 15,
                    shadowColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(20)
                  ),
                  onPressed: () {
                    signIn();
                  },
                  child: const Text(
                    'ACCEDI',
                    style: TextStyle(
                    fontFamily: 'Instagram Sans',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                    fontSize: 17
                    ),
                  ),
                ))
            ],
          ))
      ),
    ),
    );
  }
}
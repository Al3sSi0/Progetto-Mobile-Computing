import 'package:corner/authenticate/authentication.dart';
import 'package:corner/authenticate/verifyEmail.dart';
import 'package:corner/services/auth.dart';
import 'package:corner/structure.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
   final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

   Future<void> signUp() async { 
  try {
    await AuthService().createEmailPass(
      email: _email.text.trim(), 
      password: _password.text
    );

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const VerifyEmailScreen()),
      );
    }
  } on FirebaseAuthException catch (e) {
    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Errore: ${e.message}", style: TextStyle(
          color: Colors.black,
          fontSize: 15,
        ),textAlign: TextAlign.center,), 
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),),
      );
    }
  }
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
                    Navigator.pop(context);
                  },
                )),
                Positioned(
                top: 0.08* screenHeight,
                
                child: ShaderMask(
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black, Colors.transparent], 
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.dstIn,
                  child: Opacity(
                    opacity: 1, 
                    child: Image.asset(
                      'assets/images/tonali_corner.png',
                      height: 0.35* screenHeight,
                      width: 0.8* screenWidth,
                      alignment: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
                  

                Positioned(top: 0.35*screenHeight,
                left: 0.1*screenWidth,
                right: 0.1*screenWidth,
                child: Container(
                  height: 0.35*screenHeight,
                  decoration: BoxDecoration(
                    color: colore_barra,
                    borderRadius: BorderRadius.circular(20), 
                    boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3), 
                          spreadRadius: 2,  
                          blurRadius: 10,   
                          offset: const Offset(0, 5),
                        ),
                      ],
                    border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 3,
                        ),
                      ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        SizedBox(height: 0.02*screenHeight),
                        Text('CREA IL TUO ACCOUNT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          letterSpacing: 1,
                          fontFamily: 'Instagram Sans',
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                        SizedBox(height: 0.05*screenHeight),
                        Card(
                          color: const Color.fromARGB(255, 255, 249, 249),
                          elevation: 5, 
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15), 
                            side: BorderSide(
                              color: Color(0xFFE0E0E0),
                            )
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
                                SizedBox(height: 0.02*screenHeight),
                                      Card(
                    color: const Color.fromARGB(255, 255, 249, 249),
                    elevation: 5, 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), 
                      side: BorderSide(
                        color: Color(0xFFE0E0E0),
                      )
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
                      ],

                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0.73*screenHeight,
                left: 0.25*screenWidth,
                right: 0.25*screenWidth,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colore_barra, 
                    elevation: 15,
                    shadowColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                          color: Colors.white, 
                          width: 1.5,            
                        ),
                    ),
                    padding: const EdgeInsets.all(20)
                  ),
                  onPressed: (){
                  if (_email.text.isNotEmpty && _password.text.isNotEmpty) {
                    signUp();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Inserisci prima l'email per resettare la password", style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),textAlign: TextAlign.center,), 
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),),
                    );
                  }
                }, 
                  child: const Text(
                    'REGISTRATI',
                    style: TextStyle(
                    fontFamily: 'Instagram Sans',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 5,
                    fontSize: 17
                    ),
                  ),
                )),
              
               
            ],
          )),
        ),
       )
      );}
}
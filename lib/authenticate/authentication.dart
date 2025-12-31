
import 'login.dart'; 
import 'package:corner/structure.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:corner/services/auth.dart';
import 'package:flutter/services.dart';


class Authentication extends StatefulWidget {
  const Authentication({super.key});

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  
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

  Future<void> signInWithGoogle() async{
    try{
      await AuthService().signInWithGoogle();
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
                top: 0.05*screenHeight,
                left: 0,
                right: 0,
                child: Text('CORNER!',   
                textAlign: TextAlign.center,           
                style: TextStyle(
                fontSize: 45,
                fontFamily: 'Instagram Sans',
                fontWeight: FontWeight.bold,
                color: colore_barra,
                letterSpacing: 2.5,
                              ),
                   ),),
              Positioned(
                top: 0.1*screenHeight,
                left: 0.1*screenWidth,
                right: 0,
                child: Image.asset('assets/images/welcome_image.png',
                height: 0.40*screenHeight,)),
              Positioned(
                top: 0.45 * screenHeight,
                left: 0.1 * screenWidth,
                right: 0.1 * screenWidth,
                child: Card(
                  elevation: 15,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  clipBehavior: Clip.antiAlias, 
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => LoginPage()),
                          );
                    },
                    child:  Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login, color: colore_barra),
                            const SizedBox(width: 10), 
                            Text(
                              'ACCEDI',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 25,
                                fontFamily: 'Instagram Sans',
                                fontWeight: FontWeight.w500,
                                color: colore_barra,
                                letterSpacing: 2.5,
                              ),
                            ),
                          ],
                        ),
                    ),
                    ),
                  ),
                ),
              

             Positioned(
                top: 0.55 * screenHeight,
                left: 0.1 * screenWidth,
                right: 0.1 * screenWidth,
                child: Card(
                  elevation: 15,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  clipBehavior: Clip.antiAlias, 
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => LoginPage()),
                          );
                    },
                    child:  Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.app_registration, color: colore_barra),
                            const SizedBox(width: 10), 
                            Text(
                              'REGISTRATI',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 25,
                                fontFamily: 'Instagram Sans',
                                fontWeight: FontWeight.w500,
                                color: colore_barra,
                                letterSpacing: 2.5,
                              ),
                            ),
                          ],
                        ),
                    ),
                    ),
                  ),
                ),
               Positioned(
                top: 0.68 * screenHeight,
                left: 0.15 * screenWidth,
                right: 0.15 * screenWidth,
                child: Card(
                  color: Colors.blue,
                  elevation: 15,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: (){signInWithGoogle();},
                      child: Padding(
                        padding: const EdgeInsets.all(1),
                        child: Row(
                          mainAxisSize: MainAxisSize.min, 
                          mainAxisAlignment: MainAxisAlignment.center, 
                          children: [
                            Image.asset(
                              'assets/images/logo_google.png',
                              height: 0.08*screenHeight,
                              width: 0.15*screenWidth,
                            ),
                            const SizedBox(width: 12), 
                            Text(
                              'ACCEDI CON GOOGLE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Instagram Sans',
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                letterSpacing: 1.2, 
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                            
                      
                      
          Positioned(
            top: 0.8*screenHeight,
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
            )), 
            Positioned(
              top: 0.798*screenHeight,
              left: 0.2*screenWidth,
              child: Icon(Icons.person, color: const Color.fromARGB(255, 89, 85, 85),))

          ]
        )
        ),
      )
    ));
  }
}
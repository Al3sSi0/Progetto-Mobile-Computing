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

  Future<void> signIn() async {
    try {
      await AuthService().signEmailPass(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Errore: ${e.toString()}",
              style: TextStyle(color: Colors.black, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _resetPassword() async {
    try {
      await AuthService().resetPassword(email: _email.text.trim());

      if (mounted) {
        print("Tentativo di reset per: ${_email.text.trim()}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Email di ripristino inviata! Controlla la tua posta.",
              style: TextStyle(fontSize: 15),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Errore: ${e.toString()}",
              style: TextStyle(color: Colors.black, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(systemNavigationBarColor: colore_sfondo1),
      child: Scaffold(
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
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 0.05 * screenHeight,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: colore_barra,
                    iconSize: 40,
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Authentication(),
                        ), // Sostituisci con il nome esatto della tua classe se diverso
                        (Route<dynamic> route) => false,
                      );
                    },
                  ),
                ),

                Positioned(
                  top: 0.08 * screenHeight,
                  right: 0,
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
                        'assets/images/vardy_corner.png',
                        height: 0.5 * screenHeight,
                        width: 0.6 * screenWidth,
                        alignment: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0.15 * screenHeight,
                  left: 0.05 * screenWidth,
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
                        'assets/images/lewa_corner.png',
                        height: 0.35 * screenHeight,
                        width: 0.4 * screenWidth,
                        alignment: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0.45 * screenHeight,
                  left: 0.1 * screenWidth,
                  right: 0.1 * screenWidth,
                  child: Card(
                    color: const Color.fromARGB(255, 255, 249, 249),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: Color(0xFFE0E0E0)),
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
                  top: 0.55 * screenHeight,
                  left: 0.1 * screenWidth,
                  right: 0.1 * screenWidth,
                  child: Card(
                    color: const Color.fromARGB(255, 255, 249, 249),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        controller: _password,
                        obscureText: true,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          icon: Icon(
                            Icons.password_outlined,
                            color: Colors.grey,
                          ),
                          hintText: "Inserisci la tua password",
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0.67 * screenHeight,
                  left: 0.25 * screenWidth,
                  right: 0.25 * screenWidth,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colore_barra,
                      elevation: 15,
                      shadowColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.white, width: 1.5),
                      ),
                      padding: const EdgeInsets.all(20),
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
                        letterSpacing: 5,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0.78 * screenHeight,
                  left: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      if (_email.text.isNotEmpty) {
                        _resetPassword();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Inserisci prima l'email per resettare la password",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "Password dimenticata?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:corner/home.dart';
import 'package:corner/structure.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  bool canResendEmail = true;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) {
      timer?.cancel();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email verificata con successo!")),
        );
        Home();
      }
    }
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 30));
      if (mounted) setState(() => canResendEmail = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
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
      child:
  Scaffold(
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
                top: 0.2*screenHeight,
                left: 0,
                right: 0,
                child: Icon(Icons.mark_email_read_outlined,
                 size: 120, 
                 color: Colors.blueAccent),),
              Positioned(
                top: 0.35*screenHeight,
                left: 0,
                right: 0,
                child: Text(
              'Quasi fatto!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Instagram Sans'),
            ),),
            Positioned(
              top: 0.45*screenHeight,
              left: 0,
              right: 0,
              child: Text(
              'Controlla la tua posta e clicca sul link di conferma,',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),),
            Positioned(
              top: 0.47*screenHeight,
              left: 0,
              right: 0,
              child: Text('Una volta fatto, verrai reindirizzato automaticamente.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black),)
            ),
            Positioned(
              top: 0.55*screenHeight,
              left: 0.2*screenWidth,
              right: 0.2*screenWidth,
              child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: colore_barra,
                minimumSize: const Size.fromHeight(60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              icon: const Icon(Icons.email, color: Colors.white),
              label: const Text('INVIA DI NUOVO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: canResendEmail ? sendVerificationEmail : null,
            )), 
            Positioned(
              top: 0.65*screenHeight,
              right: 0,
              left: 0,
              child: TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pop(); 
              },
              child: const Text(
                'Annulla e torna al login',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),)

    ])
    ))
    )
    );}}

        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        /*Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mark_email_read_outlined, size: 120, color: Colors.blueAccent),
            const SizedBox(height: 30),
            const Text(
              'Quasi fatto!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Instagram Sans'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Controlla la tua posta e clicca sul link di conferma. Una volta fatto, verrai reindirizzato automaticamente.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 40, width:60),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: colore_barra,
                minimumSize: const Size.fromHeight(60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              icon: const Icon(Icons.email, color: Colors.white),
              label: const Text('INVIA DI NUOVO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: canResendEmail ? sendVerificationEmail : null,
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pop(); 
              },
              child: const Text(
                'Annulla e torna al login',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),),
    );}}*/
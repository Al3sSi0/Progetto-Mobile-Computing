import 'package:corner/flippable_card.dart';
import 'package:flutter/material.dart';
import 'package:corner/structure.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


final List<Map<String, dynamic>> tuttiITrofei = [
  {'id': 'borgo_1', 'title': 'PORTIERONE', 'icon': Icons.holiday_village, 'color': Colors.green, 'obiettivo':"Vinci IL MILIONARIO per tre sfide giornaliere consecutive"},
  {'id': 'vittoria_1', 'title': 'CRISTIANO', 'icon': Icons.emoji_events, 'color': Colors.amber,'obiettivo':'Vinci IL MILIONARIO per tre sfide giornaliere consecutive'},
  {'id': 'veloce_1', 'title': "PALLONE D'ORO", 'icon': Icons.bolt, 'color': Colors.blue, 'obiettivo':'Vinci IL MILIONARIO per tre sfide giornaliere consecutive'},
  {'id': 'esperto_1', 'title': 'MAESTRO', 'icon': Icons.psychology, 'color': Colors.purple, 'obiettivo':'Vinci IL MILIONARIO per tre sfide giornaliere consecutive'},
  {'id': 'costante_1', 'title': 'BANDIERA', 'icon': Icons.calendar_month, 'color': Colors.orange,'obiettivo':'Vinci IL MILIONARIO per tre sfide giornaliere consecutive'},
  {'id': 'social_1', 'title': 'SPECIAL ONE', 'icon': Icons.share, 'color': Colors.pink,'obiettivo':'Vinci IL MILIONARIO per tre sfide giornaliere consecutive'},
];


class PremiPage extends StatefulWidget {
  const PremiPage({super.key});

  @override
  State<PremiPage> createState() => _PremiPageState();
}

class _PremiPageState extends State<PremiPage> {
  @override
  Widget build(BuildContext context) {
        
    final user = FirebaseAuth.instance.currentUser;
double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color.fromARGB(255, 181, 211, 183), colore_sfondo1, colore_sfondo2],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<DocumentSnapshot>(
            // Ascoltiamo il documento dell'utente su Firestore
            stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
            builder: (context, snapshot) {
  if (snapshot.connectionState == ConnectionState.waiting) {
    return const Center(child: CircularProgressIndicator());
  }

 
  final data = snapshot.data?.data() as Map<String, dynamic>?;

  
  List<dynamic> sbloccati = (data != null && data.containsKey('trophies')) 
      ? data['trophies'] 
      : [];

              return GridView.builder(
                padding: const EdgeInsets.all(25),
                gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 0.05*screenWidth,
                  mainAxisSpacing: 0.03*screenHeight,
                ),
                itemCount: tuttiITrofei.length,
                itemBuilder: (context, index) {
                  final trofeo = tuttiITrofei[index];
                 
                  final bool isSbloccato = sbloccati.contains(trofeo['id']);

                  return FlippableCard(
                    // Se è bloccato, potresti voler disabilitare il tocco o mostrare un retro diverso
                    front: _buildCardDesign(
                      trofeo['title'] ??'', 
                      isSbloccato ? trofeo['color'] : Colors.black, 
                      trofeo['icon'],
                      isSbloccato: isSbloccato,
                    ),
                    back: _buildCardDesign(
                      trofeo['obiettivo'].toString() ,
                      Colors.blueGrey, 
                      isSbloccato ? Icons.check_circle : Icons.lock,
                      isSbloccato: isSbloccato,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCardDesign(String text, Color color, IconData icon, {required bool isSbloccato}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)],
        // Effetto "ombra" interna se bloccato
        border: !isSbloccato ? Border.all(color: Colors.white10, width: 2) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Se bloccato, usiamo un'icona grigia o scura
          Icon(
            isSbloccato ? icon : Icons.lock_outline, 
            size: 50, 
            color: isSbloccato ? Colors.white : Colors.white24,
          ),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSbloccato ? Colors.white : Colors.white24,
              fontWeight: FontWeight.bold,
              fontSize: isSbloccato ? 16 : 12,
            ),
          ),
        ],
      ),
    );
  }
}
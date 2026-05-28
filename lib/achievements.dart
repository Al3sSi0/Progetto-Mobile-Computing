import 'package:corner/flippable_card.dart';
import 'package:flutter/material.dart';
import 'package:corner/structure.dart'; // Assicurati di avere i tuoi colori definiti qui
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final List<Map<String, dynamic>> tuttiITrofei = [
  {
    'id': 'vittoria_serieb',
    'title': 'PROMOZIONE',
    'image': 'assets/images/serieb-removebg-preview.png',
    'color': Colors.orange,
    'obiettivo': "Vinci il campionato di Serie B e accedi alla serie A",
  },
  {
    'id': 'vittoria_seriea',
    'title': "CAMPIONE D'ITALIA",
    'image': 'assets/images/scudetto-removebg-preview.png',
    'color': Colors.green,
    'obiettivo': "Vinci lo Scudetto sconfiggendo il boss della Serie A",
  },
  {
    'id': 'vittoria_champions',
    'title': "CAMPIONE D'EUROPA",
    'image': 'assets/images/champions-removebg-preview.png',
    'color': Colors.amber,
    'obiettivo': "Alza al cielo la Champions League battendo il Real Madrid",
  },
  {
    'id': 'maestro_memoria',
    'title': "MENTE D'ACCIAIO", // <-- MANCAVA IL TITOLO!
    'image': 'assets/images/coppaitalia-removebg-preview.png',
    'color': const Color.fromARGB(
      255,
      15,
      54,
      231,
    ), // <-- MANCAVA IL COLORE! (se no va in errore)
    'obiettivo': "Completa con successo il mini-gioco del Memory",
  },
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
            colors: [
              const Color.fromARGB(255, 181, 211, 183),
              colore_sfondo1,
              colore_sfondo2,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
                child: Text(
                  "BACHECA TROFEI",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user?.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final data = snapshot.data?.data() as Map<String, dynamic>?;
                    List<dynamic> sbloccati =
                        (data != null && data.containsKey('trophies'))
                        ? data['trophies']
                        : [];

                    return GridView.builder(
                      padding: const EdgeInsets.all(25),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 0.05 * screenWidth,
                        mainAxisSpacing: 0.03 * screenHeight,
                      ),
                      itemCount: tuttiITrofei.length,
                      itemBuilder: (context, index) {
                        final trofeo = tuttiITrofei[index];
                        final bool isSbloccato = sbloccati.contains(
                          trofeo['id'],
                        );

                        return FlippableCard(
                          front: _buildCardDesign(
                            trofeo['title'] ?? '',
                            isSbloccato ? trofeo['color'] : Colors.black87,
                            imagePath: trofeo['image'], // Passiamo l'immagine!
                            isSbloccato: isSbloccato,
                          ),
                          back: _buildCardDesign(
                            trofeo['obiettivo'].toString(),
                            Colors.blueGrey.shade800,
                            icon: isSbloccato
                                ? Icons.check_circle
                                : Icons.lock, // Passiamo l'icona!
                            isSbloccato: isSbloccato,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Il widget ora accetta o imagePath (per il fronte) o icon (per il retro)
  Widget _buildCardDesign(
    String text,
    Color color, {
    required bool isSbloccato,
    String? imagePath,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: !isSbloccato
            ? Border.all(color: Colors.white24, width: 2)
            : Border.all(color: Colors.white54, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // GESTIONE DELL'ICONA CENTRALE / IMMAGINE
          if (!isSbloccato)
            const Icon(
              Icons.lock_outline,
              size: 50, // Puoi ingrandire anche il lucchetto se vuoi, es. 70
              color: Colors.white24,
            )
          else if (imagePath != null)
            Image.asset(
              imagePath,
              height: 85, // <--- HO INGRANDITO L'IMMAGINE QUI (era 50)
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.emoji_events,
                size: 85, // <--- Ingrandita anche l'icona di emergenza
                color: Colors.white,
              ),
            )
          else if (icon != null)
            Icon(icon, size: 60, color: Colors.white),

          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSbloccato ? Colors.white : Colors.white38,
              fontWeight: FontWeight.bold,
              fontSize: isSbloccato ? 14 : 12,
            ),
          ),
        ],
      ),
    );
  }
}

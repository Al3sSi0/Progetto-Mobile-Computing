import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Aggiunto per i trofei
import 'package:firebase_auth/firebase_auth.dart'; // Aggiunto per i trofei

// ==========================================
// MODELLO DELLA CARTA
// ==========================================
class MemoryCardModel {
  final int id;
  final String logoAsset; // Il path dell'immagine
  bool isFaceUp;
  bool isMatched;

  MemoryCardModel({
    required this.id,
    required this.logoAsset,
    this.isFaceUp = false,
    this.isMatched = false,
  });
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<MemoryCardModel> _cards = [];
  bool _isPlaying = false;
  bool _isProcessing = false;
  int? _firstFlippedIndex;
  int _matchesFound = 0;

  final int _memorizeTimeSeconds = 5;

  @override
  void initState() {
    super.initState();
    _initializeCards();
  }

  Future<void> _sbloccaTrofeo(String idTrofeo) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'trophies': FieldValue.arrayUnion([idTrofeo]),
        }, SetOptions(merge: true));
      } catch (e) {
        print("Errore nel salvataggio del trofeo: $e");
      }
    }
  }

  void _initializeCards() {
    // I TUOI PATH DELLE IMMAGINI QUI (15 loghi per 30 carte totali)
    // Assicurati che i nomi dei file e le estensioni (.png) combacino con i tuoi
    List<String> teamLogos = [
      'assets/images/juve-removebg-preview.png',
      'assets/images/psg-removebg-preview.png',
      'assets/images/city-removebg-preview.png',
      'assets/images/roma-removebg-preview.png',
      'assets/images/realmadrid-removebg-preview.png',
      'assets/images/united-removebg-preview.png',
      'assets/images/arsenal-removebg-preview.png',
      'assets/images/chelsea-removebg-preview.png',
      'assets/images/milan-removebg-preview.png',
      'assets/images/inter-removebg-preview.png',
      'assets/images/bvb-removebg-preview.png',
      'assets/images/bayern-removebg-preview.png',
      'assets/images/barcellona-removebg-preview.png',
      'assets/images/lazio-removebg-preview.png',
      'assets/images/reggiana-removebg-preview.png',
    ];

    List<MemoryCardModel> deck = [];
    int idCounter = 0;

    for (var logoPath in teamLogos) {
      for (int i = 0; i < 2; i++) {
        // Ne crea due per ogni logo
        deck.add(MemoryCardModel(id: idCounter++, logoAsset: logoPath));
      }
    }

    deck.shuffle(Random());
    setState(() {
      _cards = deck;
      _matchesFound = 0;
      _isPlaying = false;
      _firstFlippedIndex = null;
    });
  }

  void _startGame() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isPlaying = true;
      _isProcessing = true;
      for (var card in _cards) {
        card.isFaceUp = true;
      }
    });

    Timer(Duration(seconds: _memorizeTimeSeconds), () {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      setState(() {
        for (var card in _cards) {
          card.isFaceUp = false;
        }
        _isProcessing = false;
      });
    });
  }

  void _onCardTapped(int index) {
    if (_isProcessing ||
        !_isPlaying ||
        _cards[index].isFaceUp ||
        _cards[index].isMatched) {
      return;
    }

    HapticFeedback.lightImpact();
    setState(() {
      _cards[index].isFaceUp = true;
    });

    if (_firstFlippedIndex == null) {
      _firstFlippedIndex = index;
    } else {
      _isProcessing = true;
      _checkForMatch(index);
    }
  }

  void _checkForMatch(int secondIndex) async {
    int firstIndex = _firstFlippedIndex!;

    if (_cards[firstIndex].logoAsset == _cards[secondIndex].logoAsset) {
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _cards[firstIndex].isMatched = true;
        _cards[secondIndex].isMatched = true;
        _matchesFound++;
      });

      if (_matchesFound == _cards.length ~/ 2) {
        _showWinDialog();
      }
    } else {
      HapticFeedback.vibrate();
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() {
          _cards[firstIndex].isFaceUp = false;
          _cards[secondIndex].isFaceUp = false;
        });
      }
    }
    if (_matchesFound == _cards.length ~/ 2) {
      _sbloccaTrofeo(
        'maestro_memoria',
      ); // Chiama la funzione per salvare il trofeo
      _showWinDialog();
    }

    setState(() {
      _firstFlippedIndex = null;
      _isProcessing = false;
    });
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "MEMORIA DI FERRO!",
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            "Hai trovato tutte le coppie e sbloccato il TROFEO di questo minigioco!",
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
              child: const Text(
                "OTTIENI TROFEO",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(systemNavigationBarColor: Colors.black),
      child: Scaffold(
        backgroundColor: Colors.green.shade900,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context, false),
          ),
          title: const Text(
            "SFIDA MEMORY",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            // LA GRIGLIA DI GIOCO 5x6
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 10.0,
              ),
              child: Center(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    return MemoryCardWidget(
                      card: _cards[index],
                      onTap: () => _onCardTapped(index),
                    );
                  },
                ),
              ),
            ),

            // OVERLAY INIZIALE CON IL PULSANTE "INIZIA"
            if (!_isPlaying)
              Container(
                color: Colors.black.withOpacity(0.85),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "30 CARTE",
                        style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "TROVA LE 15 COPPIE",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "Avrai $_memorizeTimeSeconds secondi per\nmemorizzare i loghi.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          backgroundColor: Colors.yellow.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _startGame,
                        child: const Text(
                          "INIZIA ORA",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// WIDGET DELLA CARTA
// ============================================================================
class MemoryCardWidget extends StatelessWidget {
  final MemoryCardModel card;
  final VoidCallback onTap;

  const MemoryCardWidget({super.key, required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
          return AnimatedBuilder(
            animation: rotateAnim,
            child: child,
            builder: (context, widget) {
              final isUnder = (ValueKey(card.isFaceUp) != widget?.key);
              final value = isUnder
                  ? min(rotateAnim.value, pi / 2)
                  : rotateAnim.value;
              return Transform(
                transform: Matrix4.rotationY(value)..setEntry(3, 2, 0.001),
                alignment: Alignment.center,
                child: widget,
              );
            },
          );
        },
        child: card.isFaceUp || card.isMatched ? _buildFront() : _buildBack(),
      ),
    );
  }

  Widget _buildFront() {
    return Container(
      key: const ValueKey(true),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.yellow.shade700, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(1, 1)),
        ],
      ),
      child: Center(
        // Qui carichiamo l'immagine dal percorso specificato
        // Usiamo un padding interno per evitare che l'immagine tocchi i bordi
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Image.asset(
            card.logoAsset,
            fit: BoxFit.contain, // Adatta l'immagine mantenendo le proporzioni
          ),
        ),
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      key: const ValueKey(false),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade600, Colors.green.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white38, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(1, 1)),
        ],
      ),
      child: const Center(
        child: Icon(Icons.sports_soccer, color: Colors.white54, size: 22),
      ),
    );
  }
}

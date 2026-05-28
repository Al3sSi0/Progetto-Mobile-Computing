import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Serve per leggere il file JSON
import 'package:flutter/services.dart'; // Serve per accedere agli assets

class Classifica extends StatefulWidget {
  const Classifica({Key? key}) : super(key: key);

  @override
  State<Classifica> createState() => _ClassificaState();
}

class _ClassificaState extends State<Classifica> {
  int lives = 3;
  final int totalPlayers = 10;
  bool haGiaGiocatoOggi = false;

  // Questa è la tua variabile vuota che aspetta i dati
  List<String> dizionarioGiocatori = [];

  // Nuova funzione per leggere il file locale
  Future<void> _caricaDatasetGiocatori() async {
    try {
      // 1. Legge il file di testo dalla cartella assets
      final String jsonString = await rootBundle.loadString(
        'assets/data/giocatori.json',
      );

      // 2. Lo converte da testo a una vera lista Dart
      final List<dynamic> jsonList = jsonDecode(jsonString);

      // 3. Lo salva nella tua variabile
      setState(() {
        dizionarioGiocatori = jsonList.cast<String>();
      });

      print(
        "✅ Dataset caricato: ${dizionarioGiocatori.length} giocatori trovati!",
      );
    } catch (e) {
      print("❌ Errore nel caricamento del dataset: $e");
    }
  }

  late List<Map<String, dynamic>?> guessedPlayers;
  String titoloGioco = "Caricamento...";

  // Dati di esempio per le risposte corrette
  List<Map<String, dynamic>> correctAnswers = [];

  // Dati di esempio per l'Autocomplete
  List<String> allPlayersDatabase = [];

  bool isLoading = true;
  String? errore;

  @override
  void initState() {
    super.initState();
    _initGame();
    _inizializzaPagina();
  }

  Future<void> _inizializzaPagina() async {
    await _caricaDatasetGiocatori(); // Prima carica i 8000 nomi in mezzo secondo
    await _caricaSfidaDelGiorno(); // Poi va su Firebase a prendere le 10 soluzioni
  }

  Future<void> _salvaVittoriaDelGiorno() async {
    final prefs = await SharedPreferences.getInstance();
    // String oggi = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String oggi = '2026-04-28'; // Usa la tua variabile della data

    // Salviamo una variabile booleana con la data di oggi come chiave
    await prefs.setBool('vittoria_classifica_$oggi', true);
  }

  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2430),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.green, width: 2),
          ),
          title: const Column(
            children: [
              Icon(
                Icons.emoji_events_rounded, // Icona della coppa
                color: Colors.amber,
                size: 50,
              ),
              SizedBox(height: 10),
              Text(
                "HAI VINTO!",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          content: const Text(
            "Hai completato la classifica di oggi.\nTorna domani per una nuova sfida!",
            style: TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context); // Chiude il popup
                Navigator.pop(context); // Torna alla Home/Schermata precedente
              },
              child: const Text(
                "ESCI",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _caricaSfidaDelGiorno() async {
    try {
      // 1. Ottieni la data di oggi come stringa (es: 2023-10-27)
      //String oggi = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String oggi = '2026-04-28';

      // 1. CONTROLLO SHaredPreferences: Ha già vinto oggi?
      final prefs = await SharedPreferences.getInstance();
      bool giaVinto = prefs.getBool('vittoria_classifica_$oggi') ?? false;

      if (giaVinto) {
        setState(() {
          haGiaGiocatoOggi = true;
          isLoading = false;
        });
        return; // Interrompe il caricamento, non fa vedere il gioco
      }

      // 2. Cerca il documento su Firebase
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('daily_classifiche')
          .doc(oggi)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        setState(() {
          // Aggiorna i dati del gioco con quelli di Firebase
          titoloGioco = data['titolo'];

          // Mappiamo le soluzioni corrette
          correctAnswers = List<Map<String, dynamic>>.from(data['soluzioni']);

          // Mappiamo il database per l'autocomplete
          allPlayersDatabase = dizionarioGiocatori;

          // Resetta il gioco per la nuova sfida
          guessedPlayers = List.filled(totalPlayers, null);
          isLoading = false;
        });
      } else {
        setState(() {
          errore = "Nessuna sfida disponibile per oggi!";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errore = "Errore nel caricamento: $e";
        isLoading = false;
      });
    }
  }

  void _initGame() {
    setState(() {
      lives = 3;
      guessedPlayers = List.filled(totalPlayers, null);
    });
  }

  // --- LOGICA GIOCO E CONTROLLO RISPOSTE ---
  // --- LOGICA GIOCO E CONTROLLO RISPOSTE ---
  void _checkAnswer(String input) {
    if (input.trim().isEmpty) return;

    // Cerca se il nome inserito è presente tra le risposte corrette
    int index = correctAnswers.indexWhere(
      (p) => p['name'].toString().toLowerCase() == input.toLowerCase(),
    );

    if (index != -1) {
      // 🟢 CASO 1: IL GIOCATORE È CORRETTO!
      int correctRankIndex = correctAnswers[index]['rank'] - 1;

      if (guessedPlayers[correctRankIndex] != null) {
        // 🟠 GIÀ INSERITO: Mostra messaggio di avviso (non toglie vite)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "GIOCATORE GIÀ INSERITO!",
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.amber.shade800,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 100, left: 20, right: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // 🟢 NUOVO GIOCATORE INDOVINATO: Aggiungilo alla lista
        setState(() {
          guessedPlayers[correctRankIndex] = correctAnswers[index];
        });

        // 🏆 CONTROLLO VITTORIA: Ci sono ancora spazi vuoti (null)?
        bool hasWon = !guessedPlayers.contains(null);
        if (hasWon) {
          _salvaVittoriaDelGiorno(); // Salva in memoria che ha vinto oggi
          _showVictoryDialog(); // Mostra il popup di vittoria
        }
      }
    } else {
      // 🔴 CASO 2: IL GIOCATORE È SBAGLIATO (NON È IN CLASSIFICA)
      setState(() {
        lives--; // Toglie una vita
      });

      // 💀 CONTROLLO SCONFITTA: Vite finite?
      if (lives <= 0) {
        _showGameOverDialog();
      }
    }
  }

  // --- POPUP GAME OVER ---
  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Impedisce di chiuderlo cliccando fuori
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2430),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.redAccent, width: 2),
          ),
          title: const Column(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.redAccent,
                size: 50,
              ),
              SizedBox(height: 10),
              Text(
                "HAI PERSO!",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          content: const Text(
            "Hai esaurito tutte le vite a disposizione.\nPreparati meglio e riprova!",
            style: TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context); // Chiude il popup
                _initGame(); // Resetta le vite e la classifica
              },
              child: const Text(
                "RIPROVA",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D1117),
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    if (errore != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D1117),
        body: Center(
          child: Text(errore!, style: const TextStyle(color: Colors.white)),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Transform.translate(
                      offset: const Offset(-15, 0),
                      child: IconButton(
                        icon: const Icon(
                          Icons.home_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  Text(
                    titoloGioco,
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // --- VITE ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    index < lives ? Icons.favorite : Icons.favorite_border,
                    color: Colors.redAccent,
                    size: 38,
                  ),
                );
              }),
            ),

            const SizedBox(height: 15),

            // --- LISTA 10 POSIZIONI ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: List.generate(totalPlayers, (index) {
                    final player = guessedPlayers[index];
                    final bool isGuessed = player != null;

                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isGuessed
                                ? [
                                    Colors.green.withOpacity(0.9),
                                    Colors.green.withOpacity(0.4),
                                  ]
                                : [
                                    Colors.white.withOpacity(0.1),
                                    Colors.white.withOpacity(0.05),
                                  ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border(
                            left: BorderSide(
                              color: isGuessed
                                  ? Colors.white
                                  : Colors.amber.withOpacity(0.5),
                              width: 4,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            Text(
                              "${index + 1}",
                              style: TextStyle(
                                color: isGuessed ? Colors.white : Colors.amber,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                isGuessed
                                    ? player['name'].toString().toUpperCase()
                                    : "----------",
                                style: TextStyle(
                                  color: isGuessed
                                      ? Colors.white
                                      : Colors.white12,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: isGuessed ? 1 : 4,
                                ),
                              ),
                            ),
                            if (isGuessed)
                              Padding(
                                padding: const EdgeInsets.only(right: 15),
                                child: Text(
                                  player['stat'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Courier',
                                    fontSize: 24, // STATISTICA INGRANDITA
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // --- INPUT AREA CON AUTOCOMPLETE ---
            Container(
              padding: const EdgeInsets.all(20),
              child: Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return allPlayersDatabase.where((String option) {
                    return option.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    );
                  });
                },
                onSelected: (String selection) {
                  _checkAnswer(selection);
                },
                // NUOVO DESIGN SUGGERIMENTI IN ALTO
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    // Traslazione 1: Sposta su la tendina del 100% della sua altezza
                    child: FractionalTranslation(
                      translation: const Offset(0, -1),
                      // Traslazione 2: Sposta su la tendina di altri 65 pixel per scavalcare il TextField
                      child: Transform.translate(
                        offset: const Offset(0, -65),
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            width: MediaQuery.of(context).size.width - 40,
                            constraints: const BoxConstraints(maxHeight: 250),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E2430),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.amber.withOpacity(0.4),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.6),
                                  blurRadius: 15,
                                  offset: const Offset(
                                    0,
                                    -5,
                                  ), // Ombra verso l'alto
                                ),
                              ],
                            ),
                            // reverse: true fa partire la lista dal basso verso l'alto
                            child: ListView.separated(
                              reverse: true,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shrinkWrap: true,
                              itemCount: options.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(
                                    color: Colors.white10,
                                    height: 1,
                                    indent: 15,
                                    endIndent: 15,
                                  ),
                              itemBuilder: (BuildContext context, int index) {
                                final String option = options.elementAt(index);
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    option,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  onTap: () {
                                    onSelected(option);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                fieldViewBuilder:
                    (
                      context,
                      textEditingController,
                      focusNode,
                      onFieldSubmitted,
                    ) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: TextField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                          cursorColor: Colors.amber,
                          decoration: const InputDecoration(
                            hintText: "INSERISCI NOME...",
                            hintStyle: TextStyle(
                              color: Colors.white24,
                              letterSpacing: 2,
                            ),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isEmpty) return;

                            final matches = allPlayersDatabase.where(
                              (option) => option.toLowerCase().contains(
                                value.toLowerCase(),
                              ),
                            );

                            if (matches.isNotEmpty) {
                              _checkAnswer(matches.first);
                            } else {
                              _checkAnswer(value);
                            }

                            textEditingController.clear();
                            focusNode.requestFocus();
                          },
                        ),
                      );
                    },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

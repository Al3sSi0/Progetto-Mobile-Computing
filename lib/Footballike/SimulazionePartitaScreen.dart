import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:corner/Footballike/SquadraStarter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Piccola classe di supporto per tracciare il testo e chi ha fatto l'azione
class AzioneCronaca {
  final String testo;
  final bool diUtente; // true = Sinistra (TU), false = Destra (VENEZIA)

  AzioneCronaca(this.testo, this.diUtente);
}

class SimulazionePartitaScreen extends StatefulWidget {
  final SquadraStarter squadra;

  const SimulazionePartitaScreen({super.key, required this.squadra});

  @override
  State<SimulazionePartitaScreen> createState() =>
      _SimulazionePartitaScreenState();
}

class _SimulazionePartitaScreenState extends State<SimulazionePartitaScreen> {
  // STATISTICHE FISSE DEL VENEZIA (BILANCIATE)
  final int veneziaAtt = 15;
  final int veneziaDef = 15;
  final int veneziaGkp = 15;
  final int veneziaOv = 15;

  int minuto = 0;
  int tuoiGol = 0;
  int golVenezia = 0;
  bool partitaFinita = false;
  bool _popupMostrato = false;

  List<AzioneCronaca> cronacaLive = [
    AzioneCronaca(
      "0' - Fischio d'inizio! Inizia il match decisivo contro il Venezia.",
      true,
    ),
  ];
  Timer? _matchTimer;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _avviaCronometro();
  }

  @override
  void dispose() {
    _matchTimer?.cancel();
    super.dispose();
  }

  void _avviaCronometro() {
    _matchTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      setState(() {
        minuto++;

        if (random.nextInt(100) < 12) {
          _calcolaAzioneSaliente();
        }

        if (minuto >= 90) {
          _matchTimer?.cancel();
          partitaFinita = true;
          _concludiPartita();

          // --- LOGICA DEL POPUP ---
          if (tuoiGol > golVenezia && !_popupMostrato) {
            _popupMostrato = true;
            Future.delayed(const Duration(milliseconds: 500), () {
              _mostraPopupVittoria();
            });
          }
        }
      });
    });
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

  void _calcolaAzioneSaliente() {
    int spintaTua = widget.squadra.overall + random.nextInt(20);
    int spintaVenezia = veneziaOv + random.nextInt(20);

    if (spintaTua > spintaVenezia) {
      // --- ATTACCHI TU ---
      int potenzaTiro = widget.squadra.tiro + random.nextInt(15);
      int forzaParata = veneziaGkp + random.nextInt(15);

      if (potenzaTiro > forzaParata) {
        tuoiGol++;
        cronacaLive.insert(
          0,
          AzioneCronaca(
            "$minuto' - ⚽ GOL! ${widget.squadra.nomeAttaccante} esplode un tiro imparabile!",
            true,
          ),
        );
      } else {
        cronacaLive.insert(
          0,
          AzioneCronaca(
            "$minuto' - ❌ OCCASIONE! ${widget.squadra.nomeAttaccante} fermato da Joronen.",
            true,
          ),
        );
      }
    } else {
      // --- ATTACCA IL VENEZIA ---
      int potenzaTiroVenezia = veneziaAtt + random.nextInt(15);
      int tuaDifesa = widget.squadra.contrasto + random.nextInt(15);

      if (tuaDifesa >= potenzaTiroVenezia) {
        cronacaLive.insert(
          0,
          AzioneCronaca(
            "$minuto' - 🛡️ CHIUSURA! ${widget.squadra.nomeDifensore} ferma Pohjanpalo!",
            false,
          ),
        );
      } else {
        int tuaParata = widget.squadra.parata + random.nextInt(15);
        if (potenzaTiroVenezia > tuaParata) {
          golVenezia++;
          cronacaLive.insert(
            0,
            AzioneCronaca(
              "$minuto' - ⚽ GOL VENEZIA! ${widget.squadra.nomePortiere} non può nulla sul tiro di Pohjanpalo.",
              false,
            ),
          );
        } else {
          cronacaLive.insert(
            0,
            AzioneCronaca(
              "$minuto' - 🧤 MIRACOLO! ${widget.squadra.nomePortiere} nega il gol a Pierini!",
              true, // True perché è un'azione difensiva eroica tua!
            ),
          );
        }
      }
    }
  }

  void _concludiPartita() {
    if (tuoiGol > golVenezia) {
      _sbloccaTrofeo('vittoria_serieb');
      cronacaLive.insert(
        0,
        AzioneCronaca(
          "90' - 🏆 FINITA! Vittoria storica e promozione conquistata!",
          true,
        ),
      );
    } else if (golVenezia > tuoiGol) {
      cronacaLive.insert(
        0,
        AzioneCronaca(
          "90' - 😭 SCONFITTA. Il Venezia festeggia sul campo.",
          false,
        ),
      );
    } else {
      int tuoiRigori =
          widget.squadra.tiro + widget.squadra.parata + random.nextInt(20);
      int rigoriVenezia = veneziaAtt + veneziaGkp + random.nextInt(20);
      if (tuoiRigori >= rigoriVenezia) {
        tuoiGol++;
        _sbloccaTrofeo('vittoria_serieb');
        cronacaLive.insert(
          0,
          AzioneCronaca("RIGORI - 🏆 VITTORIA DRAMMATICA AI RIGORI!", true),
        );
      } else {
        golVenezia++;
        cronacaLive.insert(
          0,
          AzioneCronaca("RIGORI - ❌ SCONFITTA FATALE DAL DISCHETTO.", false),
        );
      }
    }
  }

  // --- FUNZIONE DEL POPUP PULITO CON LA X ---
  void _mostraPopupVittoria() {
    showDialog(
      context: context,
      barrierDismissible: true, // Ora puoi chiuderlo anche cliccando fuori
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          backgroundColor: const Color(0xFFF3E5AB),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "CAMPIONI!",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.orangeAccent,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Image.asset(
                      'assets/images/serieb-removebg-preview.png',
                      height: 150,
                      errorBuilder: (c, e, s) => const Icon(
                        Icons.emoji_events,
                        size: 100,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Sei stato promosso in Serie A!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // IL TASTO X IN ALTO A DESTRA
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.black87,
                    size: 28,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Chiude solo il popup
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool haiVinto = tuoiGol > golVenezia;

    const Color color1 = Color.fromARGB(255, 181, 211, 183);
    const Color color2 = Color.fromARGB(255, 237, 232, 208);
    const Color color3 = Color.fromARGB(255, 184, 181, 164);

    String nomeTuaSquadra = "TU";
    if (widget.squadra.stemmaPath.contains("entella")) {
      nomeTuaSquadra = "ENTELLA";
    } else if (widget.squadra.stemmaPath.contains("pescara")) {
      nomeTuaSquadra = "PESCARA";
    } else if (widget.squadra.stemmaPath.contains("reggiana")) {
      nomeTuaSquadra = "REGGIANA";
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color1, color2, color3],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            child: Column(
              children: [
                // CRONOMETRO E PUNTEGGIO
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.black45, width: 2),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 5),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        partitaFinita ? "FINALE" : "$minuto'",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                if (widget.squadra.stemmaPath.isNotEmpty)
                                  Image.asset(
                                    widget.squadra.stemmaPath,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.contain,
                                    errorBuilder: (c, e, s) => const Icon(
                                      Icons.shield,
                                      size: 40,
                                      color: Colors.black54,
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.shield,
                                    size: 40,
                                    color: Colors.black54,
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  nomeTuaSquadra,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "$tuoiGol",
                                  style: const TextStyle(
                                    fontSize: 44,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              "-",
                              style: TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/images/venezia-removebg-preview.png',
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.contain,
                                  errorBuilder: (c, e, s) => const Icon(
                                    Icons.shield,
                                    size: 40,
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "VENEZIA",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "$golVenezia",
                                  style: const TextStyle(
                                    fontSize: 44,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // LISTA DEGLI EVENTI
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black38),
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: cronacaLive.length,
                      itemBuilder: (context, index) {
                        AzioneCronaca riga = cronacaLive[index];

                        Color coloreTesto = Colors.black87;
                        if (riga.testo.contains("⚽ GOL!"))
                          coloreTesto = Colors.green[800]!;
                        if (riga.testo.contains("⚽ GOL VENEZIA!"))
                          coloreTesto = Colors.red[800]!;
                        if (riga.testo.contains("🏆") ||
                            riga.testo.contains("😭"))
                          coloreTesto = Colors.blue[800]!;

                        return Align(
                          alignment: riga.diUtente
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),
                            decoration: BoxDecoration(
                              color: riga.diUtente
                                  ? Colors.blue.withOpacity(0.15)
                                  : Colors.orange.withOpacity(0.15),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(12),
                                topRight: const Radius.circular(12),
                                bottomLeft: riga.diUtente
                                    ? Radius.zero
                                    : const Radius.circular(12),
                                bottomRight: riga.diUtente
                                    ? const Radius.circular(12)
                                    : Radius.zero,
                              ),
                              border: Border.all(
                                color: riga.diUtente
                                    ? Colors.blue
                                    : Colors.orange,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              riga.testo,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: coloreTesto,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // PULSANTE FINALE (Fisso in basso per avanzare o ritirarsi)
                if (partitaFinita) ...[
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: haiVinto
                          ? Colors.green[700]
                          : Colors.red[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context, haiVinto);
                    },
                    child: Text(
                      haiVinto ? "PROCEDI IN SERIE A" : "RITIRATA...",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:corner/Footballike/SquadraStarter.dart';
import 'package:corner/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:corner/structure.dart'; // Il file che contiene la barra di navigazione

class AzioneCronaca {
  final String testo;
  final bool diUtente;
  AzioneCronaca(this.testo, this.diUtente);
}

class SimulazionePartitaChampionsScreen extends StatefulWidget {
  final SquadraStarter squadra;

  const SimulazionePartitaChampionsScreen({super.key, required this.squadra});

  @override
  State<SimulazionePartitaChampionsScreen> createState() =>
      _SimulazionePartitaChampionsScreenState();
}

class _SimulazionePartitaChampionsScreenState
    extends State<SimulazionePartitaChampionsScreen> {
  // STATISTICHE DEL REAL MADRID (Boss Finale!)
  final int realAtt = 40;
  final int realDef = 40;
  final int realGkp = 40;
  final int realOv = 40;

  int minuto = 0;
  int tuoiGol = 0;
  int golReal = 0;
  bool partitaFinita = false;
  bool _popupMostrato = false;

  List<AzioneCronaca> cronacaLive = [
    AzioneCronaca(
      "0' - Fischio d'inizio! Inizia la finale di Champions League contro il Real Madrid.",
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

          if (tuoiGol > golReal && !_popupMostrato) {
            _popupMostrato = true;
            Future.delayed(const Duration(milliseconds: 500), () {
              _mostraPopupVittoria();
            });
          }
        }
      });
    });
  }

  void _calcolaAzioneSaliente() {
    int spintaTua = widget.squadra.overall + random.nextInt(20);
    int spintaReal = realOv + random.nextInt(20);

    String a = widget.squadra.nomeAttaccante;
    String d = widget.squadra.nomeDifensore;
    String p = widget.squadra.nomePortiere;

    if (spintaTua > spintaReal) {
      int potenzaTiro = widget.squadra.tiro + random.nextInt(15);
      int forzaParata = realGkp + random.nextInt(15);

      if (potenzaTiro > forzaParata) {
        tuoiGol++;
        cronacaLive.insert(
          0,
          AzioneCronaca(
            "$minuto' - ⚽ GOL! $a fulmina Courtois con un tiro PAZZESCO!",
            true,
          ),
        );
      } else {
        cronacaLive.insert(
          0,
          AzioneCronaca(
            "$minuto' - ❌ OCCASIONE! Courtois para il tiro di $a.",
            true,
          ),
        );
      }
    } else {
      int potenzaTiroReal = realAtt + random.nextInt(15);
      int tuaDifesa = widget.squadra.contrasto + random.nextInt(15);

      if (tuaDifesa >= potenzaTiroReal) {
        cronacaLive.insert(
          0,
          AzioneCronaca(
            "$minuto' - 🛡️ CHIUSURA! $d anticipa Vinicius Jr in scivolata!",
            false,
          ),
        );
      } else {
        int tuaParata = widget.squadra.parata + random.nextInt(15);
        if (potenzaTiroReal > tuaParata) {
          golReal++;
          cronacaLive.insert(
            0,
            AzioneCronaca(
              "$minuto' - ⚽ GOL Real Madrid! Mbappè la mette all'angolino, non c'è nulla da fare per $p.",
              false,
            ),
          );
        } else {
          cronacaLive.insert(
            0,
            AzioneCronaca(
              "$minuto' - 🧤 MIRACOLO! $p compie un intervento assurdo su Bellingham!",
              true,
            ),
          );
        }
      }
    }
  }

  void _concludiPartita() {
    if (tuoiGol > golReal) {
      // ---> ECCOLO! SALVIAMO IL TROFEO NEL DATABASE <---
      _sbloccaTrofeo('vittoria_champions');

      cronacaLive.insert(
        0,
        AzioneCronaca("90' - 🏆 FINITA! SEI CAMPIONE D'EUROPA!", true),
      );
    } else if (golReal > tuoiGol) {
      cronacaLive.insert(
        0,
        AzioneCronaca(
          "90' - 😭 SCONFITTA. Il Real Madrid vince la Champions League.",
          false,
        ),
      );
    } else {
      int tuoiRigori =
          widget.squadra.tiro + widget.squadra.parata + random.nextInt(20);
      int rigoriReal = realAtt + realGkp + random.nextInt(20);
      if (tuoiRigori >= rigoriReal) {
        tuoiGol++;

        // ---> SALVIAMO IL TROFEO ANCHE SE VINCI AI RIGORI <---
        _sbloccaTrofeo('vittoria_champions');

        cronacaLive.insert(
          0,
          AzioneCronaca("RIGORI - 🏆 VITTORIA EROICA AI RIGORI!", true),
        );
      } else {
        golReal++;
        cronacaLive.insert(
          0,
          AzioneCronaca("RIGORI - ❌ SCONFITTA DAL DISCHETTO.", false),
        );
      }
    }
  }

  // --- POPUP DELLA VITTORIA IN TEMA CHAMPIONS ---
  void _mostraPopupVittoria() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.amber, width: 2), // Bordo oro
        ),
        backgroundColor: const Color(0xFF0F172A), // Sfondo Blu Notte
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "CAMPIONI D'EUROPA!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.amberAccent, // Testo Oro
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/images/champions-removebg-preview.png',
                    height: 150,
                    errorBuilder: (c, e, s) => const Icon(
                      Icons.emoji_events,
                      size: 120,
                      color: Colors.amber, // Icona di riserva oro
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Hai vinto la Champions League!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // TASTO X
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white70, size: 28),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool haiVinto = tuoiGol > golReal;

    const Color color1 = Color(0xFF0F172A);
    const Color color2 = Color(0xFF1E1B4B);
    const Color color3 = Color(0xFF312E81);

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
                // TABELLONE SCURO STILE NOTTE
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5), // Più scuro
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        partitaFinita ? "FINALE" : "$minuto'",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // TUA SQUADRA
                          Expanded(
                            child: Column(
                              children: [
                                if (widget.squadra.stemmaPath.isNotEmpty)
                                  Image.asset(
                                    widget.squadra.stemmaPath,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.contain,
                                    errorBuilder: (c, e, s) => const Icon(
                                      Icons.shield,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.shield,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  nomeTuaSquadra,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // TRATTINO CENTRALE
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              "-",
                              style: TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.bold,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                          // SQUADRA AVVERSARIA (REAL MADRID)
                          Expanded(
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/images/realmadrid-removebg-preview.png',
                                  width: 55,
                                  height: 55,
                                  fit: BoxFit.contain,
                                  errorBuilder: (c, e, s) => const Icon(
                                    Icons.shield,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Real Madrid",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "$golReal",
                                  style: const TextStyle(
                                    fontSize: 44,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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

                // CRONACA (BOX SCURO)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(
                        0.4,
                      ), // Sfondo cronaca scuro
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: cronacaLive.length,
                      itemBuilder: (context, index) {
                        AzioneCronaca riga = cronacaLive[index];

                        // Colori testo brillanti per lo sfondo scuro
                        Color coloreTesto = Colors.white;
                        if (riga.testo.contains("⚽ GOL!")) {
                          coloreTesto = Colors.greenAccent;
                        }
                        if (riga.testo.contains("⚽ GOL Real Madrid!")) {
                          coloreTesto = Colors.redAccent;
                        }
                        if (riga.testo.contains("🏆") ||
                            riga.testo.contains("😭")) {
                          coloreTesto = Colors.amberAccent;
                        }

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
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            decoration: BoxDecoration(
                              color: riga.diUtente
                                  ? Colors.blue.withOpacity(
                                      0.3,
                                    ) // Blu scuro trasparente
                                  : Colors.white.withOpacity(
                                      0.1,
                                    ), // Grigio semitrasparente
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
                                    ? Colors.blueAccent.withOpacity(0.5)
                                    : Colors.white30,
                                width: 1.0,
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

                if (partitaFinita) ...[
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: haiVinto
                          ? Colors.greenAccent[700]
                          : Colors.redAccent[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      // ---> IL SEGRETO È QUI <---
                      // Invece di HomeScreen(), carica la STRUTTURA che contiene la barra!
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          // Metti qui il nome esatto della classe che si trova in structure.dart!
                          builder: (context) => const Structure(),
                        ),
                        (Route<dynamic> route) =>
                            false, // Distrugge tutte le mappe/partite precedenti
                      );
                    },
                    child: Text(
                      haiVinto ? "TORNA ALLA HOME" : "RITIRATA...",
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

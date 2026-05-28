import 'package:flutter/material.dart';
import 'package:corner/Footballike/SimulazionePartitaChampionsScreen.dart';
import 'package:corner/Footballike/SquadraStarter.dart';
import 'dart:math';
import 'package:corner/home.dart';

enum TipoEventoA {
  partenza,
  attacco,
  difesa,
  parata,
  training,
  amichevole,
  soldi,
  mercato,
  boss,
}

class NodoMappaA {
  final String id;
  final double x;
  final double y;
  TipoEventoA evento;
  final List<String> connessioni;
  String? infoExtra;

  NodoMappaA(
    this.id,
    this.x,
    this.y,
    this.evento,
    this.connessioni, {
    this.infoExtra,
  });
}

class SchermataGiocoChampions extends StatefulWidget {
  final SquadraStarter squadra;

  const SchermataGiocoChampions({super.key, required this.squadra});

  @override
  State<SchermataGiocoChampions> createState() =>
      _SchermataGiocoChampionsState();
}

class _SchermataGiocoChampionsState extends State<SchermataGiocoChampions> {
  late List<NodoMappaA> nodi;
  List<String> percorso = ['start'];
  final double cardWidth = 70.0;
  final double cardHeight = 90.0;

  @override
  void initState() {
    super.initState();
    _generaMappa();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mostraPopupPromozione();
    });
  }

  void _mostraPopupPromozione() {
    setState(() {
      widget.squadra.budget += 5000000;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Text("🏆", style: TextStyle(fontSize: 24)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Benvenuto in Champions League!",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Text(
          "Complimenti per lo Scudetto!\nTi aspetta l'Europa. Hai ricevuto un compenso di 5 milioni da spendere sul mercato!",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade900,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Andiamo a vincerla!"),
          ),
        ],
      ),
    );
  }

  void _generaMappa() {
    final random = Random();

    List<TipoEventoA> eventiLivello1 = [TipoEventoA.soldi, TipoEventoA.mercato];
    eventiLivello1.shuffle(random);

    List<TipoEventoA> eventiRimanenti = [
      TipoEventoA.attacco,
      TipoEventoA.difesa,
      TipoEventoA.parata,
      TipoEventoA.training,
      TipoEventoA.amichevole,
    ];
    List<TipoEventoA> statisticheBase = [
      TipoEventoA.attacco,
      TipoEventoA.difesa,
      TipoEventoA.parata,
    ];
    eventiRimanenti.add(
      statisticheBase[random.nextInt(statisticheBase.length)],
    );
    eventiRimanenti.shuffle(random);

    nodi = [
      NodoMappaA('start', 0.5, 0.05, TipoEventoA.partenza, [
        'lvl1_l',
        'lvl1_r',
      ]),
      NodoMappaA('lvl1_l', 0.30, 0.22, eventiLivello1[0], ['lvl2_l', 'lvl2_c']),
      NodoMappaA('lvl1_r', 0.70, 0.22, eventiLivello1[1], ['lvl2_c', 'lvl2_r']),
      NodoMappaA('lvl2_l', 0.15, 0.42, eventiRimanenti[0], ['lvl3_l']),
      NodoMappaA('lvl2_c', 0.50, 0.42, eventiRimanenti[1], [
        'lvl3_l',
        'lvl3_r',
      ]),
      NodoMappaA('lvl2_r', 0.85, 0.42, eventiRimanenti[2], ['lvl3_r']),
      NodoMappaA('lvl3_l', 0.30, 0.62, eventiRimanenti[3], ['boss_a']),
      NodoMappaA('lvl3_r', 0.70, 0.62, eventiRimanenti[4], ['boss_a']),
      NodoMappaA(
        'boss_a',
        0.5,
        0.88,
        TipoEventoA.boss,
        [],
        infoExtra: 'Real madrid',
      ),
    ];
  }

  void _applicaBonus(NodoMappaA nodo) {
    if (nodo.evento == TipoEventoA.attacco) widget.squadra.tiro += 5;
    if (nodo.evento == TipoEventoA.difesa) widget.squadra.contrasto += 5;
    if (nodo.evento == TipoEventoA.parata) widget.squadra.parata += 5;
    if (nodo.evento == TipoEventoA.training) {
      widget.squadra.tiro += 1;
      widget.squadra.contrasto += 1;
      widget.squadra.parata += 1;
    }
    if (nodo.evento == TipoEventoA.amichevole) {
      widget.squadra.tiro += 2;
      widget.squadra.contrasto += 2;
      widget.squadra.parata += 2;
    }
    if (nodo.evento == TipoEventoA.soldi) widget.squadra.budget += 1000000;
  }

  void _avviaPartitaFinale(NodoMappaA nodoAttuale) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SimulazionePartitaChampionsScreen(squadra: widget.squadra),
      ),
    ).then((haiVinto) {
      // Se hai Vinto
      if (haiVinto == true) {
        setState(() {
          percorso.add(nodoAttuale.id);
          if (nodoAttuale.evento == TipoEventoA.amichevole) {
            _applicaBonus(nodoAttuale);
          }
        });

        // SE HAI BATTUTO IL BOSS FINALE... TORNI ALLA HOME DA QUI!
        if (nodoAttuale.evento == TipoEventoA.boss) {
          Navigator.pushAndRemoveUntil(
            context,
            // Sostituisci HomeScreen() con il vero nome della classe della tua home
            MaterialPageRoute(builder: (context) => const Home()),
            (Route<dynamic> route) => false,
          );
        }
      }
      // Se hai esplicitamente perso (== false, e non null!)
      else if (haiVinto == false) {
        if (nodoAttuale.evento == TipoEventoA.boss) {
          Navigator.pop(context);
        }
      }
    });
  }

  // --- LOGICA DEL MERCATO CHAMPIONS CON NUOVI GIOCATORI ---
  void _mostraMercato(NodoMappaA nodo) {
    final List<Map<String, dynamic>> poolGiocatori = [
      // 10 PIPPE EUROPEE (NO REAL MADRID)
      {"nome": "N. Bendtner", "ruolo": "ATT", "stat": 30, "prezzo": 200000},
      {"nome": "K. Lasagna", "ruolo": "ATT", "stat": 32, "prezzo": 200000},
      {"nome": "A. Cerci", "ruolo": "ATT", "stat": 34, "prezzo": 200000},
      {"nome": "M. Destro", "ruolo": "ATT", "stat": 35, "prezzo": 200000},
      {"nome": "H. Maguire", "ruolo": "DEF", "stat": 30, "prezzo": 200000},
      {"nome": "P. Jones", "ruolo": "DEF", "stat": 32, "prezzo": 200000},
      {"nome": "A. Ranocchia", "ruolo": "DEF", "stat": 34, "prezzo": 200000},
      {"nome": "L. Karius", "ruolo": "GKP", "stat": 25, "prezzo": 200000},
      {"nome": "C. Tatarusanu", "ruolo": "GKP", "stat": 28, "prezzo": 200000},
      {"nome": "A. Mirante", "ruolo": "GKP", "stat": 31, "prezzo": 200000},

      // 7 INTERMEDI EUROPEI (NO REAL MADRID)
      {"nome": "F. Chiesa", "ruolo": "ATT", "stat": 65, "prezzo": 1500000},
      {"nome": "O. Dembélé", "ruolo": "ATT", "stat": 67, "prezzo": 1500000},
      {"nome": "A. Bastoni", "ruolo": "DEF", "stat": 68, "prezzo": 1500000},
      {"nome": "R. Dias", "ruolo": "DEF", "stat": 70, "prezzo": 1500000},
      {"nome": "T. Hernández", "ruolo": "DEF", "stat": 69, "prezzo": 1500000},
      {"nome": "G. Donnarumma", "ruolo": "GKP", "stat": 70, "prezzo": 1500000},
      {"nome": "M. Maignan", "ruolo": "GKP", "stat": 68, "prezzo": 1500000},

      // 3 ICONE EUROPEE (NO REAL MADRID)
      {"nome": "E. Haaland", "ruolo": "ATT", "stat": 96, "prezzo": 5000000},
      {"nome": "L. Yamal", "ruolo": "ATT", "stat": 93, "prezzo": 5000000},
      {"nome": "M. Olise", "ruolo": "ATT", "stat": 91, "prezzo": 5000000},
    ];

    final random = Random();
    List<Map<String, dynamic>> poolMisto = List.from(poolGiocatori)
      ..shuffle(random);
    List<Map<String, dynamic>> proposte = poolMisto.take(3).toList();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            int getStatAttuale(String ruolo) {
              if (ruolo == 'ATT') return widget.squadra.tiro;
              if (ruolo == 'DEF') return widget.squadra.contrasto;
              return widget.squadra.parata;
            }

            Color getColoreRarita(int prezzo) {
              if (prezzo >= 5000000) return Colors.orange.shade500;
              if (prezzo >= 1500000) return Colors.green.shade500;
              return Colors.blueGrey.shade400;
            }

            void effettuaScambio(Map<String, dynamic> giocatore) {
              if (widget.squadra.budget >= giocatore['prezzo']) {
                setState(() {
                  // Scala i soldi
                  widget.squadra.budget -= giocatore['prezzo'] as int;

                  // AGGIORNAMENTO STAT E NOME!
                  if (giocatore['ruolo'] == 'ATT') {
                    widget.squadra.tiro = giocatore['stat'];
                    widget.squadra.nomeAttaccante =
                        giocatore['nome']; // <-- NOME AGGIORNATO
                  }
                  if (giocatore['ruolo'] == 'DEF') {
                    widget.squadra.contrasto = giocatore['stat'];
                    widget.squadra.nomeDifensore =
                        giocatore['nome']; // <-- NOME AGGIORNATO
                  }
                  if (giocatore['ruolo'] == 'GKP') {
                    widget.squadra.parata = giocatore['stat'];
                    widget.squadra.nomePortiere =
                        giocatore['nome']; // <-- NOME AGGIORNATO
                  }

                  percorso.add(nodo.id);
                });
                Navigator.pop(context);
              }
            }

            String budgetStr = widget.squadra.budget >= 1000000
                ? "${(widget.squadra.budget / 1000000).toStringAsFixed(1)}M"
                : "${widget.squadra.budget ~/ 1000}k";

            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "MERCATO",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.blue.shade900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.green.shade700,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "$budgetStr €",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Scegli un solo giocatore per puntare alla Champions.",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            children: proposte.map((giocatore) {
                              final prezzo = giocatore['prezzo'] as int;
                              final stat = giocatore['stat'] as int;
                              final ruolo = giocatore['ruolo'] as String;

                              bool canAfford = widget.squadra.budget >= prezzo;
                              Color coloreCarta = getColoreRarita(prezzo);
                              int statAttuale = getStatAttuale(ruolo);
                              bool isUpgrade = stat > statAttuale;

                              String prezzoStr = prezzo >= 1000000
                                  ? "${(prezzo / 1000000).toStringAsFixed(1)}M"
                                  : "${prezzo ~/ 1000}k";

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      coloreCarta.withOpacity(0.12),
                                      Colors.white,
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: coloreCarta.withOpacity(0.5),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          border: Border.all(
                                            color: coloreCarta,
                                            width: 3,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: coloreCarta.withOpacity(
                                                0.2,
                                              ),
                                              blurRadius: 4,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              stat.toString(),
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w900,
                                                color: coloreCarta,
                                                height: 1.1,
                                              ),
                                            ),
                                            Text(
                                              ruolo,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              giocatore['nome'],
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    "Tua Stat: $statAttuale",
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade700,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 4.0,
                                                        ),
                                                    child: Icon(
                                                      Icons.arrow_forward_ios,
                                                      color:
                                                          Colors.grey.shade400,
                                                      size: 8,
                                                    ),
                                                  ),
                                                  Text(
                                                    stat.toString(),
                                                    style: TextStyle(
                                                      color: isUpgrade
                                                          ? Colors
                                                                .green
                                                                .shade600
                                                          : Colors.red.shade600,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "$prezzoStr €",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: canAfford
                                                  ? Colors.black87
                                                  : Colors.red.shade600,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: canAfford
                                                  ? coloreCarta
                                                  : Colors.grey.shade200,
                                              foregroundColor: canAfford
                                                  ? Colors.white
                                                  : Colors.grey.shade500,
                                              elevation: canAfford ? 2 : 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              minimumSize: Size.zero,
                                            ),
                                            onPressed: canAfford
                                                ? () =>
                                                      effettuaScambio(giocatore)
                                                : null,
                                            child: Text(
                                              canAfford ? "COMPRA" : "BLOCCATO",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            percorso.add(nodo.id);
                          });
                          Navigator.pop(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.close, size: 16),
                            SizedBox(width: 8),
                            Text("Rifiuta offerte e prosegui"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _mostraAiuto() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFF3E5AB),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "GUIDA POWER-UP",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildRigaAiuto(
                      "assets/images/shoot.png",
                      "ATTACCO",
                      "+5 Tiro",
                      fallbackIcon: Icons.sports_soccer,
                    ),
                    _buildRigaAiuto(
                      "assets/images/defender-removebg-preview.png",
                      "DIFESA",
                      "+5 Contrasto",
                      fallbackIcon: Icons.shield,
                    ),
                    _buildRigaAiuto(
                      "assets/images/gloves.png",
                      "PARATA",
                      "+5 Parata",
                      fallbackIcon: Icons.front_hand,
                    ),
                    _buildRigaAiuto(
                      "assets/images/gym.png",
                      "TRAINING",
                      "+1 su tutto",
                      fallbackIcon: Icons.fitness_center,
                    ),
                    _buildRigaAiuto(
                      "assets/images/money.png",
                      "SOLDI",
                      "+1 Milione",
                      fallbackIcon: Icons.monetization_on,
                    ),
                    _buildRigaAiuto(
                      "assets/images/friendly-removebg-preview.png",
                      "MATCH",
                      "50% prob. +2 su tutto",
                      fallbackIcon: Icons.people,
                    ),
                    _buildRigaAiuto(
                      "assets/images/trasfer-removebg-preview.png",
                      "MERCATO",
                      "Scambia giocatori",
                      fallbackIcon: Icons.handshake,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRigaAiuto(
    String img,
    String titolo,
    String desc, {
    IconData fallbackIcon = Icons.star,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Image.asset(
            img,
            width: 30,
            height: 30,
            errorBuilder: (context, error, stackTrace) =>
                Icon(fallbackIcon, size: 30),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titolo, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(desc, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String budgetFormattato = widget.squadra.budget >= 1000000
        ? "${(widget.squadra.budget / 1000000).toStringAsFixed(1)}M"
        : "${widget.squadra.budget ~/ 1000}k";

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // Gradiente Notte Champions League
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF312E81)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                // HEADER STATISTICHE
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    border: Border.all(color: Colors.black, width: 3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (widget.squadra.stemmaPath.isNotEmpty)
                            Image.asset(
                              widget.squadra.stemmaPath,
                              width: 20,
                              height: 20,
                            ),
                          const SizedBox(width: 4),
                          Text(
                            "💰 $budgetFormattato",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "ATT: ${widget.squadra.tiro}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        "DEF: ${widget.squadra.contrasto}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        "GKP: ${widget.squadra.parata}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        "OV: ${widget.squadra.overall}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // MAPPA CON CIELO STELLATO
                Expanded(
                  child: Container(
                    width: double.infinity,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: Colors.black, // Sfondo nero per le stelle
                      border: Border.all(color: Colors.white, width: 4),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            CustomPaint(
                              size: Size(
                                constraints.maxWidth,
                                constraints.maxHeight,
                              ),
                              painter: DisegnatoreCampoCompletoA(),
                            ),
                            CustomPaint(
                              size: Size(
                                constraints.maxWidth,
                                constraints.maxHeight,
                              ),
                              painter: DisegnatoreLineeSolidA(nodi, percorso),
                            ),
                            ...nodi.map((nodo) {
                              double w =
                                  (nodo.evento == TipoEventoA.partenza ||
                                      nodo.evento == TipoEventoA.boss)
                                  ? 82.0
                                  : cardWidth;
                              double h =
                                  (nodo.evento == TipoEventoA.partenza ||
                                      nodo.evento == TipoEventoA.boss)
                                  ? 85.0
                                  : cardHeight;
                              return Positioned(
                                left: (nodo.x * constraints.maxWidth) - (w / 2),
                                top: (nodo.y * constraints.maxHeight) - (h / 2),
                                width: w,
                                height: h,
                                child: _buildNodo(nodo),
                              );
                            }),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: _mostraAiuto,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.question_mark,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
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

  Widget _buildNodo(NodoMappaA nodo) {
    bool isVisitato = percorso.contains(nodo.id);
    bool isDisponibile =
        !isVisitato &&
        nodi
            .firstWhere((n) => n.id == percorso.last)
            .connessioni
            .contains(nodo.id);
    double opacity = (!isVisitato && !isDisponibile) ? 0.3 : 1.0;

    if (nodo.evento == TipoEventoA.partenza) {
      return Opacity(
        opacity: opacity,
        child: _buildGoalLabel(
          "",
          isVisitato,
          isDisponibile,
          immagine: widget.squadra.stemmaPath,
          dimImmagine: 45.0,
        ),
      );
    } else if (nodo.evento == TipoEventoA.boss) {
      return Opacity(
        opacity: opacity,
        child: GestureDetector(
          onTap: () {
            if (isDisponibile) _avviaPartitaFinale(nodo);
          },
          child: _buildGoalLabel(
            "",
            isVisitato,
            isDisponibile,
            immagine: 'assets/images/realmadrid-removebg-preview.png',
            dimImmagine: 55.0,
          ),
        ),
      );
    }

    String label = "";
    Color coloreBase = Colors.white;
    String img = "";
    IconData iconaEmergenza = Icons.broken_image;

    switch (nodo.evento) {
      case TipoEventoA.attacco:
        label = "+5 ATT";
        coloreBase = Colors.amber;
        img = 'assets/images/shoot.png';
        iconaEmergenza = Icons.sports_soccer;
        break;
      case TipoEventoA.difesa:
        label = "+5 DEF";
        coloreBase = Colors.grey;
        img = 'assets/images/defender-removebg-preview.png';
        iconaEmergenza = Icons.shield;
        break;
      case TipoEventoA.parata:
        label = "+5 GKP";
        coloreBase = Colors.blue;
        img = 'assets/images/gloves.png';
        iconaEmergenza = Icons.front_hand;
        break;
      case TipoEventoA.training:
        label = "TRAINING";
        coloreBase = Colors.purpleAccent;
        img = 'assets/images/gym.png';
        iconaEmergenza = Icons.fitness_center;
        break;
      case TipoEventoA.soldi:
        label = "+1 MIL";
        coloreBase = Colors.greenAccent;
        img = 'assets/images/money.png';
        iconaEmergenza = Icons.monetization_on;
        break;
      case TipoEventoA.amichevole:
        label = "MATCH";
        coloreBase = Colors.redAccent;
        img = 'assets/images/friendly-removebg-preview.png';
        iconaEmergenza = Icons.people;
        break;
      case TipoEventoA.mercato:
        label = "MERCATO";
        coloreBase = Colors.orangeAccent;
        img = 'assets/images/trasfer-removebg-preview.png';
        iconaEmergenza = Icons.handshake;
        break;
      default:
        break;
    }

    return Opacity(
      opacity: opacity,
      child: GestureDetector(
        onTap: () {
          if (isDisponibile) {
            if (nodo.evento == TipoEventoA.mercato) {
              _mostraMercato(nodo);
            } else if (nodo.evento == TipoEventoA.amichevole) {
              bool haiVinto = Random().nextBool();
              setState(() {
                percorso.add(nodo.id);
                if (haiVinto) {
                  _applicaBonus(nodo);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Amichevole Vinta! +2 a tutte le statistiche ⚽",
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Amichevole Persa... Nessun bonus ottenuto ❌",
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              });
            } else {
              setState(() {
                percorso.add(nodo.id);
                _applicaBonus(nodo);
              });
            }
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: isVisitato ? Colors.grey[300] : const Color(0xFFFEEBC8),
            border: Border.all(
              color: isDisponibile ? Colors.greenAccent : coloreBase,
              width: isDisponibile ? 4.0 : 3.0,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      img,
                      width: 40,
                      height: 40,
                      errorBuilder: (c, e, s) =>
                          Icon(iconaEmergenza, color: coloreBase, size: 30),
                    ),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: coloreBase,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (isVisitato)
                const Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalLabel(
    String text,
    bool isVisitato,
    bool isDisponibile, {
    String? immagine,
    double dimImmagine = 20.0,
  }) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isVisitato ? Colors.grey[800] : Colors.black87,
        border: Border.all(
          color: isDisponibile ? Colors.greenAccent : Colors.white,
          width: isDisponibile ? 3.0 : 2.0,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (immagine != null)
                Image.asset(
                  immagine,
                  width: dimImmagine,
                  height: dimImmagine,
                  errorBuilder: (c, e, s) =>
                      const Icon(Icons.shield, color: Colors.white),
                ),
            ],
          ),
          if (isVisitato)
            const Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.check, color: Colors.green, size: 16),
              ),
            ),
        ],
      ),
    );
  }
}

class DisegnatoreCampoCompletoA extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. DISEGNO LE STELLE (Uso un seed fisso così non "lampeggiano")
    final random = Random(42);
    final starPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 120; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5;

      // Alcune stelle brillano di più, altre di meno
      starPaint.color = Colors.white.withOpacity(
        random.nextDouble() * 0.5 + 0.3,
      );
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }

    // 2. DISEGNO LE LINEE DEL CAMPO
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.2,
      paint,
    );
    canvas.drawRect(
      Rect.fromLTRB(size.width * 0.2, 0, size.width * 0.8, size.height * 0.12),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTRB(
        size.width * 0.2,
        size.height * 0.88,
        size.width * 0.8,
        size.height,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DisegnatoreLineeSolidA extends CustomPainter {
  final List<NodoMappaA> nodi;
  final List<String> percorso;
  DisegnatoreLineeSolidA(this.nodi, this.percorso);

  @override
  void paint(Canvas canvas, Size size) {
    final paintBase = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    final paintAttiva = Paint()
      ..color = Colors.yellowAccent.withOpacity(0.8)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;
    final mappaNodi = {for (var n in nodi) n.id: n};

    for (var nodo in nodi) {
      final p1 = Offset(nodo.x * size.width, nodo.y * size.height);
      for (var idDest in nodo.connessioni) {
        final nodoDest = mappaNodi[idDest];
        if (nodoDest != null) {
          final p2 = Offset(nodoDest.x * size.width, nodoDest.y * size.height);
          bool isPercorsa =
              percorso.indexOf(nodo.id) != -1 &&
              percorso.indexOf(nodo.id) + 1 < percorso.length &&
              percorso[percorso.indexOf(nodo.id) + 1] == idDest;
          canvas.drawLine(p1, p2, isPercorsa ? paintAttiva : paintBase);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

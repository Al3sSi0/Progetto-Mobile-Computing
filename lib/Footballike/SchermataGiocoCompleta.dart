import 'package:corner/Footballike/SimulazionePartitaScreen.dart';
import 'package:flutter/material.dart';
import 'package:corner/Footballike/SquadraStarter.dart';
import 'dart:math';
import 'package:corner/Footballike/SchermataGiocoSerieA.dart';

// 1. AGGIUNTI I NUOVI EVENTI
enum TipoEvento {
  partenza,
  attacco,
  difesa,
  parata,
  training,
  amichevole,
  soldi,
  boss,
}

class NodoMappaCompleto {
  final String id;
  final double x;
  final double y;
  TipoEvento evento;
  final List<String> connessioni;
  String? infoExtra; // Utile per salvare il nome dell'amichevole

  NodoMappaCompleto(
    this.id,
    this.x,
    this.y,
    this.evento,
    this.connessioni, {
    this.infoExtra,
  });
}

class SchermataGiocoCompleta extends StatefulWidget {
  final SquadraStarter squadra;

  const SchermataGiocoCompleta({super.key, required this.squadra});

  @override
  State<SchermataGiocoCompleta> createState() => _SchermataGiocoCompletaState();
}

class _SchermataGiocoCompletaState extends State<SchermataGiocoCompleta> {
  late List<NodoMappaCompleto> nodi;
  List<String> percorso = ['start'];

  final double cardWidth = 70.0;
  final double cardHeight = 90.0;

  // Per limitare a massimo 2 amichevoli sulla mappa
  int amichevoliGenerate = 0;

  @override
  void initState() {
    super.initState();
    _generaMappaComplessa();
  }

  void _generaMappaComplessa() {
    final random = Random();

    // 1. PREPARIAMO IL LIVELLO 1 (Soldi e Match fissi, ma invertiti a caso)
    List<TipoEvento> eventiLivello1 = [TipoEvento.soldi, TipoEvento.amichevole];
    eventiLivello1.shuffle(
      random,
    ); // Li mischia, così non sai mai su che lato capitano

    // 2. PREPARIAMO IL RESTO DELLA MAPPA (5 Nodi rimanenti)
    // Garantiamo ALMENO uno per tipo delle statistiche e training
    List<TipoEvento> eventiRimanenti = [
      TipoEvento.attacco,
      TipoEvento.difesa,
      TipoEvento.parata,
      TipoEvento.training,
    ];

    // Ci manca 1 evento per arrivare a 5 nodi. Scegliamo una statistica base a caso per riempire.
    List<TipoEvento> statisticheBase = [
      TipoEvento.attacco,
      TipoEvento.difesa,
      TipoEvento.parata,
    ];
    eventiRimanenti.add(
      statisticheBase[random.nextInt(statisticheBase.length)],
    );

    // Mischiamo il "mazzo" dei 5 eventi rimanenti
    eventiRimanenti.shuffle(random);

    // 3. ASSEGNIAMO LE "CARTE" AI NODI
    nodi = [
      // START (y: 0.05)
      NodoMappaCompleto('start', 0.5, 0.05, TipoEvento.partenza, [
        'lvl1_l',
        'lvl1_r',
      ]),

      // LIVELLO 1 (y: 0.22) - Prendono i primi 2 eventi (Soldi e Match)
      NodoMappaCompleto('lvl1_l', 0.30, 0.22, eventiLivello1[0], [
        'lvl2_l',
        'lvl2_c',
      ]),
      NodoMappaCompleto('lvl1_r', 0.70, 0.22, eventiLivello1[1], [
        'lvl2_c',
        'lvl2_r',
      ]),

      // LIVELLO 2 (y: 0.42) - Prendono i primi 3 eventi del mazzo rimanente
      NodoMappaCompleto('lvl2_l', 0.15, 0.42, eventiRimanenti[0], ['lvl3_l']),
      NodoMappaCompleto('lvl2_c', 0.50, 0.42, eventiRimanenti[1], [
        'lvl3_l',
        'lvl3_r',
      ]),
      NodoMappaCompleto('lvl2_r', 0.85, 0.42, eventiRimanenti[2], ['lvl3_r']),

      // LIVELLO 3 (y: 0.62) - Prendono gli ultimi 2 eventi
      NodoMappaCompleto('lvl3_l', 0.30, 0.62, eventiRimanenti[3], ['boss1']),
      NodoMappaCompleto('lvl3_r', 0.70, 0.62, eventiRimanenti[4], ['boss1']),

      // BOSS FINALE (y: 0.88)
      NodoMappaCompleto(
        'boss1',
        0.5,
        0.88,
        TipoEvento.boss,
        [],
        infoExtra: 'Venezia',
      ),
    ];
  }

  void _applicaBonus(NodoMappaCompleto nodo) {
    if (nodo.evento == TipoEvento.attacco) widget.squadra.tiro += 5;
    if (nodo.evento == TipoEvento.difesa) widget.squadra.contrasto += 5;
    if (nodo.evento == TipoEvento.parata) widget.squadra.parata += 5;

    // NUOVI BONUS
    if (nodo.evento == TipoEvento.training) {
      widget.squadra.tiro += 1;
      widget.squadra.contrasto += 1;
      widget.squadra.parata += 1;
    }
    if (nodo.evento == TipoEvento.amichevole) {
      widget.squadra.tiro += 2;
      widget.squadra.contrasto += 2;
      widget.squadra.parata += 2;
    }
    if (nodo.evento == TipoEvento.soldi) {
      widget.squadra.budget += 1000000; // +1 Milione
    }
  }

  void _avviaPartitaFinale(NodoMappaCompleto nodoAttuale) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SimulazionePartitaScreen(squadra: widget.squadra),
      ),
    ).then((haiVinto) {
      if (haiVinto == true) {
        setState(() {
          percorso.add(nodoAttuale.id);
          if (nodoAttuale.evento == TipoEvento.amichevole) {
            _applicaBonus(nodoAttuale);
          }
        });

        // SE HAI BATTUTO IL BOSS, VAI IN SERIE A!
        if (nodoAttuale.evento == TipoEvento.boss) {
          Navigator.pushReplacement(
            // pushReplacement chiude la Serie B e apre la Serie A
            context,
            MaterialPageRoute(
              // Passiamo la "stessa" squadra, che ora ha tutte le stat pompate!
              builder: (context) =>
                  SchermataGiocoSerieA(squadra: widget.squadra),
            ),
          );
        }
      } else {
        // Se perdi col Boss, torni indietro (alla scelta squadre)
        if (nodoAttuale.evento == TipoEvento.boss) {
          Navigator.pop(context);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color color1 = Color.fromARGB(255, 181, 211, 183);
    const Color color2 = Color.fromARGB(255, 237, 232, 208);
    const Color color3 = Color.fromARGB(255, 184, 181, 164);

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
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                _buildHeaderStats(),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: const Color(0xFF166534), // Verde campo
                      border: Border.all(color: Colors.white, width: 4),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(color: Colors.black45, blurRadius: 10),
                      ],
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
                              painter: DisegnatoreCampoCompleto(),
                            ),
                            CustomPaint(
                              size: Size(
                                constraints.maxWidth,
                                constraints.maxHeight,
                              ),
                              painter: DisegnatoreLineeSolid(nodi, percorso),
                            ),
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
                            ...nodi.map((nodo) {
                              double widthAttuale = cardWidth;
                              double heightAttuale = cardHeight;

                              if (nodo.evento == TipoEvento.partenza ||
                                  nodo.evento == TipoEvento.boss) {
                                widthAttuale = 82.0;
                                heightAttuale = 85.0;
                              }

                              return Positioned(
                                left:
                                    (nodo.x * constraints.maxWidth) -
                                    (widthAttuale / 2),
                                top:
                                    (nodo.y * constraints.maxHeight) -
                                    (heightAttuale / 2),
                                width: widthAttuale,
                                height: heightAttuale,
                                child: _buildNodo(nodo),
                              );
                            }),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "GUIDA POWER-UP",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _buildRigaAiuto(
                    "assets/images/shoot.png",
                    "ATTACCO",
                    "+5 Tiro",
                  ),
                  _buildRigaAiuto(
                    "assets/images/defender-removebg-preview.png",
                    "DIFESA",
                    "+5 Contrasto",
                  ),
                  _buildRigaAiuto(
                    "assets/images/gloves.png",
                    "PARATA",
                    "+5 Parata",
                  ),
                  _buildRigaAiuto(
                    "assets/images/gym.png",
                    "TRAINING",
                    "+1 su tutto",
                  ),
                  _buildRigaAiuto(
                    "assets/images/money.png",
                    "SOLDI",
                    "+1 Milione",
                  ),
                  _buildRigaAiuto(
                    "assets/images/friendly-removebg-preview.png",
                    "MATCH",
                    "50% prob. +2 su tutto",
                  ),
                ],
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

  Widget _buildRigaAiuto(String img, String titolo, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Image.asset(img, width: 30, height: 30),
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

  Widget _buildHeaderStats() {
    // Calcola il budget in formato bello (es. 1.8M o 800k)
    String budgetFormattato = "";
    if (widget.squadra.budget >= 1000000) {
      budgetFormattato =
          "${(widget.squadra.budget / 1000000).toStringAsFixed(1)}M";
    } else {
      budgetFormattato = "${widget.squadra.budget ~/ 1000}k";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5AB),
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
                  errorBuilder: (c, e, s) => const Icon(Icons.shield, size: 20),
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(
            "DEF: ${widget.squadra.contrasto}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(
            "GKP: ${widget.squadra.parata}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
    );
  }

  Widget _buildNodo(NodoMappaCompleto nodo) {
    String nodoAttualeId = percorso.last;
    NodoMappaCompleto nodoAttualeObj = nodi.firstWhere(
      (n) => n.id == nodoAttualeId,
    );

    bool isVisitato = percorso.contains(nodo.id);
    bool isDisponibile =
        !isVisitato && nodoAttualeObj.connessioni.contains(nodo.id);
    bool isBloccato = !isVisitato && !isDisponibile;

    double opacity = isBloccato ? 0.3 : 1.0;

    // --- START E BOSS ---
    if (nodo.evento == TipoEvento.partenza) {
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
    } else if (nodo.evento == TipoEvento.boss) {
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
            immagine: 'assets/images/venezia-removebg-preview.png',
            dimImmagine: 45.0,
          ),
        ),
      );
    }

    // ECCO LA SOLUZIONE: Inizializziamo subito le variabili per evitare l'errore rosso!
    String label = "";
    Color coloreBase = Colors.white;
    String percorsoImmagine = "";

    // --- I NUOVI POWERUP ---
    switch (nodo.evento) {
      case TipoEvento.attacco:
        label = "+5 ATT";
        coloreBase = Colors.amber;
        percorsoImmagine = 'assets/images/shoot.png';
        break;
      case TipoEvento.difesa:
        label = "+5 DEF";
        coloreBase = Colors.grey;
        percorsoImmagine = 'assets/images/defender-removebg-preview.png';
        break;
      case TipoEvento.parata:
        label = "+5 GKP";
        coloreBase = Colors.blue;
        percorsoImmagine = 'assets/images/gloves.png';
        break;
      case TipoEvento.training:
        label = "TRAINING";
        coloreBase = Colors.purpleAccent;
        percorsoImmagine = 'assets/images/gym.png';
        break;
      case TipoEvento.soldi:
        label = "+1 MIL";
        coloreBase = Colors.greenAccent;
        percorsoImmagine = 'assets/images/money.png';
        break;
      case TipoEvento.amichevole:
        label = "MATCH";
        coloreBase = Colors.redAccent;
        percorsoImmagine = 'assets/images/friendly-removebg-preview.png';
        break;
      default:
        break;
    }

    Color borderColor = isDisponibile ? Colors.greenAccent : coloreBase;

    return Opacity(
      opacity: opacity,
      child: GestureDetector(
        onTap: () {
          if (isDisponibile) {
            // --- GESTIONE AMICHEVOLE (50% DI POSSIBILITÀ) ---
            if (nodo.evento == TipoEvento.amichevole) {
              bool haiVinto = Random().nextBool(); // 50% true, 50% false

              setState(() {
                percorso.add(nodo.id);
                if (haiVinto) {
                  _applicaBonus(
                    nodo,
                  ); // Dà il +2 a tutto (già configurato in _applicaBonus)
                }
              });

              if (haiVinto) {
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
            }
            // --- GESTIONE ALTRI POWER-UP (Vengono presi subito al 100%) ---
            else {
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
              color: borderColor,
              width: isDisponibile ? 4.0 : 3.0,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: isDisponibile
                ? [
                    BoxShadow(
                      color: Colors.greenAccent.withOpacity(0.6),
                      blurRadius: 8,
                    ),
                  ]
                : [],
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      percorsoImmagine,
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                      cacheWidth: 150,
                      errorBuilder: (c, e, s) =>
                          Icon(Icons.broken_image, color: coloreBase, size: 30),
                    ),
                    const SizedBox(height: 4),
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
        boxShadow: isDisponibile
            ? [
                BoxShadow(
                  color: Colors.greenAccent.withOpacity(0.6),
                  blurRadius: 8,
                ),
              ]
            : [],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (immagine != null && immagine.isNotEmpty) ...[
                Image.asset(
                  immagine,
                  width: dimImmagine,
                  height: dimImmagine,
                  fit: BoxFit.contain,
                  cacheWidth: 150,
                  errorBuilder: (c, e, s) => Icon(
                    Icons.shield,
                    color: Colors.white,
                    size: dimImmagine * 0.8,
                  ),
                ),
                if (text.isNotEmpty) const SizedBox(width: 6),
              ],
              if (text.isNotEmpty)
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
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

// ... I DUE DISEGNATORI DEL CAMPO (DisegnatoreCampoCompleto e DisegnatoreLineeSolid) RIMANGONO IDENTICI ...
class DisegnatoreCampoCompleto extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final double width = size.width;
    final double height = size.height;

    canvas.drawLine(Offset(0, height / 2), Offset(width, height / 2), paint);
    canvas.drawCircle(Offset(width / 2, height / 2), width * 0.2, paint);
    canvas.drawRect(
      Rect.fromLTRB(width * 0.2, 0, width * 0.8, height * 0.12),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTRB(width * 0.2, height * 0.88, width * 0.8, height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DisegnatoreLineeSolid extends CustomPainter {
  final List<NodoMappaCompleto> nodi;
  final List<String> percorso;
  DisegnatoreLineeSolid(this.nodi, this.percorso);

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
      final puntoPartenza = Offset(nodo.x * size.width, nodo.y * size.height);
      for (var idDestinazione in nodo.connessioni) {
        final nodoDestinazione = mappaNodi[idDestinazione];
        if (nodoDestinazione != null) {
          final puntoArrivo = Offset(
            nodoDestinazione.x * size.width,
            nodoDestinazione.y * size.height,
          );
          bool isLineaPercorsa = false;
          int indexPartenza = percorso.indexOf(nodo.id);
          if (indexPartenza != -1 && indexPartenza + 1 < percorso.length) {
            if (percorso[indexPartenza + 1] == idDestinazione) {
              isLineaPercorsa = true;
            }
          }
          canvas.drawLine(
            puntoPartenza,
            puntoArrivo,
            isLineaPercorsa ? paintAttiva : paintBase,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

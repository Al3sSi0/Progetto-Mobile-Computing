import 'package:corner/Footballike/SchermataGiocoCompleta.dart';
import 'package:flutter/material.dart';
import 'package:corner/Footballike/SquadraStarter.dart';

// Una piccola classe di supporto per collegare i dati estetici (nomi, budget)
// alle statistiche reali del gioco (SquadraStarter)
class InfoSquadra {
  final String nomeSquadra;
  final String budget;
  final String nomeAttaccante;
  final String nomeDifensore;
  final String nomePortiere;
  final SquadraStarter starter;
  final String stemmaPath;

  InfoSquadra({
    required this.nomeSquadra,
    required this.budget,
    required this.nomeAttaccante,
    required this.nomeDifensore,
    required this.nomePortiere,
    required this.stemmaPath,
    required this.starter,
  });
}

class Classifica extends StatefulWidget {
  const Classifica({super.key});

  @override
  State<Classifica> createState() => _ClassificaState();
}

class _ClassificaState extends State<Classifica> {
  // Lista prefissata delle 3 squadre
  late List<InfoSquadra> squadreScelta;

  @override
  void initState() {
    super.initState();

    squadreScelta = [
      InfoSquadra(
        nomeSquadra: "VIRTUS ENTELLA",
        stemmaPath: 'assets/images/entella-removebg-preview.png',
        budget: "800k",
        nomeAttaccante: "Santini",
        nomeDifensore: "Chiosa",
        nomePortiere: "De Lucia",
        starter: SquadraStarter(
          tiro: 6,
          contrasto: 6,
          parata: 6,
          stemmaPath: 'assets/images/entella-removebg-preview.png',
          budget: 800000,
          nomeAttaccante: "Santini",
          nomeDifensore: "Chiosa",
          nomePortiere: "De Lucia",
        ),
      ),
      InfoSquadra(
        nomeSquadra: "PESCARA",
        stemmaPath: 'assets/images/pescara-removebg-preview.png',
        budget: "900k",
        nomeAttaccante: "Cuppone",
        nomeDifensore: "Brosco",
        nomePortiere: "Plizzari",
        starter: SquadraStarter(
          tiro: 7,
          contrasto: 6,
          parata: 7,
          stemmaPath: 'assets/images/pescara-removebg-preview.png',
          budget: 900000,
          nomeAttaccante: "Cuppone",
          nomeDifensore: "Brosco",
          nomePortiere: "Plizzari",
        ),
      ),
      InfoSquadra(
        nomeSquadra: "REGGIANA",
        stemmaPath: 'assets/images/reggiana-removebg-preview.png',
        budget: "1M",
        nomeAttaccante: "Pettinari",
        nomeDifensore: "Rozzio",
        nomePortiere: "Bardi",
        starter: SquadraStarter(
          tiro: 30,
          contrasto: 30,
          parata: 30,
          stemmaPath: 'assets/images/reggiana-removebg-preview.png',
          budget: 1000000,
          nomeAttaccante: "Pettinari",
          nomeDifensore: "Rozzio",
          nomePortiere: "Bardi",
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 181, 211, 183),
              Color.fromARGB(255, 237, 232, 208),
              Color.fromARGB(255, 184, 181, 164),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: squadreScelta.map((info) {
                        return _buildPannelloSquadra(info);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundColor: Colors.black26,
            child: IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Text(
            "SCEGLI IL TUO TEAM",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
              shadows: [
                Shadow(
                  color: Colors.black45,
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildPannelloSquadra(InfoSquadra info) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5AB),
        border: Border.all(color: Colors.black, width: 3),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black38, offset: Offset(4, 4)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              // Passiamo SOLO la classe SquadraStarter alla mappa, come prima!
              builder: (context) =>
                  SchermataGiocoCompleta(squadra: info.starter),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // RIGA IN ALTO: NOME SQUADRA E BUDGET
              Row(
                children: [
                  // --- IL LOGO DELLA SQUADRA ---
                  Image.asset(
                    info.stemmaPath,
                    width: 35,
                    height: 35,
                    fit: BoxFit.contain,
                    // Se l'immagine non viene trovata, mostra uno scudo di default
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.shield,
                      size: 35,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 10),

                  // --- NOME SQUADRA ---
                  Expanded(
                    child: Text(
                      info.nomeSquadra,
                      style: const TextStyle(
                        fontSize:
                            20, // Leggermente rimpicciolito per far spazio al logo
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                      overflow: TextOverflow
                          .ellipsis, // Se è troppo lungo mette i puntini...
                    ),
                  ),

                  // --- BUDGET ---
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[800],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      "💰 ${info.budget}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.black26, thickness: 2, height: 25),

              // I 3 GIOCATORI DELLA ROSA
              _buildRigaGiocatore(
                "Attaccante",
                info.nomeAttaccante,
                "Tiro",
                info.starter.tiro,
                Colors.red[800]!,
              ),
              const SizedBox(height: 8),
              _buildRigaGiocatore(
                "Difensore",
                info.nomeDifensore,
                "Contrasto",
                info.starter.contrasto,
                Colors.blue[800]!,
              ),
              const SizedBox(height: 8),
              _buildRigaGiocatore(
                "Portiere",
                info.nomePortiere,
                "Parata",
                info.starter.parata,
                Colors.orange[800]!,
              ),

              const SizedBox(height: 12),

              // OVERALL CENTRATO IN BASSO
              Center(
                child: Text(
                  "OVERALL TOTALE: ${info.starter.overall}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget di supporto per disegnare le righe dei giocatori in modo elegante
  Widget _buildRigaGiocatore(
    String ruolo,
    String nome,
    String statNome,
    int statVal,
    Color statColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ruolo.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                nome,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                statNome,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                statVal.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: statColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

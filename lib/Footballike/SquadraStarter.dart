class SquadraStarter {
  int tiro;
  int contrasto;
  int parata;
  String stemmaPath;
  int budget;
  // Aggiungi queste 3 righe:
  String nomeAttaccante;
  String nomeDifensore;
  String nomePortiere;

  SquadraStarter({
    required this.tiro,
    required this.contrasto,
    required this.parata,
    required this.stemmaPath,
    required this.budget,
    required this.nomeAttaccante, // Aggiungi
    required this.nomeDifensore, // Aggiungi
    required this.nomePortiere, // Aggiungi
  });

  int get overall => (tiro + contrasto + parata) ~/ 3;
}

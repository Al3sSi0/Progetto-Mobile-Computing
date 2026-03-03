import 'package:corner/structure.dart';
import 'package:corner/main.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:corner/services/auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isUploading = false;
  bool _notificheAttive = true;
  File? _imageFile; // Variabile per tenere l'immagine selezionata
  final ImagePicker _picker = ImagePicker();
  String? _profileImageUrl; // URL dell'immagine attuale (se esiste)

  // Funzione per selezionare l'immagine
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // Comprime leggermente per velocizzare il caricamento
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        // Resettiamo l'URL di rete per dare priorità all'anteprima locale
        _profileImageUrl = null;
      });
    }
  }

  Future<void> signOut() async {
    await AuthService().signOut();
  }

  void _mostraNotificaTop(BuildContext context) {
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(
              milliseconds: 500,
            ), // Durata della dissolvenza
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value, // Effetto dissolvenza
                child: Transform.translate(
                  offset: Offset(
                    0,
                    (1 - value) * -20,
                  ), // Piccolo movimento dall'alto verso il basso
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(color: Colors.green, width: 1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                  SizedBox(width: 15),
                  Text(
                    "Notifiche attivate!",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Inserisce la notifica nello schermo
    Overlay.of(context).insert(overlayEntry);

    // La fa sparire automaticamente dopo 3 secondi
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  // 2. Funzione per CARICARE l'immagine su Firebase Storage
  Future<void> _uploadAndUpdateProfile() async {
    if (_imageFile == null) return;

    // Inizia il caricamento visivo
    setState(() {
      _isUploading = true;
    });

    try {
      // DEFINISCI IL PERCORSO: Usa un ID utente statico o dinamico
      // (es: FirebaseAuth.instance.currentUser!.uid)
      // Qui usiamo un ID statico per test.
      String userId = "id_utente_esempio";
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('user_profiles')
          .child('$userId.jpg'); // Sovrascrive se il nome è uguale

      // Esegui il caricamento fisico
      await storageRef.putFile(_imageFile!);

      // Ottieni l'URL pubblico appena generato
      String downloadUrl = await storageRef.getDownloadURL();

      // Fine del caricamento e aggiornamento stato
      setState(() {
        _profileImageUrl = downloadUrl; // Mostra l'immagine di rete
        _imageFile = null; // Rimuove il file locale
        _isUploading = false; // Nasconde il caricamento
      });

      // Feedback all'utente
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profilo aggiornato con successo!")),
      );
    } catch (e) {
      // Gestione errori
      setState(() {
        _isUploading = false;
      });
      print("Errore durante il caricamento: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Errore: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Profilo Utente",
          style: TextStyle(
            fontFamily: 'Instagram Sans',
            color: colore_barra,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
            mainAxisAlignment: MainAxisAlignment.start, // In alto al centro
            children: [
              const SizedBox(height: 40), // Spazio dall'appbar
              Stack(
                alignment: Alignment.center, // Centra gli elementi dello stack
                children: [
                  // 1. Il cerchio con l'immagine (o l'icona)
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!) as ImageProvider
                        : (_profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!)
                              : null),
                    child: (_imageFile == null && _profileImageUrl == null)
                        ? const Icon(Icons.person, size: 70, color: Colors.grey)
                        : null,
                  ),

                  // 2. INDICATORE DI CARICAMENTO (sopra il cerchio)
                  if (_isUploading)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5), // Sfondo scuro
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    ),

                  // 3. Icona per modificare (posizionata in basso a destra del cerchio)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      child: IconButton(
                        onPressed: _isUploading
                            ? null
                            : _pickImage, // Disabilita se carica
                        icon: const Icon(Icons.add_a_photo, color: Colors.blue),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 10,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SwitchListTile(
                    title: const Text(
                      "Notifiche",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    secondary: Icon(
                      _notificheAttive
                          ? Icons.notifications_active
                          : Icons.notifications_off,
                      color: _notificheAttive
                          ? Colors.orangeAccent
                          : Colors.grey,
                    ),
                    value: _notificheAttive,
                    onChanged: (bool value) {
                      setState(() {
                        _notificheAttive = value;
                      });

                      if (value == true) {
                        // Chiamiamo la nostra nuova funzione!
                        _mostraNotificaTop(context);
                      }
                    },
                  ),
                ),
              ),
              // 4. TASTO SALVA (compare solo se c'è una nuova foto e non sta caricando)
              if (_imageFile != null && !_isUploading)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: ElevatedButton.icon(
                    onPressed: _uploadAndUpdateProfile,
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: const Text("Salva nuova foto"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),

              // Mostra un caricamento testuale se preferisci
              if (_isUploading)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    "Caricamento in corso...",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              const SizedBox(height: 15), // Spazio tra i due switch
              // 5. IL NUOVO BOTTONE DELLA MUSICA
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 10,
                ),
                child: ValueListenableBuilder<bool>(
                  valueListenable:
                      isMusicPlayingNotifier, // Ascolta la variabile globale
                  builder: (context, isMusicPlaying, child) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SwitchListTile(
                        title: Text(
                          "Musica",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        secondary: Icon(
                          isMusicPlaying ? Icons.music_note : Icons.music_off,
                          color: isMusicPlaying
                              ? Colors.blueAccent
                              : Colors.grey,
                        ),
                        value: isMusicPlaying,
                        onChanged: (bool value) {
                          // Chiama la funzione globale per stoppare/riavviare!
                          toggleMusic(value);
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),
              const Spacer(), // Questa è la "molla" magica che spinge il bottone in fondo allo schermo

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 20, // Un po' di spazio dal fondo del telefono
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    // 1. FERMA LA MUSICA USANDO LA TUA FUNZIONE GLOBALE
                    toggleMusic(false);
                    signOut();
                  },
                  icon: const Icon(Icons.logout, size: 28),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(
                      double.infinity,
                      55,
                    ), // Largo tutto lo schermo
                    backgroundColor: Colors.redAccent.withOpacity(
                      0.9,
                    ), // Rosso per indicare l'uscita
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        20,
                      ), // Usa lo stesso arrotondamento degli altri tasti
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 10,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    // Usiamo lo stesso stile degli altri riquadri per coerenza
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.groups, color: Colors.blueGrey),
                          SizedBox(width: 10),
                          Text(
                            "Credits",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                        height: 25,
                        thickness: 1,
                      ), // Una riga sottile divisoria
                      // Elenco dei nomi
                      _buildCreditName("Alessandro Di Saverio"),
                      _buildCreditName("Alessio Falasca"),
                      _buildCreditName("Gemini AI"),

                      const SizedBox(height: 10),
                      const Text(
                        "Progetto Mobile Computing 2025/2026",
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreditName(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.star_border, size: 16, color: Colors.amber),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

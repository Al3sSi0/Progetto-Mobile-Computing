import 'package:corner/structure.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:corner/authenticate/authentication.dart';
import 'package:corner/services/auth.dart';
import 'package:audioplayers/audioplayers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Avvia la musica all'apertura dell'app!
  startBackgroundMusic();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(systemNavigationBarColor: Colors.white),
  );
  runApp(const MyApp());
}

// 1. Variabili globali per la musica
final AudioPlayer bgMusicPlayer = AudioPlayer();
final ValueNotifier<bool> isMusicPlayingNotifier = ValueNotifier(true);

// 2. Funzione per far partire la musica (chiamala nel main!)
Future<void> startBackgroundMusic() async {
  // Imposta la musica in loop (così ricomincia quando finisce)
  bgMusicPlayer.setReleaseMode(ReleaseMode.loop);

  // Avvia la riproduzione del file che hai messo negli assets
  await bgMusicPlayer.play(AssetSource('audio/background.mp3'));
  isMusicPlayingNotifier.value = true;
}

// 3. Funzione per attivare/disattivare tramite il bottone
void toggleMusic(bool play) {
  if (play) {
    bgMusicPlayer.resume(); // Riprende da dove era
  } else {
    bgMusicPlayer.pause(); // Mette in pausa
  }
  isMusicPlayingNotifier.value = play;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Structure();
          } else {
            return Authentication();
          }
        },
      ),
    );
  }
}

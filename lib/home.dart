import 'package:corner/pages/ilMilionario_screen.dart';
import 'package:corner/services/auth.dart';
import 'package:corner/structure.dart';
import 'package:corner/pages/sole_page.dart';
import 'package:corner/pages/Classifica.dart';
import 'package:corner/pages/ilMilionario_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'dart:ui';

class CardButtonData {
  final String title;
  final Widget Function() pageBuilder;
  final String imagePath;
  final double topImg;
  final double widthImg;
  final double heightImg;
  const CardButtonData(
    this.title,
    this.pageBuilder,
    this.imagePath,
    this.topImg,
    this.widthImg,
    this.heightImg,
  );
}

class AnimatedButtonsCarousel extends StatefulWidget {
  const AnimatedButtonsCarousel({super.key});

  @override
  State<AnimatedButtonsCarousel> createState() =>
      _AnimatedButtonsCarouselState();
}

class _AnimatedButtonsCarouselState extends State<AnimatedButtonsCarousel> {
  late PageController _pageController;
  final double _viewportFraction = 0.8;
  final double _scaleFactor = 0.8;

  final List<CardButtonData> _items = [
    CardButtonData(
      'IL MILIONARIO',
      () => QuizScreen(),
      'assets/images/modric_corner.png',
      30,
      500,
      400,
    ),
    CardButtonData(
      'Coming Soon',
      () => SolePage(),
      'assets/images/messi_corner.png',
      10,
      500,
      500,
    ),
    CardButtonData(
      'Classifichiamo!',
      () => Classifica(),
      'assets/images/salah.png',
      0,
      500,
      500,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkUserNickname();
    // Inizializzazione del tuo PageController esistente
    _pageController = PageController(
      viewportFraction: _viewportFraction,
      initialPage: _items.length * 100,
    );

    _pageController.addListener(() {
      setState(() {});
    });

    // Gestione post-frame: aggiorna la UI e controlla il Nickname
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {}); // Il tuo vecchio setState
      }
    });
  }

  // Controlla su Firestore se l'utente ha già scelto un nome
  Future<void> _checkUserNickname() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.isAnonymous) {
      // Accede alla collezione 'users' che abbiamo creato insieme
      var doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // Se il documento non esiste o il campo nickname è nullo
      if (!doc.exists || doc.data()?['nickname'] == null) {
        _showNicknamePopUp(context, user.uid);
      }
    }
  }

  // Mostra il pop-up carino per il Nickname
  void _showNicknamePopUp(BuildContext context, String uid) {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // Obblighiamo l'utente a scegliere un nome
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Benvenuto su Corner! ⚽",
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Sembra che tu non abbia ancora un nickname."),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "Inserisci Nickname",
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () async {
                String nick = _controller.text.trim();
                if (nick.isNotEmpty) {
                  // Salviamo il nome nel "cassetto" users su Firestore
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .set({
                        'nickname': nick,
                        'lastUpdate': FieldValue.serverTimestamp(),
                        'trophies': [],
                      }, SetOptions(merge: true));

                  Navigator.pop(context); // Chiude il pop-up

                  // Opzionale: un messaggio di successo
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Benvenuto, $nick!")));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Inizia a giocare",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: PageView.builder(
        controller: _pageController,
        itemBuilder: (context, index) {
          return _buildCarouselItem(index);
        },
      ),
    );
  }

  Widget _buildCarouselItem(int index) {
    final int realIndex = index % _items.length;
    final CardButtonData data = _items[realIndex];

    Matrix4 matrix = Matrix4.identity();

    double currPageValue = 0.0;
    if (_pageController.hasClients && _pageController.page != null) {
      currPageValue = _pageController.page!;
    }

    double delta = (index - currPageValue);
    double scale = (1 - (delta.abs() * (1 - _scaleFactor))).clamp(
      _scaleFactor,
      1.0,
    );
    double transY = (400 * (1 - scale)) / 2;

    matrix = Matrix4.diagonal3Values(1.0, scale, 1.0)
      ..setTranslationRaw(0, transY, 0);

    return Transform(
      transform: matrix,
      child: Card(
        elevation: 15,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => data.pageBuilder()),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colore_barra.withOpacity(0.9),
                  colore_barra.withOpacity(0.6),
                ],
                stops: const [0, 1],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: data.topImg,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ShaderMask(
                    shaderCallback: (rect) {
                      return const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black, Colors.transparent],
                        stops: [0.3, 0.9],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.dstIn,
                    child: Opacity(
                      opacity: 0.4,
                      child: Image.asset(
                        data.imagePath,
                        width: data.widthImg,
                        height: data.heightImg,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0.20 * MediaQuery.of(context).size.height,
                          right: 0,
                          left: 0,
                          child: Text(
                            data.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 35,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(color: Colors.black45, blurRadius: 10),
                              ],
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
        ),
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
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
          child: Stack(
            children: [
              Positioned(
                top: 0.01 * screenHeight,
                right: 0.48 * screenWidth,
                child: Opacity(
                  opacity: 0.25,
                  child: Image.asset(
                    'assets/images/messi_corner.png',
                    height: 0.5 * screenHeight,
                  ),
                ),
              ),
              Positioned(
                top: 0.001 * screenHeight,
                left: 0.5 * screenWidth,
                child: Opacity(
                  opacity: 0.25,
                  child: Image.asset(
                    'assets/images/cr7_corner.png',
                    height: 0.6 * screenHeight,
                  ),
                ),
              ),

              Positioned(
                top: 0.04 * screenHeight,
                left: 0,
                right: 0,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(30, 25, 30, 10),
                        decoration: BoxDecoration(
                          color: colore_sfondo2.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          'CORNER!',
                          style: TextStyle(
                            fontSize: 45,
                            fontFamily: 'Instagram Sans',
                            fontWeight: FontWeight.bold,
                            color: colore_barra,
                            letterSpacing: 2.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0.045 * screenHeight,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'BENVENUTO SU',
                    style: TextStyle(
                      fontSize: 17,
                      fontFamily: 'Instagram Sans',
                      fontWeight: FontWeight.w500,
                      color: colore_barra,
                      letterSpacing: 2.5,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0.35 * screenHeight,
                left: 10,
                right: 10,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 10.0,
                        ),
                        decoration: BoxDecoration(
                          color: colore_sfondo2.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'SCEGLI UNA SFIDA E DIMOSTRA DI ESSERE IL MIGLIORE!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 19,
                              fontFamily: 'Instagram Sans',
                              fontWeight: FontWeight.bold,
                              color: colore_barra,
                              letterSpacing: 2.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                // 1. QUESTO LO RIMETTE AL SUO POSTO (GIÙ)
                top: 0.43 * screenHeight,
                left: 0,
                right: 0,

                // 2. QUESTO EVITA LO STRETCHING (GABBIA)
                child: SizedBox(
                  height:
                      400, // <--- CAMBIA QUESTO VALORE in base all'altezza che vuoi per le card
                  child: const AnimatedButtonsCarousel(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

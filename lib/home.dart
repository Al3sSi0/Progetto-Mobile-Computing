import 'package:corner/services/auth.dart';
import 'package:corner/structure.dart';
import 'package:corner/pages/sole_page.dart';
import 'package:corner/pages/fuoco_page.dart';
import 'package:corner/pages/acqua_page.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';

class CardButtonData {
  final String title;
  final IconData icon;
  final Widget Function() pageBuilder;
  const CardButtonData(this.title, this.icon, this.pageBuilder);
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
    CardButtonData('Sole', Icons.wb_sunny, () => SolePage()),
    CardButtonData('Fuoco', Icons.local_fire_department, () => FuocoPage()),
    CardButtonData('Acqua', Icons.water_drop, () => AcquaPage()),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
    _pageController = PageController(
      viewportFraction: _viewportFraction,
      initialPage: _items.length * 100,
    );
    _pageController.addListener(() {
      setState(() {});
    });
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
        elevation: 8,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: colore_barra,
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
                colors: [colore_barra.withOpacity(0.7), colore_barra],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(data.icon, size: 80, color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black26, blurRadius: 5)],
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

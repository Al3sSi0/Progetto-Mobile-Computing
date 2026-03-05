import 'package:corner/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:corner/profile.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

const colore_barra = Color(0xFF06402B);
const colore_sfondo1 = Color(0xFFEDE8D0);
const colore_sfondo2 = Color(0xFFB8B5A4);

class Structure extends StatefulWidget {
  const Structure({super.key});

  @override
  State<Structure> createState() => _StructureState();
}

class _StructureState extends State<Structure> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(systemNavigationBarColor: colore_barra),
      child: Scaffold(
        extendBody: true,
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: [
            Home(),

            Container(decoration: BoxDecoration(color: Colors.blue)),

            Container(decoration: BoxDecoration(color: Colors.green)),

            ProfilePage(),
          ],
        ),

        bottomNavigationBar: CurvedNavigationBar(
          index: _currentIndex,
          backgroundColor: Colors.transparent, // Lo sfondo dietro la curva
          color: colore_barra, // Il colore della barra stessa
          buttonBackgroundColor: colore_barra, // Il colore del cerchio che sale
          height: 60,
          items: <Widget>[
            Icon(CupertinoIcons.home, size: 30, color: Colors.white),
            Icon(CupertinoIcons.shopping_cart, size: 30, color: Colors.white),
            Icon(CupertinoIcons.star, size: 30, color: Colors.white),
            Icon(CupertinoIcons.person, size: 30, color: Colors.white),
          ],
          onTap: _onBottomNavTapped,
        ),
      ),
    );
  }
}

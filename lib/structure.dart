import 'package:corner/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 

const colore_barra = Color(0xFF06402B);
const colore_sfondo1 = Color(0xFFEDE8D0);
const colore_sfondo2 = Color(0xFFC9C5B1);

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
    value: const SystemUiOverlayStyle(
      systemNavigationBarColor: colore_barra),
      child: 
      Scaffold(
      body:
        PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children:  [
          Home(),
       
          Container(decoration: BoxDecoration(color: Colors.blue)),
       
          Container(decoration: BoxDecoration(color: Colors.green),),
       
          Container(decoration: BoxDecoration(color: Colors.yellow),),
        ],
      ),
      
       bottomNavigationBar: BottomNavigationBar(
        backgroundColor: colore_barra,
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: const Color.fromARGB(255, 206, 206, 206),
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Cerca',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifiche',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profilo',
          ),
        ],
      ),
    ),
    );
  }
}
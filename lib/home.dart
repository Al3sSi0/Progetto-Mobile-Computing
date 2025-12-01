import 'package:corner/structure.dart';
import 'package:corner/pages/sole_page.dart';
import 'package:corner/pages/fuoco_page.dart';
import 'package:corner/pages/acqua_page.dart';
import 'package:flutter/material.dart';
import 'dart:math';


class _ButtonSpec {
  final String title;
  final IconData icon;
  const _ButtonSpec(this.title, this.icon);
}





class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
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
              colore_sfondo1,
              colore_sfondo2,
            ]
          )
        ),
        child: SafeArea(
          child: Stack(
            children: [Positioned(
              top: 0.01*screenHeight,
              right: 0.48*screenWidth,
              child: Opacity(
              opacity: 0.25,
              child: Image.asset('assets/images/messi_cornerSfondo.png',
              height: 0.5*screenHeight,),
            )
            ),
            Positioned(top: 0.05*screenHeight, left: 0, right: 0,child: Center(
              child: Card(color: colore_sfondo2,
              elevation: 10,
                    child: Text('BENVENUTO!', 
                      style: TextStyle(
                        fontSize: 45,               
                        fontWeight: FontWeight.w900,
                        color: colore_barra,
                        letterSpacing: 2.5,
                      )),
                  ),
                ),
              ),
            
              Positioned(
                bottom: 0.06*screenHeight,
                left: 0.06*screenWidth,
                right: 0.06*screenWidth,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colore_barra,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SolePage()),
                          );
                        },
                        icon: const Icon(Icons.wb_sunny, color: Colors.white),
                        label: const Text(
                          'Sole',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colore_barra,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const FuocoPage()),
                          );
                        },
                        icon: const Icon(Icons.local_fire_department, color: Colors.white),
                        label: const Text(
                          'Fuoco',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colore_barra,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AcquaPage()),
                          );
                        },
                        icon: const Icon(Icons.water_drop, color: Colors.white),
                        label: const Text(
                          'Acqua',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              )          
            ],
          ),
        ),
      ),
    );
  }
}

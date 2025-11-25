import 'package:corner/structure.dart';
import 'package:flutter/material.dart';

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
            children: [
              Positioned(
                top: 0.43*screenHeight,
                left: 0,
                right: 0,
                child: 
                Center(
                  child: Card(
                    elevation: 10,
                    color: colore_barra,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      width: 0.8* screenWidth,
                      height: 0.4*screenHeight,
                    ),
                  ),
                )   
              )          
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:corner/structure.dart';

class SolePage extends StatelessWidget {
  const SolePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colore_barra,
        title: const Text('Sole'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colore_sfondo1,
              colore_sfondo2,
            ],
          ),
        ),
        child: const Center(
          child: Text(
            'Pagina Sole',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}


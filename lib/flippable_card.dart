import 'package:flutter/material.dart';
import 'dart:math'; // Necessario per pi (180 gradi)

class FlippableCard extends StatefulWidget {
  final Widget front;
  final Widget back;

  const FlippableCard({super.key, required this.front, required this.back});

  @override
  State<FlippableCard> createState() => _FlippableCardState();
}

class _FlippableCardState extends State<FlippableCard> {
  bool _isFlipped = false; // Stato: la carta è girata?

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isFlipped = !_isFlipped),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: _isFlipped ? pi : 0),
        duration: const Duration(milliseconds: 500),
        builder: (context, val, child) {
          // Determiniamo se mostrare il fronte o il retro in base alla rotazione
          bool isBack = val >= pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Aggiunge la prospettiva 3D
              ..rotateY(val),
            child: isBack 
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(pi), // Rigira il retro per leggerlo bene
                  child: widget.back,
                )
              : widget.front,
          );
        },
      ),
    );
  }
}
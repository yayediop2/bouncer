import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameOverScreen extends StatelessWidget {
  final bool isGameOver;
  final function;

  static var gameFont = GoogleFonts.pressStart2p(
      textStyle: TextStyle(
          color: Colors.deepPurple[600], letterSpacing: 0, fontSize: 28));

  const GameOverScreen({super.key, required this.isGameOver, this.function});

  @override
  Widget build(BuildContext context) {
    return isGameOver
        ? Stack(
            children: [
              Container(
                alignment: const Alignment(0, -0.3),
                child: const Text(
                  'GAME OVER',
                  style: gameFont,
                ),
              ),
              Container(
                alignment: const Alignment(0, 0.2),
                child: GestureDetector(
                    onTap: function,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        color: Colors.deepPurple,
                        child: const Text(
                          'play again',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )),
              )
            ],
          )
        : Container();
  }
}

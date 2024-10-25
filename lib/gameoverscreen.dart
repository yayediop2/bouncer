import 'package:flutter/material.dart';

class GameOverScreen extends StatelessWidget {
  final bool isGameOver;
  final function;
  const GameOverScreen({super.key, required this.isGameOver, this.function});

  @override
  Widget build(BuildContext context) {
    return isGameOver
        ? Stack(
            children: [
              Container(
                alignment: const Alignment(0, -0.3),
                child: const Text('G A M E  O V E R',
                    style: TextStyle(color: Colors.deepPurple, fontSize: 22)),
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

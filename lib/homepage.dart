import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_app_bouncer/ball.dart';
import 'package:my_app_bouncer/coverscreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double ballX = 0;
  double ballY = 0;
  bool hasGameStarted = false;

  void startGame() {
    hasGameStarted = true;
    Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        ballY -= 0.01;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: startGame,
      child: Scaffold(
        backgroundColor: Colors.deepPurple[100],
        body: Center(
          child: Stack(
            children: [
              Coverscreen(hasGameStarted: hasGameStarted),
              MyBall(
                ballX: ballX,
                ballY: ballY,
              )
            ],
          ),
        ),
      ),
    );
  }
}

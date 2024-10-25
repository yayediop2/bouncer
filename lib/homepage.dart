import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app_bouncer/ball.dart';
import 'package:my_app_bouncer/brick.dart';
import 'package:my_app_bouncer/coverscreen.dart';
import 'package:my_app_bouncer/gameoverscreen.dart';
import 'package:my_app_bouncer/player.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum direction { UP, DOWN }

class _HomePageState extends State<HomePage> {
  // ball variables
  double ballX = 0;
  double ballY = 0;

  // game state variables
  bool hasGameStarted = false;
  bool isGameOver = false;

  // player variables
  double playerX = -0.2;
  double playerWidth = 0.4;

  // brick variables
  double brickX = 0;
  double brickY = -0.9;
  double brickWidth = 0.4;
  double brickHeight = 0.05;

  var ballDirection = direction.DOWN;

  // start game
  void startGame() {
    hasGameStarted = true;
    Timer.periodic(const Duration(milliseconds: 10), (timer) {
      // move ball
      moveBall();

      // update direction
      updateDirection();

      // check if gameOver
      if (isPlayerDead()) {
        timer.cancel();
        isGameOver = true;
      }
    });
  }

  bool isPlayerDead() {
    if (ballY >= 1) {
      return true;
    }
    return false;
  }

  // move player left
  void moveLeft() {
    setState(() {
      // only move left if the player doesn't go offscreen
      if (!(playerX - 0.2 < -1)) {
        playerX -= 0.2;
      }
    });
  }

  // move player rigth
  void moveRight() {
    setState(() {
      // only move right if the player doesn't go offscreen
      if (!(playerX + playerWidth >= 1)) {
        playerX += 0.2;
      }
    });
  }

  void moveBall() {
    setState(() {
      if (ballDirection == direction.DOWN) {
        ballY += 0.01;
      } else if (ballDirection == direction.UP) {
        ballY -= 0.01;
      }
    });
  }

  void updateDirection() {
    setState(() {
      if (ballY >= 0.9 && ballX >= playerX && ballX <= playerX + playerWidth) {
        ballDirection = direction.UP;
      } else if (ballY <= -0.9) {
        ballDirection = direction.DOWN;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
          moveLeft();
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          moveRight();
        }
      },
      child: GestureDetector(
        onTap: startGame,
        child: Scaffold(
          backgroundColor: Colors.deepPurple[100],
          body: Center(
            child: Stack(
              children: [
                // tap to play
                Coverscreen(hasGameStarted: hasGameStarted),

                // game over screen
                GameOverScreen(isGameOver: isGameOver),

                // ball
                MyBall(
                  ballX: ballX,
                  ballY: ballY,
                ),

                // player
                MyPlayer(
                  playerX: playerX,
                  playerWidth: playerWidth,
                ),

                // brick
                MyBrick(
                  brickX: brickX,
                  brickY: brickY,
                  brickHeight: brickHeight,
                  brickWidth: brickWidth,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

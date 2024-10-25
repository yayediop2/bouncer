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

enum direction { UP, DOWN, LEFT, RIGHT }

class _HomePageState extends State<HomePage> {
  // ball variables
  double ballX = 0;
  double ballY = 0;
  double ballXincrements = 0.01;
  double ballYincrements = 0.01;

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
  bool isBrickBroken = false;

  var ballYDirection = direction.DOWN;
  var ballXDirection = direction.LEFT;

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

      // check for broken bricks
      checkForBrokenBricks();
    });
  }

  void resetGame() {
    // _initializeBricks();
    setState(() {
      playerX = -0.2;
      ballX = 0;
      ballY = 0;
      isGameOver = false;
      hasGameStarted = false;
    });
  }

  void checkForBrokenBricks() {
    if (ballX >= brickX &&
        ballX <= brickX + brickWidth &&
        ballY <= brickY + brickHeight &&
        isBrickBroken == false) {
      setState(() {
        isBrickBroken = true;
        ballYDirection = direction.DOWN;
      });
    }
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
      // move horizontally
      if (ballXDirection == direction.LEFT) {
        ballX -= ballXincrements;
      } else if (ballXDirection == direction.RIGHT) {
        ballX += ballXincrements;
      }

      // move vertically
      if (ballYDirection == direction.DOWN) {
        ballY += ballYincrements;
      } else if (ballYDirection == direction.UP) {
        ballY -= ballYincrements;
      }
    });
  }

  void updateDirection() {
    setState(() {
      // player
      if (ballY >= 0.9 && ballX >= playerX && ballX <= playerX + playerWidth) {
        ballYDirection = direction.UP;
      }
      // top
      else if (ballY <= -1) {
        ballYDirection = direction.DOWN;
      }
      // right wall
      else if (ballX >= 1) {
        ballXDirection = direction.LEFT;
      }
      // left wall
      else if (ballX <= -1) {
        ballXDirection = direction.RIGHT;
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
                GameOverScreen(
                  isGameOver: isGameOver,
                  function: resetGame,
                ),

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
                  isBrickBroken: isBrickBroken,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

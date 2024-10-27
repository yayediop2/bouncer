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
  double ballXincrements = 0.015;
  double ballYincrements = 0.01;

  // game state variables
  bool hasGameStarted = false;
  bool isGameOver = false;

  // player variables
  double playerX = -0.2;
  double playerWidth = 0.4;

  // brick variables
  static double firstBrickX = -1 + wallGap;
  static double firstBrickY = -0.9;
  static double brickWidth = 0.3;
  static double brickHeight = 0.05;
  static double brickGap = 0.1;
  static int numberOfBrickInRow = 5;
  static double wallGap = 0.5 *
      (2 -
          numberOfBrickInRow * brickWidth -
          (numberOfBrickInRow - 1) * brickGap);

  List myBricks = [
    // [x, y, broken = true/false]
    [firstBrickX + 0 * (brickWidth + brickGap), firstBrickY, false],
    [firstBrickX + 1 * (brickWidth + brickGap), firstBrickY, false],
    [firstBrickX + 2 * (brickWidth + brickGap), firstBrickY, false],
    [firstBrickX + 3 * (brickWidth + brickGap), firstBrickY, false],
    [firstBrickX + 4 * (brickWidth + brickGap), firstBrickY, false],
  ];

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
    setState(() {
      myBricks = [
        // [x, y, broken = true/false]
        [firstBrickX + 0 * (brickWidth + brickGap), firstBrickY, false],
        [firstBrickX + 1 * (brickWidth + brickGap), firstBrickY, false],
        [firstBrickX + 2 * (brickWidth + brickGap), firstBrickY, false],
        [firstBrickX + 3 * (brickWidth + brickGap), firstBrickY, false],
        [firstBrickX + 4 * (brickWidth + brickGap), firstBrickY, false],
      ];
      playerX = -0.2;
      ballX = 0;
      ballY = 0;
      isGameOver = false;
      hasGameStarted = false;
    });
  }

  void checkForBrokenBricks() {
    for (var i = 0; i < myBricks.length; i++) {
      if (ballX >= myBricks[i][0] &&
          ballX <= myBricks[i][0] + brickWidth &&
          ballY <= myBricks[i][1] + brickHeight &&
          myBricks[i][2] == false) {
        setState(() {
          myBricks[i][2] = true;
          // change direction after broken brick
          double leftSideDist = (myBricks[i][0] - ballX).abs();
          double rightSideDist = (myBricks[i][0] + brickWidth - ballX).abs();
          double topSideDist = (myBricks[i][1] - ballY).abs();
          double bottomSideDist = (myBricks[i][1] + brickHeight - ballY).abs();

          String min =
              findMin(leftSideDist, rightSideDist, topSideDist, bottomSideDist);
          switch (min) {
            case 'left':
              ballXDirection = direction.LEFT;
            case 'right':
              ballXDirection = direction.RIGHT;
            case 'up':
              ballYDirection = direction.UP;
            case 'down':
              ballYDirection = direction.DOWN;

              break;
          }
        });
      }
    }
  }

  String findMin(double a, double b, double c, double d) {
    List<double> myList = [a, b, c, d];

    double currentMin = a;

    for (var i = 0; i < myList.length; i++) {
      if (myList[i] < currentMin) {
        currentMin = myList[i];
      }
    }

    if ((currentMin - a).abs() < 0.01) {
      return 'left';
    } else if ((currentMin - b).abs() < 0.01) {
      return 'right';
    } else if ((currentMin - c).abs() < 0.01) {
      return 'up';
    } else if ((currentMin - d).abs() < 0.01) {
      return 'down';
    }
    return '';
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
                  brickX: myBricks[0][0],
                  brickY: myBricks[0][1],
                  brickHeight: brickHeight,
                  brickWidth: brickWidth,
                  isBrickBroken: myBricks[0][2],
                ),
                MyBrick(
                  brickX: myBricks[1][0],
                  brickY: myBricks[1][1],
                  brickHeight: brickHeight,
                  brickWidth: brickWidth,
                  isBrickBroken: myBricks[1][2],
                ),
                MyBrick(
                  brickX: myBricks[2][0],
                  brickY: myBricks[2][1],
                  brickHeight: brickHeight,
                  brickWidth: brickWidth,
                  isBrickBroken: myBricks[2][2],
                ),
                MyBrick(
                  brickX: myBricks[3][0],
                  brickY: myBricks[3][1],
                  brickHeight: brickHeight,
                  brickWidth: brickWidth,
                  isBrickBroken: myBricks[3][2],
                ),
                MyBrick(
                  brickX: myBricks[4][0],
                  brickY: myBricks[4][1],
                  brickHeight: brickHeight,
                  brickWidth: brickWidth,
                  isBrickBroken: myBricks[4][2],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

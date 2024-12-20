// ignore_for_file: constant_identifier_names, camel_case_types, deprecated_member_use, avoid_print
import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app_bouncer/ball.dart';
import 'package:my_app_bouncer/brick.dart';
import 'package:my_app_bouncer/coverscreen.dart';
import 'package:my_app_bouncer/gameoverscreen.dart';
import 'package:my_app_bouncer/player.dart';
import 'package:my_app_bouncer/utils.dart';
import 'package:sensors_plus/sensors_plus.dart';

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
  double ballXincrements = 0.005;
  double ballYincrements = 0.002;

  // game state variables
  Timer? _gameTimer;
  bool hasGameStarted = false;
  bool isGameOver = false;
  bool isPaused = false;

  // player variables
  double playerX = -0.2;
  double playerWidth = 0.4;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid || Platform.isIOS) {
      _setupAccelerometer();
    }
  }

  void _setupAccelerometer() {
    double sensitivity = 0.015; // Reduced sensitivity for smoother control
    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      if (!isPaused && hasGameStarted) {
        setState(() {
          // Calculate new position based on accelerometer input
          // Negative because tilting right (positive X) should move paddle right
          double movement = -event.x * sensitivity;
          double newPosition = playerX + movement;

          // Clamp position within screen boundaries (-1 to 1)
          if (newPosition < -1) {
            playerX = -1;
          } else if (newPosition + playerWidth > 1) {
            playerX = 1 - playerWidth;
          } else {
            playerX = newPosition;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

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
    // First row
    [firstBrickX + 0 * (brickWidth + brickGap), firstBrickY, false],
    [firstBrickX + 1 * (brickWidth + brickGap), firstBrickY, false],
    [firstBrickX + 2 * (brickWidth + brickGap), firstBrickY, false],
    [firstBrickX + 3 * (brickWidth + brickGap), firstBrickY, false],
    [firstBrickX + 4 * (brickWidth + brickGap), firstBrickY, false],

    // Second row (placed below the first row with a gap)
    [
      firstBrickX + 0 * (brickWidth + brickGap),
      firstBrickY + brickHeight + 0.05,
      false
    ],
    [
      firstBrickX + 1 * (brickWidth + brickGap),
      firstBrickY + brickHeight + 0.05,
      false
    ],
    [
      firstBrickX + 2 * (brickWidth + brickGap),
      firstBrickY + brickHeight + 0.05,
      false
    ],
    [
      firstBrickX + 3 * (brickWidth + brickGap),
      firstBrickY + brickHeight + 0.05,
      false
    ],
    [
      firstBrickX + 4 * (brickWidth + brickGap),
      firstBrickY + brickHeight + 0.05,
      false
    ],
  ];

  var ballYDirection = direction.DOWN;
  var ballXDirection = direction.LEFT;

  // start game
  void startGame() {
    if (hasGameStarted || _gameTimer != null) {
      return; // Don't start if game is already running
    }

    setState(() {
      hasGameStarted = true;
    });

    _gameTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (isPaused) {
        return;
      }
      // move ball
      moveBall();

      // update direction
      updateDirection();

      // check if gameOver
      if (isPlayerDead()) {
        timer.cancel();
        _gameTimer = null;
        isGameOver = true;
      }

      // check if all bricks are broken
      if (areAllBricksBroken()) {
        timer.cancel();
        _gameTimer = null;
        isGameOver = true;
      }

      // check for broken bricks
      checkForBrokenBricks();
    });
  }

  void resetGame() {
    _gameTimer?.cancel();
    _gameTimer = null;

    setState(() {
      myBricks = [
        // [x, y, broken = true/false]
        // First row
        [firstBrickX + 0 * (brickWidth + brickGap), firstBrickY, false],
        [firstBrickX + 1 * (brickWidth + brickGap), firstBrickY, false],
        [firstBrickX + 2 * (brickWidth + brickGap), firstBrickY, false],
        [firstBrickX + 3 * (brickWidth + brickGap), firstBrickY, false],
        [firstBrickX + 4 * (brickWidth + brickGap), firstBrickY, false],

        // Second row (placed below the first row with a gap)
        [
          firstBrickX + 0 * (brickWidth + brickGap),
          firstBrickY + brickHeight + 0.05,
          false
        ],
        [
          firstBrickX + 1 * (brickWidth + brickGap),
          firstBrickY + brickHeight + 0.05,
          false
        ],
        [
          firstBrickX + 2 * (brickWidth + brickGap),
          firstBrickY + brickHeight + 0.05,
          false
        ],
        [
          firstBrickX + 3 * (brickWidth + brickGap),
          firstBrickY + brickHeight + 0.05,
          false
        ],
        [
          firstBrickX + 4 * (brickWidth + brickGap),
          firstBrickY + brickHeight + 0.05,
          false
        ],
      ];
      playerX = -0.2;
      ballX = 0;
      ballY = 0;
      isGameOver = false;
      hasGameStarted = false;
      isPaused = false;
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

  bool isPlayerDead() {
    if (ballY >= 1) {
      return true;
    }
    return false;
  }

  // move player left
  void moveLeft() {
    if (isPaused || !hasGameStarted) return;
    setState(() {
      // only move left if the player doesn't go offscreen
      if (!(playerX - 0.2 < -1)) {
        playerX -= 0.2;
      }
    });
  }

  // move player rigth
  void moveRight() {
    if (isPaused || !hasGameStarted) return;
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
      if (ballY >= 0.9 && ballY <= 0.95 && // Narrower vertical collision window
          ballX >= playerX && 
          ballX <= playerX + playerWidth) {
        ballYDirection = direction.UP;
      }
      // Game over condition - ball passes paddle
      else if (ballY > 0.95) {
        // Let the ball continue falling until it triggers game over
        ballYDirection = direction.DOWN;
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

  bool areAllBricksBroken() {
    for (var brick in myBricks) {
      if (!brick[2]) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        // Keep keyboard controls for non-mobile platforms
        if (!Platform.isAndroid && !Platform.isIOS) {
          if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
            moveLeft();
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
            moveRight();
          }
        }
        // Keep escape key for all platforms
        if (event.isKeyPressed(LogicalKeyboardKey.escape)) {
          setState(() {
            isPaused = !isPaused;
          });
        }
      },
      child: GestureDetector(
        onTap: startGame,
        child: Scaffold(
          backgroundColor: Colors.deepPurple[100],
          body: Center(
            child: Stack(
              children: [
                isPaused && !isGameOver
                    ? Container(
                        alignment: const Alignment(0, -0.3),
                        child: const Text(
                          'PAUSED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : Container(),

                // tap to play
                Coverscreen(hasGameStarted: hasGameStarted),

                // game over screen
                GameOverScreen(
                  isGameOver: isGameOver,
                  hasPlayerWon: areAllBricksBroken(),
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
                // display all bricks
                ...myBricks.map((brick) {
                  return MyBrick(
                    brickX: brick[0],
                    brickY: brick[1],
                    brickHeight: brickHeight,
                    brickWidth: brickWidth,
                    isBrickBroken: brick[2],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

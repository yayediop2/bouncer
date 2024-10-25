// ignore_for_file: prefer_typing_uninitialized_variables
import 'package:flutter/material.dart';

class MyBrick extends StatelessWidget {
  final brickX;
  final brickY;
  final brickHeight;
  final brickWidth;
  const MyBrick(
      {super.key, this.brickX, this.brickY, this.brickHeight, this.brickWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(brickX, brickY),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
          height: MediaQuery.of(context).size.height * brickHeight / 2,
          width: MediaQuery.of(context).size.width * brickWidth / 2,
          color: Colors.deepPurple,
        ),
      ),
    );
  }
}

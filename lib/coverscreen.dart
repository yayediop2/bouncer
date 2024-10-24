import 'package:flutter/material.dart';

class Coverscreen extends StatelessWidget {
  final bool hasGameStarted;
  const Coverscreen({super.key, required this.hasGameStarted});

  @override
  Widget build(BuildContext context) {
    return hasGameStarted
        ? Container()
        : Container(
            alignment: const Alignment(0, -0.1),
            child: Text(
              'tap to play',
              style: TextStyle(color: Colors.deepPurple[400]),
            ),
          );
  }
}

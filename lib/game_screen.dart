import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pong_game/pong_menu.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final ballSize = 20.0;
  final racketWidth = 120.0;
  final racketHeight = 25.0;
  final racketBottomOffset = 50.0;

  final initialBallSpeed = 2.0;

  double racketX = 20;

  double ballX = 20;
  double ballY = 20;
  double ballSpeedX = 0;
  double ballSpeedY = 0;

  int score = 0;

  late double ballSpeedMultiplier;

  late Ticker ticker;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  @override
  void dispose() {
    super.dispose();
    stopGame();
  }

  void startGame() {
    final random = Random();
    ballX = 20;
    ballY = 20;
    ballSpeedX = -initialBallSpeed;
    ballSpeedY = -initialBallSpeed;
    racketX = 135;
    score = 0;

    if (random.nextBool()) {
      ballSpeedX = -ballSpeedX;
    }

    if (random.nextBool()) {
      ballSpeedY = -ballSpeedY;
    }

    continueGame();
  }

  void stopGame() {
    ticker.dispose();
  }

  void continueGame() {
    Future.delayed(const Duration(seconds: 1), () {
      ticker = Ticker((elapsed) {
        setState(() {
          moveBall();
        });
      });
      ticker.start();
    });
  }

  void moveBall() {
    ballX == 20 && ballY == 20 ? ballSpeedMultiplier = 2 : ballSpeedMultiplier;
    debugPrint("ballSpeedMultiplier: $ballSpeedMultiplier");

    ballX += ballSpeedX * ballSpeedMultiplier;
    ballY += ballSpeedY * ballSpeedMultiplier;
    final Size size = MediaQuery.of(context).size;

    if (ballY < 0) {
      ballSpeedY = -ballSpeedY;
      score++;
      ballSpeedMultiplier += 0.1;
      debugPrint("ballSpeedMultiplier: $ballSpeedMultiplier");
    }

    if (ballX < 0 || ballX > size.width - ballSize) {
      ballSpeedX = -ballSpeedX;
    }

    if (ballY > size.height - ballSize - racketHeight - racketBottomOffset &&
        ballX >= racketX &&
        ballX <= racketX + racketWidth) {
      ballSpeedY = -ballSpeedY;
    } else if (ballY > size.height - ballSize) {
      debugPrint("gameover");
      stopGame();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return PongMenu(
            title: "Game Over",
            subtitle: "Your score",
            score: score.toString(),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.purple),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                startGame();
              },
              child: const Text(
                "Play Again",
                style: TextStyle(fontSize: 18),
              ),
            ),
          );
        },
      );
    }
  }

  void moveracket(double x) {
    setState(() {
      racketX = x - racketWidth / 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onHorizontalDragUpdate: (details) {
              moveracket(details.globalPosition.dx);
            },
            child: CustomPaint(
              painter: _GamePainter(
                racketBottomOffset: racketBottomOffset,
                racketHeight: racketHeight,
                racketWidth: racketWidth,
                racketX: racketX,
                ballSize: ballSize,
                ballX: ballX,
                ballY: ballY,
              ),
              size: Size.infinite,
            ),
          ),
          Center(
            child: Text(
              "Score: $score",
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              onPressed: () {
                stopGame();
                showDialog(
                  context: context,
                  builder: (context) {
                    return PongMenu(
                      title: "Pause",
                      subtitle: "Your score",
                      score: score.toString(),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.purple),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          continueGame();
                        },
                        child: const Text(
                          "Resume",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    );
                  },
                );
              },
              icon: const Icon(
                Icons.pause,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GamePainter extends CustomPainter {
  final double ballX;
  final double ballY;
  final double ballSize;

  final double racketX;
  final double racketWidth;
  final double racketHeight;
  final double racketBottomOffset;

  _GamePainter({
    required this.racketBottomOffset,
    required this.ballX,
    required this.ballY,
    required this.ballSize,
    required this.racketX,
    required this.racketWidth,
    required this.racketHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final racketPaint = Paint()..color = Colors.black;
    final ballPaint = Paint()..color = Colors.black;
    final backgroundPaint = Paint()..color = Colors.grey[300]!;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    canvas.drawOval(
      Rect.fromLTWH(
        ballX,
        ballY,
        ballSize,
        ballSize,
      ),
      ballPaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        racketX,
        size.height - racketHeight - racketBottomOffset,
        racketWidth,
        racketHeight,
      ),
      racketPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GamePainter oldDelegate) {
    return ballX != oldDelegate.ballX ||
        ballY != oldDelegate.ballY ||
        racketX != oldDelegate.racketX;
  }
}

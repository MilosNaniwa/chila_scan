import 'package:flutter/material.dart';

class ChikaPainter extends CustomPainter {
  final Offset position1;
  final Offset position2;

  ChikaPainter({
    @required this.position1,
    @required this.position2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 30;
    canvas.drawLine(position1, position2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}

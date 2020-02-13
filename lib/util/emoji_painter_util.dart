import 'package:flutter/material.dart';

class EmojiPainter extends CustomPainter {
  final Offset position;
  final double fontSize;

  EmojiPainter({
    @required this.position,
    @required this.fontSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textSpan = TextSpan(
      text: '😄',
      style: TextStyle(
        fontSize: fontSize,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: 0,
    );

    textPainter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}

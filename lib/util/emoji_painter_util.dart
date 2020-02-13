import 'package:flutter/material.dart';

class EmojiPainter extends CustomPainter {
  final Offset centerPosition;
  final Size faceSize;

  EmojiPainter({
    @required this.centerPosition,
    @required this.faceSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textSpan = TextSpan(
      text: '😄',
      style: TextStyle(
        fontSize: faceSize.height,
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

    textPainter.paint(canvas, centerPosition);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}

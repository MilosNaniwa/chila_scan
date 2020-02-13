import 'package:flutter/material.dart';

class EmojiPainter extends CustomPainter {
  final Offset position;

  EmojiPainter({
    @required this.position,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textSpan = TextSpan(
      text: '😄',
      style: TextStyle(
        fontSize: 100,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    textPainter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}

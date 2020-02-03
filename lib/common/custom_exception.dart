import 'package:flutter/foundation.dart';

class CustomException implements Exception {
  final errorCode;
  final message;

  CustomException({
    @required this.errorCode,
    this.message,
  });
}

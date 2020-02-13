import 'package:flutter/material.dart';

class FaceLandmarkModel {
  final Offset leftEyePosition;
  final Offset rightEyePosition;
  final Offset topCenterPosition;
  final Size faceSize;

  FaceLandmarkModel({
    @required this.leftEyePosition,
    @required this.rightEyePosition,
    @required this.topCenterPosition,
    @required this.faceSize,
  });
}

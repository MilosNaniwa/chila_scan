import 'package:flutter/material.dart';

class FaceLandmarkModel {
  final Offset leftEyePosition;
  final Offset rightEyePosition;
  final Offset noseBasePosition;

  FaceLandmarkModel({
    @required this.leftEyePosition,
    @required this.rightEyePosition,
    @required this.noseBasePosition,
  });
}

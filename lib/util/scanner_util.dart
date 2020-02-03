import 'dart:io';

import 'package:chika_scan/common/custom_exception.dart';
import 'package:chika_scan/common/error_code.dart';
import 'package:chika_scan/model/eyes_position_model.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

class ScannerUtil {
  EyesPositionModel detectPositionOfEyes({
    @required List<Face> faceList,
    @required double imageWidth,
    @required double imageHeight,
    @required bool isUsedFrontCamera,
    @required double campusWidth,
    @required double campusHeight,
  }) {
    Offset _leftEyePosition;
    Offset _rightEyePosition;

    FaceLandmark leftEye = faceList.first.getLandmark(
      FaceLandmarkType.leftEye,
    );

    FaceLandmark rightEye = faceList.first.getLandmark(
      FaceLandmarkType.rightEye,
    );

    if (leftEye != null && rightEye != null) {
      double _imageWidth;
      double _imageHeight;
      if (imageWidth > imageHeight) {
        _imageWidth = imageHeight;
        _imageHeight = imageWidth;
      } else {
        _imageWidth = imageWidth;
        _imageHeight = imageHeight;
      }

      if (Platform.isAndroid && isUsedFrontCamera) {
        _leftEyePosition = Offset(
          campusWidth -
              (leftEye.position.dx * (campusWidth / _imageWidth) * 0.75),
          leftEye.position.dy * campusHeight / _imageHeight,
        );
        _rightEyePosition = Offset(
          campusWidth -
              (rightEye.position.dx * (campusWidth / _imageWidth) * 1.25),
          rightEye.position.dy * (campusHeight / _imageHeight),
        );
      } else {
        _leftEyePosition = Offset(
          leftEye.position.dx * (campusWidth / _imageWidth) * 0.75,
          leftEye.position.dy * campusHeight / _imageHeight,
        );
        _rightEyePosition = Offset(
          rightEye.position.dx * (campusWidth / _imageWidth) * 1.25,
          rightEye.position.dy * (campusHeight / _imageHeight),
        );
      }

      return EyesPositionModel(
        leftEyePosition: _leftEyePosition,
        rightEyePosition: _rightEyePosition,
      );
    } else {
      throw CustomException(
        errorCode: ErrorCode.cannotDetectEyes,
      );
    }
  }
}

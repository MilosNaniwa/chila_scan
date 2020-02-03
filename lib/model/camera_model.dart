import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraModel {
  final List<CameraDescription> availableCameraList;

  CameraModel({
    @required this.availableCameraList,
  });
}

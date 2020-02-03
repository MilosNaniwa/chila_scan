import 'package:chika_scan/model/camera_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

abstract class ChikaScanScreenState extends Equatable {
  @override
  List<Object> get props => [];
}

class UninitializedState extends ChikaScanScreenState {
  @override
  String toString() => '初期化前';
}

class InitializingState extends ChikaScanScreenState {
  @override
  String toString() => '初期化中';
}

class InitializedState extends ChikaScanScreenState {
  final CameraModel cameraModel;

  InitializedState({
    @required this.cameraModel,
  });

  @override
  String toString() => '初期化後';
}

class ScanningState extends ChikaScanScreenState {
  @override
  String toString() => 'スキャン中';
}

class ScannedState extends ChikaScanScreenState {
  @override
  String toString() => 'スキャン後';
}

class CameraSwitchingState extends ChikaScanScreenState {
  @override
  String toString() => 'カメラ切り替え中';
}

class CameraSwitchedState extends ChikaScanScreenState {
  @override
  String toString() => 'カメラ切り替え後';
}

class ToTakePicturePreparingState extends ChikaScanScreenState {
  @override
  String toString() => '写真撮影準備中';
}

class ToTakePicturePreparedState extends ChikaScanScreenState {
  @override
  String toString() => '写真撮影準備後';
}

class PictureTakingState extends ChikaScanScreenState {
  @override
  String toString() => '写真撮影中';
}

class PictureTookState extends ChikaScanScreenState {
  @override
  String toString() => '写真撮影後';
}

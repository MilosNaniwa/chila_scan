import 'package:chika_scan/model/camera_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

abstract class ScanScreenState extends Equatable {
  @override
  List<Object> get props => [];
}

class UninitializedState extends ScanScreenState {
  @override
  String toString() => '初期化前';
}

class InitializingState extends ScanScreenState {
  @override
  String toString() => '初期化中';
}

class InitializedState extends ScanScreenState {
  final CameraModel cameraModel;

  InitializedState({
    @required this.cameraModel,
  });

  @override
  String toString() => '初期化後';
}

class ScanningState extends ScanScreenState {
  @override
  String toString() => 'スキャン中';
}

class ScannedState extends ScanScreenState {
  final String scannedData;

  ScannedState({
    @required this.scannedData,
  });

  @override
  String toString() => 'スキャン後';
}

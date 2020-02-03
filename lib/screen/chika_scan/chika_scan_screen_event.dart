import 'package:equatable/equatable.dart';

abstract class ChikaScanScreenEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class OnRequestInitializingEvent extends ChikaScanScreenEvent {
  @override
  String toString() => '初期化要求';
}

class OnCompleteRenderingEvent extends ChikaScanScreenEvent {
  @override
  String toString() => '描画完了';
}

class OnRequestScanningEvent extends ChikaScanScreenEvent {
  @override
  String toString() => 'スキャン要求';
}

class OnCompleteScanningEvent extends ChikaScanScreenEvent {
  @override
  String toString() => 'スキャン完了';
}

class OnRequestSwitchingCameraEvent extends ChikaScanScreenEvent {
  @override
  String toString() => 'カメラ切り替え要求';
}

class OnCompleteSwitchingCameraEvent extends ChikaScanScreenEvent {
  @override
  String toString() => 'カメラ切り替え完了';
}

class OnRequestPreparingToTakePictureEvent extends ChikaScanScreenEvent {
  @override
  String toString() => '写真撮影準備要求';
}

class OnCompletePreparingToTakePictureEvent extends ChikaScanScreenEvent {
  @override
  String toString() => '写真撮影準備完了';
}

class OnRequestTakingPictureEvent extends ChikaScanScreenEvent {
  @override
  String toString() => '写真撮影要求';
}

class OnCompleteTakingPictureEvent extends ChikaScanScreenEvent {
  @override
  String toString() => '写真撮影完了';
}

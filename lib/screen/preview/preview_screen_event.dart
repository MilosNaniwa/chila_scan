import 'package:equatable/equatable.dart';

abstract class PreviewScreenEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class OnRequestInitializingEvent extends PreviewScreenEvent {
  @override
  String toString() => '初期化要求';
}

class OnCompleteRenderingEvent extends PreviewScreenEvent {
  @override
  String toString() => '描画完了';
}

class OnRequestSharingImageEvent extends PreviewScreenEvent {
  @override
  String toString() => '画像共有要求';
}

class OnCompleteSharingImageEvent extends PreviewScreenEvent {
  @override
  String toString() => '画像共有完了';
}

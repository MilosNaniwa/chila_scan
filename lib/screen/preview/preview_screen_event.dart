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

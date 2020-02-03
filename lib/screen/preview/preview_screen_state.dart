import 'package:equatable/equatable.dart';

abstract class PreviewScreenState extends Equatable {
  @override
  List<Object> get props => [];
}

class UninitializedState extends PreviewScreenState {
  @override
  String toString() => '初期化前';
}

class InitializingState extends PreviewScreenState {
  @override
  String toString() => '初期化中';
}

class InitializedState extends PreviewScreenState {
  @override
  String toString() => '初期化後';
}

class IdlingState extends PreviewScreenState {
  @override
  String toString() => '待機中';
}

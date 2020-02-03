import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

abstract class ScanScreenEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class OnRequestInitializingEvent extends ScanScreenEvent {
  @override
  String toString() => '初期化要求';
}

class OnRequestScanningEvent extends ScanScreenEvent {
  @override
  String toString() => 'スキャン要求';
}

class OnCompleteScanningEvent extends ScanScreenEvent {
  final String scannedData;

  OnCompleteScanningEvent({
    @required this.scannedData,
  });

  @override
  String toString() => 'スキャン完了';
}

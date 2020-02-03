import 'package:chika_scan/model/camera_model.dart';
import 'package:chika_scan/repository/camera_repository.dart';
import 'package:chika_scan/screen/scan/scan_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScanScreenBloc extends Bloc<ScanScreenEvent, ScanScreenState> {
  @override
  String toString() => "スキャン画面";

  final CameraRepository cameraRepository;

  ScanScreenBloc({
    @required this.cameraRepository,
  });

  @override
  ScanScreenState get initialState => UninitializedState();

  @override
  Stream<ScanScreenState> mapEventToState(ScanScreenEvent event) async* {
    // 初期化要求
    if (event is OnRequestInitializingEvent) {
      yield InitializingState();

      CameraModel cameraModel = await cameraRepository.getAvailableCamera();

      yield InitializedState(
        cameraModel: cameraModel,
      );
    }

    // スキャン要求
    else if (event is OnRequestScanningEvent) {
      yield ScanningState();
    }

    // スキャン完了
    else if (event is OnCompleteScanningEvent) {
      yield ScannedState(
        scannedData: event.scannedData,
      );
    }
  }
}

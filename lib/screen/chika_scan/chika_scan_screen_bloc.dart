import 'package:chika_scan/model/camera_model.dart';
import 'package:chika_scan/repository/camera_repository.dart';
import 'package:chika_scan/screen/chika_scan/chika_scan_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChikaScanScreenBloc
    extends Bloc<ChikaScanScreenEvent, ChikaScanScreenState> {
  @override
  String toString() => "地下スキャン画面";

  final CameraRepository cameraRepository;

  ChikaScanScreenBloc({
    @required this.cameraRepository,
  });

  @override
  ChikaScanScreenState get initialState => UninitializedState();

  @override
  Stream<ChikaScanScreenState> mapEventToState(
      ChikaScanScreenEvent event) async* {
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

    // カメラ切り替え要求
    else if (event is OnRequestSwitchingCameraEvent) {
      yield CameraSwitchingState();
    }

    // カメラ切り替え完了
    else if (event is OnCompleteSwitchingCameraEvent) {
      yield CameraSwitchedState();
    }

    // 写真撮影準備要求
    else if (event is OnRequestPreparingToTakePictureEvent) {
      yield ToTakePicturePreparingState();
    }

    // 写真撮影準備完了
    else if (event is OnCompletePreparingToTakePictureEvent) {
      yield ToTakePicturePreparedState();
    }

    // 写真撮影要求
    else if (event is OnRequestTakingPictureEvent) {
      yield PictureTakingState();
    }

    // 写真撮影完了
    else if (event is OnCompleteTakingPictureEvent) {
      yield PictureTookState();
    }
  }
}

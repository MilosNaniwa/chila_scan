import 'package:chika_scan/data_provider/camera_data_provider.dart';
import 'package:chika_scan/model/camera_model.dart';
import 'package:flutter/foundation.dart';

class CameraRepository {
  final CameraDataProvider cameraDataProvider;

  CameraRepository({
    @required this.cameraDataProvider,
  });

  Future<CameraModel> getAvailableCamera() async {
    List availableCameraList = await cameraDataProvider.getAvailableCameras();

    return CameraModel(
      availableCameraList: availableCameraList,
    );
  }
}

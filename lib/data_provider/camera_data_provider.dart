import 'package:camera/camera.dart';

class CameraDataProvider {
  Future<List<CameraDescription>> getAvailableCameras() async {
    return availableCameras();
  }
}

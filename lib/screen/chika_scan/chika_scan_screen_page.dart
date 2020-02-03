import 'dart:io';

import 'package:camera/camera.dart';
import 'package:chika_scan/common/custom_exception.dart';
import 'package:chika_scan/common/error_code.dart';
import 'package:chika_scan/data_provider/camera_data_provider.dart';
import 'package:chika_scan/model/camera_model.dart';
import 'package:chika_scan/model/eyes_position_model.dart';
import 'package:chika_scan/repository/camera_repository.dart';
import 'package:chika_scan/screen/chika_scan/chika_scan_screen.dart';
import 'package:chika_scan/screen/preview/preview_screen_page.dart';
import 'package:chika_scan/util/chika_painter_util.dart';
import 'package:chika_scan/util/scanner_util.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ChikaScanScreenPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChikaScanScreenPage();
}

class _ChikaScanScreenPage extends State<ChikaScanScreenPage> {
  ChikaScanScreenBloc _bloc;

  CameraRepository _cameraRepository;

  CameraDataProvider _cameraDataProvider;

  CameraController _cameraController;
  CameraModel _cameraModel;

  FaceDetector _faceDetector;

  ScannerUtil _scannerUtil;

  int _currentCamera;
  static const backCamera = 0;
  static const frontCamera = 1;

  bool _shouldSkipScanning;

  bool _isDetected;

  EyesPositionModel _eyesPositionModel;

  @override
  void initState() {
    super.initState();

    // 画面の向きをポートレートモード（縦向き）に固定する
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _currentCamera = backCamera;

    _shouldSkipScanning = false;
    _isDetected = false;

    _cameraController = CameraController(
      null,
      null,
    );

    _faceDetector = FirebaseVision.instance.faceDetector(
      FaceDetectorOptions(
        enableLandmarks: true,
        mode: FaceDetectorMode.fast,
      ),
    );
    _scannerUtil = ScannerUtil();

    _cameraDataProvider = CameraDataProvider();

    _cameraRepository = CameraRepository(
      cameraDataProvider: _cameraDataProvider,
    );

    _bloc = ChikaScanScreenBloc(
      cameraRepository: _cameraRepository,
    );

    _bloc.add(
      OnRequestInitializingEvent(),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _faceDetector.close();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _bloc,
      listener: (context, state) async {
        // 初期化後
        if (state is InitializedState) {
          _cameraModel = state.cameraModel;

          _cameraController = CameraController(
            _cameraModel.availableCameraList[_currentCamera],
            ResolutionPreset.low,
          );

          try {
            await _cameraController.initialize();

            _bloc.add(
              OnRequestScanningEvent(),
            );
          } on CameraException catch (e) {
            print(e);
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("エラー"),
                content: Text("カメラを利用できません。\nカメラの利用権限をご確認ください。"),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("OK"),
                  ),
                ],
              ),
            );

            _bloc.add(
              OnCompleteRenderingEvent(),
            );
          } catch (e) {
            print(e);
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("エラー"),
                content: Text("予期せぬエラーが発生しました。\n開発者へご連絡ください。"),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("OK"),
                  ),
                ],
              ),
            );

            _bloc.add(
              OnCompleteRenderingEvent(),
            );
          }
        }

        // スキャン中
        else if (state is ScanningState) {
          if (_cameraController.value.isStreamingImages) {
            return;
          }

          _cameraController.startImageStream(
            (CameraImage availableImage) async {
              if (_shouldSkipScanning) {
                return;
              }

              _shouldSkipScanning = true;

              final FirebaseVisionImageMetadata metadata =
                  FirebaseVisionImageMetadata(
                rawFormat: availableImage.format.raw,
                size: Size(
                  availableImage.width.toDouble(),
                  availableImage.height.toDouble(),
                ),
                rotation: _rotationIntToImageRotation(
                  rotation: _cameraModel
                      .availableCameraList[_currentCamera].sensorOrientation,
                ),
                planeData: availableImage.planes
                    .map(
                      (currentPlane) => FirebaseVisionImagePlaneMetadata(
                        bytesPerRow: currentPlane.bytesPerRow,
                        height: currentPlane.height,
                        width: currentPlane.width,
                      ),
                    )
                    .toList(),
              );

              final FirebaseVisionImage visionImage =
                  FirebaseVisionImage.fromBytes(
                availableImage.planes.first.bytes,
                metadata,
              );
              final List<Face> faceList = await _faceDetector.processImage(
                visionImage,
              );

              if (faceList.length != 0) {
                try {
                  setState(() {
                    _eyesPositionModel = _scannerUtil.detectPositionOfEyes(
                      faceList: faceList,
                      imageWidth: availableImage.width.toDouble(),
                      imageHeight: availableImage.height.toDouble(),
                      isUsedFrontCamera: _currentCamera == frontCamera,
                      campusWidth: MediaQuery.of(context).size.width,
                      campusHeight: MediaQuery.of(context).size.height,
                    );

                    _isDetected = true;
                    _shouldSkipScanning = false;
                  });
                } on CustomException catch (e) {
                  if (e.errorCode == ErrorCode.cannotDetectEyes) {
                    setState(() {
                      _isDetected = false;
                      _shouldSkipScanning = false;
                    });
                  }
                } catch (e, stackTrace) {
                  print(e);
                  print(stackTrace);
                  // TODO エラーレポート処理を実装
                  throw e;
                }
              } else {
                setState(() {
                  _isDetected = false;
                  _shouldSkipScanning = false;
                });
              }
            },
          ).catchError(
            (error) => print(error),
          );
        }

        // カメラ切り替え中
        else if (state is CameraSwitchingState) {
          showDialog(
            context: (context),
            builder: (context) => Center(
              child: CircularProgressIndicator(),
            ),
          );

          _isDetected = false;
          _shouldSkipScanning = false;

          await _cameraController.stopImageStream();
          await _cameraController.dispose();
          _cameraController = CameraController(
            null,
            null,
          );

          if (_currentCamera == backCamera) {
            _currentCamera = frontCamera;
          } else {
            _currentCamera = backCamera;
          }

          _cameraController = CameraController(
            _cameraModel.availableCameraList[_currentCamera],
            ResolutionPreset.low,
          );

          await Future.delayed(
            Duration(
              seconds: 1,
            ),
          );

          _bloc.add(
            OnCompleteSwitchingCameraEvent(),
          );
        }

        // カメラ切り替え後
        else if (state is CameraSwitchedState) {
          try {
            await _cameraController.initialize();

            Navigator.of(context).pop();

            _bloc.add(
              OnRequestScanningEvent(),
            );
          } on CameraException catch (e) {
            print(e);
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("エラー"),
                content: Text("カメラを利用できません。\nカメラの利用権限をご確認ください。"),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("OK"),
                  ),
                ],
              ),
            );

            _bloc.add(
              OnCompleteRenderingEvent(),
            );
          } catch (e) {
            print(e);
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("エラー"),
                content: Text("予期せぬエラーが発生しました。\n開発者へご連絡ください。"),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("OK"),
                  ),
                ],
              ),
            );

            _bloc.add(
              OnCompleteRenderingEvent(),
            );
          }
        }

        // 写真撮影準備中
        else if (state is ToTakePicturePreparingState) {
          await _cameraController.stopImageStream();

          _bloc.add(
            OnCompletePreparingToTakePictureEvent(),
          );
        }

        // 写真撮影準備後
        else if (state is ToTakePicturePreparedState) {
          _bloc.add(
            OnRequestTakingPictureEvent(),
          );
        }

        // 写真撮影中
        else if (state is PictureTakingState) {
          final fileName = DateTime.now().toString();

          final path = (await getTemporaryDirectory()).path + '$fileName.png';

          await _cameraController.takePicture(path);

          final compressedImage = await FlutterImageCompress.compressWithFile(
            path,
          );

          await File(path).writeAsBytes(compressedImage);

          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PreviewScreenPage(
                imageFilePath: path,
                isUsedFrontCamera: _currentCamera == frontCamera,
              ),
              fullscreenDialog: true,
            ),
          );

          _bloc.add(
            OnCompleteTakingPictureEvent(),
          );
        }

        // 写真撮影後
        else if (state is PictureTookState) {
          _bloc.add(
            OnRequestScanningEvent(),
          );
        }
      },
      child: BlocBuilder(
        bloc: _bloc,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.black87,
            body: _cameraController.value.isInitialized
                ? Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          AspectRatio(
                            aspectRatio: 1 /
                                _cameraController.value.previewSize.aspectRatio,
                            child: CameraPreview(
                              _cameraController,
                            ),
                          ),
                          _isDetected
                              ? CustomPaint(
                                  size: Size(
                                    MediaQuery.of(context).size.width,
                                    MediaQuery.of(context).size.height,
                                  ),
                                  painter: ChikaPainter(
                                    position1:
                                        _eyesPositionModel.leftEyePosition,
                                    position2:
                                        _eyesPositionModel.rightEyePosition,
                                  ),
                                )
                              : Container(),
                          Column(
                            children: <Widget>[
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.6,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  SizedBox(
                                    width: 45.0,
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.camera,
                                    ),
                                    onPressed: () {
                                      _bloc.add(
                                        OnRequestPreparingToTakePictureEvent(),
                                      );
                                    },
                                    color: Colors.white,
                                    iconSize: 45.0,
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.switch_camera,
                                    ),
                                    onPressed: () {
                                      _bloc.add(
                                        OnRequestSwitchingCameraEvent(),
                                      );
                                    },
                                    color: Colors.white,
                                    iconSize: 45.0,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  )
                : Container(),
          );
        },
      ),
    );
  }

  static ImageRotation _rotationIntToImageRotation({
    @required int rotation,
  }) {
    switch (rotation) {
      case 0:
        return ImageRotation.rotation0;
      case 90:
        return ImageRotation.rotation90;
      case 180:
        return ImageRotation.rotation180;
      default:
        assert(rotation == 270);
        return ImageRotation.rotation270;
    }
  }
}

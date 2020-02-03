import 'dart:io';

import 'package:chika_scan/common/custom_exception.dart';
import 'package:chika_scan/common/error_code.dart';
import 'package:chika_scan/model/eyes_position_model.dart';
import 'package:chika_scan/screen/preview/preview_screen.dart';
import 'package:chika_scan/util/chika_painter_util.dart';
import 'package:chika_scan/util/scanner_util.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image/image.dart' as imgLib;

class PreviewScreenPage extends StatefulWidget {
  final String imageFilePath;
  final bool isUsedFrontCamera;

  PreviewScreenPage({
    @required this.imageFilePath,
    @required this.isUsedFrontCamera,
  });

  @override
  State<StatefulWidget> createState() => _PreviewScreenPage();
}

class _PreviewScreenPage extends State<PreviewScreenPage> {
  PreviewScreenBloc _bloc;

  ScannerUtil _scannerUtil;

  FaceDetector _faceDetector;

  EyesPositionModel _eyesPositionModel;

  Image _imageFile;
  imgLib.Image _imgLibFile;

  bool _isDetected;

  @override
  void initState() {
    super.initState();

    _isDetected = false;

    _imageFile = Image.file(
      File(
        widget.imageFilePath,
      ),
    );

    _imgLibFile = imgLib.decodeImage(
      File(
        widget.imageFilePath,
      ).readAsBytesSync(),
    );

    _faceDetector = FirebaseVision.instance.faceDetector(
      FaceDetectorOptions(
        enableLandmarks: true,
        mode: FaceDetectorMode.accurate,
      ),
    );

    _scannerUtil = ScannerUtil();

    _bloc = PreviewScreenBloc();

    _bloc.add(
      OnRequestInitializingEvent(),
    );
  }

  @override
  void dispose() {
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
          print("width: ${_imgLibFile.width}");
          print("height: ${_imgLibFile.height}");

          final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(
            File(
              widget.imageFilePath,
            ),
          );

          final List<Face> faceList = await _faceDetector.processImage(
            visionImage,
          );

          if (faceList.length != 0) {
            try {
              _eyesPositionModel = _scannerUtil.detectPositionOfEyes(
                faceList: faceList,
                imageWidth: _imgLibFile.width.toDouble(),
                imageHeight: _imgLibFile.height.toDouble(),
                isUsedFrontCamera: widget.isUsedFrontCamera,
                campusWidth: MediaQuery.of(context).size.width * 0.9,
                campusHeight: _imgLibFile.height *
                    (MediaQuery.of(context).size.width *
                        0.9 /
                        _imgLibFile.width),
              );
              _isDetected = true;

              print(_eyesPositionModel.leftEyePosition);
              print(_eyesPositionModel.rightEyePosition);
            } on CustomException catch (e) {
              if (e.errorCode == ErrorCode.cannotDetectEyes) {
                print("目を検出できませんでした");
              }
            } catch (e, stackTrace) {
              print(e);
              print(stackTrace);
              // TODO エラーレポート処理を実装
              throw e;
            }
          } else {
            print("顔を検出できませんでした");
          }

          _bloc.add(
            OnCompleteRenderingEvent(),
          );
        }
      },
      child: BlocBuilder(
        bloc: _bloc,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text("プレビュー"),
            ),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      SizedBox(
                        child: _imageFile,
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: _imgLibFile.height *
                            (MediaQuery.of(context).size.width *
                                0.9 /
                                _imgLibFile.width),
                      ),
                      _isDetected
                          ? CustomPaint(
                              size: Size(
                                MediaQuery.of(context).size.width * 0.9,
                                _imgLibFile.height *
                                    (MediaQuery.of(context).size.width *
                                        0.9 /
                                        _imgLibFile.width),
                              ),
                              painter: ChikaPainter(
                                position1: _eyesPositionModel.leftEyePosition,
                                position2: _eyesPositionModel.rightEyePosition,
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

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
          final FirebaseVisionImage visionImage =
              FirebaseVisionImage.fromFilePath(
            widget.imageFilePath,
          );

          final List<Face> faceList = await _faceDetector.processImage(
            visionImage,
          );

          if (faceList.length != 0) {
            try {
              _eyesPositionModel = _scannerUtil.detectPositionOfEyes(
                faceList: faceList,
                imageWidth: _imageFile.width,
                imageHeight: _imageFile.height,
                isUsedFrontCamera: widget.isUsedFrontCamera,
                campusWidth: _imageFile.width,
                campusHeight: _imageFile.height,
              );
            } on CustomException catch (e) {
              if (e.errorCode == ErrorCode.cannotDetectEyes) {
                print("検出できませんでした");
              }
            } catch (e) {
              // TODO エラーレポート処理を実装
              throw e;
            }
          } else {
            print("検出できませんでした");
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
            backgroundColor: Colors.black87,
            appBar: AppBar(
              title: Text("プレビュー"),
            ),
            body: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Image.file(
                      File(
                        widget.imageFilePath,
                      ),
                    ),
                    _isDetected
                        ? CustomPaint(
                            size: Size(
                              MediaQuery.of(context).size.width,
                              MediaQuery.of(context).size.height,
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
          );
        },
      ),
    );
  }
}

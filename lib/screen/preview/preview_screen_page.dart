import 'dart:io';
import 'dart:ui' as ui;

import 'package:chika_scan/common/custom_exception.dart';
import 'package:chika_scan/common/error_code.dart';
import 'package:chika_scan/model/face_landmark_model.dart';
import 'package:chika_scan/screen/preview/preview_screen.dart';
import 'package:chika_scan/util/chika_painter_util.dart';
import 'package:chika_scan/util/emoji_painter_util.dart';
import 'package:chika_scan/util/scanner_util.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image/image.dart' as imgLib;

class PreviewScreenPage extends StatefulWidget {
  final String imageFilePath;
  final bool isUsedFrontCamera;
  final bool isEnabledChikaMode;

  PreviewScreenPage({
    @required this.imageFilePath,
    @required this.isUsedFrontCamera,
    @required this.isEnabledChikaMode,
  });

  @override
  State<StatefulWidget> createState() => _PreviewScreenPage();
}

class _PreviewScreenPage extends State<PreviewScreenPage> {
  PreviewScreenBloc _bloc;

  ScannerUtil _scannerUtil;

  FaceDetector _faceDetector;

  List<FaceLandmarkModel> _faceLandmarkModelList;

  Image _imageFile;
  imgLib.Image _imgLibFile;

  bool _isDetected;

  GlobalKey _globalKey;

  @override
  void initState() {
    super.initState();

    _globalKey = GlobalKey();

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
              _faceLandmarkModelList = _scannerUtil.detectLandmarks(
                faceList: faceList,
                imageWidth: _imgLibFile.width.toDouble(),
                imageHeight: _imgLibFile.height.toDouble(),
                isUsedFrontCamera: false,
                campusWidth: MediaQuery.of(context).size.width * 0.9,
                campusHeight: _imgLibFile.height *
                    (MediaQuery.of(context).size.width *
                        0.9 /
                        _imgLibFile.width),
              );
              _isDetected = true;
            } on CustomException catch (e) {
              if (e.errorCode == ErrorCode.cannotDetectLandmark) {
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: Text("目を検出できませんでした"),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("OK"),
                      )
                    ],
                  ),
                );
              }
            } catch (e, stackTrace) {
              print(e);
              print(stackTrace);
              // TODO エラーレポート処理を実装
              throw e;
            }
          } else {
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: Text("顔を検出できませんでした"),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("OK"),
                  )
                ],
              ),
            );
          }

          _bloc.add(
            OnCompleteRenderingEvent(),
          );
        }

        // 画像共有中
        else if (state is ImageSharingState) {
          RenderRepaintBoundary boundary =
              _globalKey.currentContext.findRenderObject();

          ui.Image image = await boundary.toImage(
            pixelRatio: 3.0,
          );

          final byteData = await image.toByteData(
            format: ui.ImageByteFormat.png,
          );

          await Share.file(
            '地下化',
            '地下化.png',
            byteData.buffer.asUint8List(),
            'image/png',
            text: '地下化しました',
          );

          _bloc.add(
            OnCompleteSharingImageEvent(),
          );
        }

        // 画像共有後
        else if (state is ImageSharedState) {
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
            body: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                    ),
                    RepaintBoundary(
                      key: _globalKey,
                      child: Stack(
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
                              ? Stack(
                                  children: _faceLandmarkModelList.map(
                                    (model) {
                                      return CustomPaint(
                                        size: Size(
                                          MediaQuery.of(context).size.width *
                                              0.9,
                                          _imgLibFile.height *
                                              (MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.9 /
                                                  _imgLibFile.width),
                                        ),
                                        painter: widget.isEnabledChikaMode
                                            ? ChikaPainter(
                                                position1:
                                                    model.leftEyePosition,
                                                position2:
                                                    model.rightEyePosition,
                                              )
                                            : EmojiPainter(
                                                centerPosition:
                                                    model.topCenterPosition,
                                                faceSize: model.faceSize * 2,
                                              ),
                                      );
                                    },
                                  ).toList(),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.share,
                      ),
                      iconSize: 45.0,
                      onPressed: () {
                        _bloc.add(
                          OnRequestSharingImageEvent(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

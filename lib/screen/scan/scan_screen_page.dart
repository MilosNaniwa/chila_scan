import 'package:camera/camera.dart';
import 'package:chika_scan/data_provider/camera_data_provider.dart';
import 'package:chika_scan/repository/camera_repository.dart';
import 'package:chika_scan/screen/scan/scan_screen.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class ScanScreenPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScanScreenPage();
}

class _ScanScreenPage extends State<ScanScreenPage> {
  ScanScreenBloc _bloc;

  CameraRepository _cameraRepository;

  CameraDataProvider _cameraDataProvider;

  CameraController _cameraController;

  bool _shouldSkipScanning;

  @override
  void initState() {
    super.initState();

    _shouldSkipScanning = true;

    _cameraController = CameraController(
      null,
      null,
    );

    _cameraDataProvider = CameraDataProvider();

    _cameraRepository = CameraRepository(
      cameraDataProvider: _cameraDataProvider,
    );

    _bloc = ScanScreenBloc(
      cameraRepository: _cameraRepository,
    );

    _bloc.add(
      OnRequestInitializingEvent(),
    );
  }

  @override
  void dispose() {
    _bloc.close();
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _bloc,
      listener: (context, state) async {
        // 初期化後
        if (state is InitializedState) {
          _cameraController = CameraController(
            state.cameraModel.availableCameraList.first,
            ResolutionPreset.high,
          );

          try {
            await _cameraController.initialize();

            _bloc.add(
              OnRequestScanningEvent(),
            );
          } on CameraException catch (e) {
            print(e);
            Navigator.of(context).pop();
          } catch (e) {
            print(e);
            Navigator.of(context).pop();
          }
        }

        // スキャン中
        else if (state is ScanningState) {
          // ストリーム開始直後はメモリ上に前回のデータが残存している場合があるため、
          // 新規ストリーム画像で上書きされるまで一定時間処理をスキップさせる
          Future.delayed(
            Duration(
              seconds: 1,
            ),
          ).then(
            (value) => _shouldSkipScanning = false,
          );

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
              final BarcodeDetector barcodeDetector =
                  FirebaseVision.instance.barcodeDetector();
              final List<Barcode> barcodeList =
                  await barcodeDetector.detectInImage(visionImage);

              await barcodeDetector.close();

              if (barcodeList.length != 0) {
                _cameraController.stopImageStream().then(
                  (value) {
                    _bloc.add(
                      OnCompleteScanningEvent(
                        scannedData: barcodeList.first.rawValue,
                      ),
                    );
                  },
                ).catchError(
                  (error) {
                    print(error);
                  },
                );
              } else {
                _shouldSkipScanning = false;
              }
            },
          );
        }

        // スキャン後
        else if (state is ScannedState) {
          bool isUrlQr = await canLaunch(state.scannedData);

          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Center(
                    child: Text(
                      state.scannedData,
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                FlatButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close),
                  label: Text("閉じる"),
                ),
                FlatButton.icon(
                  onPressed: isUrlQr
                      ? () async {
                          await launch(state.scannedData);

                          Navigator.of(context).pop();
                        }
                      : null,
                  icon: Icon(Icons.launch),
                  label: Text("開く"),
                ),
                FlatButton.icon(
                  onPressed: () async {
                    final data = ClipboardData(
                      text: state.scannedData,
                    );
                    await Clipboard.setData(data);
                  },
                  icon: Icon(Icons.content_copy),
                  label: Text("コピー"),
                ),
              ],
            ),
          );

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
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width,
                        child: ClipRect(
                          child: OverflowBox(
                            alignment: Alignment.center,
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.width /
                                    _cameraController.value.aspectRatio,
                                child: CameraPreview(
                                  _cameraController,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

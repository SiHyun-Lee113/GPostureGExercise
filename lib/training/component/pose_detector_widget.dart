import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:good_posture_good_exercise/common/const/constant.dart';
import 'package:good_posture_good_exercise/common/const/style.dart';
import 'package:good_posture_good_exercise/main.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

enum ScreenMode { liveFeed, gallery }

class PoseDetectorWidget extends StatefulWidget {
  PoseDetectorWidget({
    Key? key,
    required this.title,
    required this.customPaint,
    this.text,
    required this.count,
    required this.onImage,
    required this.onStart,
    required this.onEnd,
    this.onScreenModeChanged,
    this.initialDirection = CameraLensDirection.front,
    required this.checkBalance,
  }) : super(key: key);

  final String title;
  final CustomPaint? customPaint;
  final String? text;
  final int count;
  // google mlkit
  final Function(InputImage inputImage) onImage;
  final Function() onStart;
  final Function() onEnd;
  final Function() checkBalance;
  final Function(ScreenMode mode)? onScreenModeChanged;
  final CameraLensDirection initialDirection;

  @override
  _PoseDetectorWidgetState createState() => _PoseDetectorWidgetState();
}

class _PoseDetectorWidgetState extends State<PoseDetectorWidget> {
  CameraController? _controller;
  num _cameraIndex = 0;
  double zoomLevel = 0.0, minZoomLevel = 0.0, maxZoomLevel = 0.0;
  bool _changingCameraLens = false;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(cameras[0], ResolutionPreset.max);

    if (cameras.any(
      (element) =>
          element.lensDirection == widget.initialDirection &&
          element.sensorOrientation == 90,
    )) {
      _cameraIndex = cameras.indexOf(
        cameras.firstWhere((element) =>
            element.lensDirection == widget.initialDirection &&
            element.sensorOrientation == 90),
      );
    } else {
      _cameraIndex = cameras.indexOf(
        cameras.firstWhere(
          (element) => element.lensDirection == widget.initialDirection,
        ),
      );
    }

    _startLiveFeed();
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _checkBalance();

    double deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: null,
      body: Column(
        children: [
          Expanded(
            child: _liveFeedBody(),
          ),
          SizedBox(
            height: 32,
          ),
          SizedBox(
            height: TRAINING_BOTTOM_MARGIN,
            child: _renderFooter(),
          ),
        ],
      ),
    );
  }

  bool checkFlag = false;

  void _checkBalance() {
    while (checkFlag) {
      Future.delayed(const Duration(milliseconds: 500));
      widget.checkBalance;
    }
  }

  _renderFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('운동 정보'), Text('운동 개수 ${widget.count}')],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: PRIMARY_COLOR,
              minimumSize: const Size.fromHeight(40),
            ),
            onPressed: () {
              widget.onEnd();
            },
            child: Text('그만하기'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: PRIMARY_COLOR,
              minimumSize: const Size.fromHeight(40),
            ),
            onPressed: () {
              widget.onStart();
              // setState(() {
              //   checkFlag = !checkFlag;
              // });
            },
            child: Text('시작하기'),
          ),
        ],
      ),
    );
  }

  Widget _liveFeedBody() {
    if (_controller?.value.isInitialized == false) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * _controller!.value.aspectRatio;

    if (scale < 1) scale = 1 / scale;

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Transform.scale(
            scale: scale,
            child: Center(
              child: _changingCameraLens
                  ? Center(
                      child: const Text('Changing camera lens'),
                    )
                  : CameraPreview(_controller!),
            ),
          ),
          if (widget.customPaint != null) widget.customPaint!,
          Positioned(
            bottom: 100,
            left: 50,
            right: 50,
            child: Slider(
              value: zoomLevel,
              min: minZoomLevel,
              max: maxZoomLevel,
              onChanged: (newSliderValue) {
                setState(() {
                  zoomLevel = newSliderValue;
                  _controller!.setZoomLevel(zoomLevel);
                });
              },
              divisions: (maxZoomLevel - 1).toInt() < 1
                  ? null
                  : (maxZoomLevel - 1).toInt(),
            ),
          )
        ],
      ),
    );
  }

  Future _startLiveFeed() async {
    var cameras = await availableCameras();
    final camera = cameras[_cameraIndex.toInt()];
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller?.getMinZoomLevel().then((value) {
        zoomLevel = value;
        minZoomLevel = value;
      });
      _controller?.getMaxZoomLevel().then((value) {
        maxZoomLevel = value;
      });
      _controller?.startImageStream(_processCameraImage);
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  Future _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final camera = cameras[_cameraIndex.toInt()];
    // google mlkit
    final imageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (imageRotation == null) return;

    // google mlkit
    final inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw);
    if (inputImageFormat == null) return;

    final planeData = image.planes.map(
      (Plane plane) {
        // google mlkit
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    // google mlkit
    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    // google mlkit
    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    widget.onImage(inputImage);
  }
}

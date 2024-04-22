import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:good_posture_good_exercise/training/module/pose_detector/pose_painter.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class CameraController extends GetxController {
  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());

  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? customPaint;
  String? text;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    _canProcess = false;
    _poseDetector.close();
    super.onClose();
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;

    final poses = await _poseDetector.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = PosePainter(poses, inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      customPaint = CustomPaint(painter: painter);
    } else {
      text = 'Poses found: ${poses.length}\n\n';
      // TODO: set _customPaint to draw landmarks on top of image
      customPaint = null;
    }

    Map<String, int> map = {};

    map[''];

    // if (poses.isNotEmpty) {
    //   for (var pose in poses) {
    //     print(
    //         '[POSE : Nose x]  : ${pose.landmarks[PoseLandmarkType.nose]?.x.toString()}');
    //     print(
    //         '[POSE : Nose y]  : ${pose.landmarks[PoseLandmarkType.nose]?.y.toString()}');
    //   }
    // }
    _isBusy = false;
    update();
  }
}

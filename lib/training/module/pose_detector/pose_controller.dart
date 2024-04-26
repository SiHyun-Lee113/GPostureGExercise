import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:good_posture_good_exercise/dev_utils/logger.dart';
import 'package:good_posture_good_exercise/training/model/coordinate.dart';
import 'package:good_posture_good_exercise/training/model/training_real_time_model.dart';
import 'package:good_posture_good_exercise/training/model/training_reference_model.dart';
import 'package:good_posture_good_exercise/training/module/pose_detector/pose_painter.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseController extends GetxController {
  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());

  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? customPaint;
  String? text;
  TrainingRealTimeModel trRealTimeModel = TrainingRealTimeModel();

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

    late TrainingReferenceModel trainingReferenceModel;

    if (poses.isNotEmpty) {
      trainingReferenceModel = addCoordinate(poses);
    }

    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = PosePainter(poses, inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation, trainingReferenceModel);
      customPaint = CustomPaint(painter: painter);
    } else {
      text = 'Poses found: ${poses.length}\n\n';
      // TODO: set _customPaint to draw landmarks on top of image
      customPaint = null;
    }

    _isBusy = false;
    update();
  }

  void checkHorizontal(List<Pose> poses) {}

  void checkVertical() {}

  void printHigh() {
    Get.back();
    var calXHighRow = trRealTimeModel.calXHighRow(trRealTimeModel.rightHand);
    siHyunLogger("high x : ${calXHighRow.x}, row x : ${calXHighRow.y}");
    var calYHighRow = trRealTimeModel.calYHighRow(trRealTimeModel.rightHand);
    siHyunLogger("high y : ${calXHighRow.y}, row y : ${calXHighRow.y}");
  }

  TrainingReferenceModel addCoordinate(List<Pose> poses) {
    for (var pose in poses) {
      var leftHand = Coordinate(
          pose.landmarks[PoseLandmarkType.leftWrist]?.x ?? 0,
          pose.landmarks[PoseLandmarkType.leftWrist]?.y ?? 0);
      var rightHand = Coordinate(
          pose.landmarks[PoseLandmarkType.rightWrist]?.x ?? 0,
          pose.landmarks[PoseLandmarkType.rightWrist]?.y ?? 0);
      var leftShoulder = Coordinate(
          pose.landmarks[PoseLandmarkType.leftShoulder]?.x ?? 0,
          pose.landmarks[PoseLandmarkType.leftShoulder]?.y ?? 0);
      var rightShoulder = Coordinate(
          pose.landmarks[PoseLandmarkType.rightShoulder]?.x ?? 0,
          pose.landmarks[PoseLandmarkType.rightShoulder]?.y ?? 0);
      var leftElbow = Coordinate(
          pose.landmarks[PoseLandmarkType.leftElbow]?.x ?? 0,
          pose.landmarks[PoseLandmarkType.leftElbow]?.y ?? 0);
      var rightElbow = Coordinate(
          pose.landmarks[PoseLandmarkType.rightElbow]?.x ?? 0,
          pose.landmarks[PoseLandmarkType.rightElbow]?.y ?? 0);

      trRealTimeModel.addCoordinates(leftHand, rightHand, leftShoulder,
          rightShoulder, leftElbow, rightElbow);
    }

    return trRealTimeModel.calTrainingRFModel();
  }
}

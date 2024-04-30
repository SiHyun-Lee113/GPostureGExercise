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
  int count = 0;

  TrainingRealTimeModel trRealTimeModel = TrainingRealTimeModel();
  bool trainingFlag = false;

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
      trainingReferenceModel = await addCoordinate(poses);
    }

    countingTraining(poses);

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

  bool downFlag = false;
  bool upFlag = true;

  void countingTraining(List<Pose> poses) {
    late int yHighLeft;
    late int yRowLeft;
    late int yHighRight;
    late int yRowRight;
    try {
      var leftHandHR = trRealTimeModel.calYHighRow(trRealTimeModel.leftHand);
      yHighLeft = leftHandHR.y.ceil();
      yRowLeft = leftHandHR.x.ceil();
      var rightHandHR = trRealTimeModel.calYHighRow(trRealTimeModel.rightHand);
      yHighRight = rightHandHR.y.ceil();
      yRowRight = rightHandHR.x.ceil();
    } catch (e) {
      return;
    }
    int leftY = poses[poses.length - 1]
            .landmarks[PoseLandmarkType.leftWrist]
            ?.y
            .ceil() ??
        0;
    int rightY = poses[poses.length - 1]
            .landmarks[PoseLandmarkType.rightWrist]
            ?.y
            .ceil() ??
        0;

    if (downFlag) {
      if (leftY > yHighLeft && rightY > yHighRight) {
        upFlag = true;
        siHyunLogger("올라가유~~ 최댓값 : $yHighLeft, $yHighRight}");
        siHyunLogger("올라가는 주우우웅 $leftY, $rightY}");
      }
    }

    if (upFlag) {
      siHyunLogger("내려가유~~ 최솟값 : $yRowLeft, $yRowRight}");
      siHyunLogger("내려가는 주우우웅 $leftY, $rightY}");

      if (leftY < yRowLeft && rightY < yRowRight) {
        downFlag = true;
        siHyunLogger("내려가유~~ 최솟값 : $yRowLeft, $yRowRight}");
        siHyunLogger("내려가는 주우우웅 $leftY}");
        upFlag = false;
      }
    }

    if (downFlag && upFlag) {
      count++;
      downFlag = false;
    }
  }

  void printHigh() {
    Get.back();
    var calXHighRow = trRealTimeModel.calXHighRow(trRealTimeModel.leftHand);
    siHyunLogger("high x : ${calXHighRow.x}, row x : ${calXHighRow.y}");
    var calYHighRow = trRealTimeModel.calYHighRow(trRealTimeModel.leftHand);
    siHyunLogger("high y : ${calYHighRow.x}, row y : ${calYHighRow.y}");
    var length2 = trRealTimeModel.rightHand.length;

    siHyunLogger("아ㅏ아아아아아아ㅏㅇ나아앙$length2");
  }

  Future<TrainingReferenceModel> addCoordinate(List<Pose> poses) async {
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

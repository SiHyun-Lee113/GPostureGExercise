import 'package:assets_audio_player/assets_audio_player.dart';
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

  late final AssetsAudioPlayer _player = AssetsAudioPlayer.newPlayer();

  @override
  void onInit() {
    super.onInit();
    _player.open(
      Audio("assets/sound/training_count_sound_ten.mp3"),
      loopMode: LoopMode.single,
      autoStart: false,
      showNotification: false,
    );
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

  bool _soundPlay = false;

  void soundStart() {
    if (!_soundPlay) {
      _player.play();
      _soundPlay = true;
    } else {
      _player.stop();
      _player.dispose();
      _soundPlay = false;
    }
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

    try {
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
    } catch (e) {
      return;
    }

    _isBusy = false;
    update();
  }

  void checkHorizontal(List<Pose> poses) {}

  void checkVertical() {}

  void printHigh() {
    Get.back();
    var calXHighRow = trRealTimeModel.calXHighRow(trRealTimeModel.leftHand);
    siHyunLogger("high x : ${calXHighRow.x}, row x : ${calXHighRow.y}");
    var calYHighRow = trRealTimeModel.calYHighRow(trRealTimeModel.leftHand);
    siHyunLogger("high y : ${calYHighRow.x}, row y : ${calYHighRow.y}");
    var length2 = trRealTimeModel.rightHand.length;
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

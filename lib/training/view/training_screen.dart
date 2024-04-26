import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:good_posture_good_exercise/training/component/pose_detector_widget.dart';
import 'package:good_posture_good_exercise/training/module/pose_detector/pose_controller.dart';

class TrainingScreen extends GetView<PoseController> {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PoseController>(
      builder: (context) {
        if (controller == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return PoseDetectorWidget(
            title: '',
            customPaint: controller.customPaint,
            text: controller.text,
            onImage: (inputImage) {
              controller.processImage(inputImage);
            },
            onEnd: () {
              controller.printHigh();
            },
          );
        }
      },
    );
  }
}

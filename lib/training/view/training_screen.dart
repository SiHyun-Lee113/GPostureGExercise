import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:good_posture_good_exercise/training/component/pose_detector_widget.dart';
import 'package:good_posture_good_exercise/training/module/pose_detector/pose_controller.dart';

class TrainingScreen extends GetView<PoseController> {
  TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var _debounce = Timer(const Duration(milliseconds: 500), () {
      controller.checkHorizontal();
    });

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
            count: controller.count,
            onImage: (inputImage) {
              controller.processImage(inputImage);
            },
            onStart: () {
              controller.soundStart();
            },
            onEnd: () {
              controller.printHigh();
            },
            checkBalance: () {
              controller.checkHorizontal();
              controller.checkVertical();
            },
          );
        }
      },
    );
  }
}

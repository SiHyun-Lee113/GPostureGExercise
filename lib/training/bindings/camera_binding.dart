import 'package:get/get.dart';
import 'package:good_posture_good_exercise/training/module/pose_detector/pose_controller.dart';

class CameraBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(PoseController());
  }
}

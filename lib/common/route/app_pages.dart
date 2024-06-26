import 'package:get/get.dart';
import 'package:good_posture_good_exercise/common/view/home_screen.dart';
import 'package:good_posture_good_exercise/schedule/view/schedule_screen.dart';
import 'package:good_posture_good_exercise/training/bindings/camera_binding.dart';
import 'package:good_posture_good_exercise/training/view/training_screen.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: _Paths.TRAINING,
      page: () => TrainingScreen(),
      binding: CameraBinding(),
    ),
    GetPage(
      name: _Paths.SCHEDULE,
      page: () => const ScheduleScreen(),
    ),
  ];
}

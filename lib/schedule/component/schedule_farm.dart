import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:good_posture_good_exercise/common/const/style.dart';
import 'package:good_posture_good_exercise/common/route/app_pages.dart';

class ScheduleFarm extends StatelessWidget {
  const ScheduleFarm({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: PRIMARY_COLOR,
          minimumSize: const Size.fromHeight(50),
        ),
        onPressed: () {
          Get.toNamed(Routes.SCHEDULE);
        },
        child: Text('운동 일지'),
      ),
    );
  }
}

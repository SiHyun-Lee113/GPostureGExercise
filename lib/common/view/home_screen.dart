import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:good_posture_good_exercise/common/const/style.dart';
import 'package:good_posture_good_exercise/common/layout/default_layout.dart';
import 'package:good_posture_good_exercise/common/route/app_pages.dart';
import 'package:good_posture_good_exercise/schedule/component/schedule_farm.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '좋은 자세 좋은 운동',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            ScheduleFarm(),
            SizedBox(
              height: 16.0,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: PRIMARY_COLOR,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () {
                Get.toNamed(Routes.TRAINING);
              },
              child: Text('운동하러 가기'),
            ),
          ],
        ),
      ),
    );
  }
}

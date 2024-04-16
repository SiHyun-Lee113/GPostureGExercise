import 'package:flutter/material.dart';
import 'package:good_posture_good_exercise/common/layout/default_layout.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '운동 일지',
      child: Center(
        child: Text('HELLO'),
      ),
    );
  }
}

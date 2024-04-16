import 'package:flutter/material.dart';
import 'package:good_posture_good_exercise/common/layout/default_layout.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '자세 확인',
      child: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            Center(
              child: Text('TrainingScreen'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';

void siHyunLogger(String message) {
  DateTime dt = DateTime.now();
  debugPrint('[DEBUG MESSAGE] [$dt] : $message');
}

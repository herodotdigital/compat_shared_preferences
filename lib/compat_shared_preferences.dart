
import 'dart:async';

import 'package:flutter/services.dart';

class CompatSharedPreferences {
  static const MethodChannel _channel = MethodChannel('compat_shared_preferences');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}

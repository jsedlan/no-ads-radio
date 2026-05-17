import 'dart:io';

import 'package:flutter/services.dart';

class AndroidSettingsLauncher {
  const AndroidSettingsLauncher();

  static const MethodChannel _channel = MethodChannel(
    'com.example.no_ads_radio/android_settings',
  );

  Future<bool> openAppBatterySettings() async {
    if (!Platform.isAndroid) {
      return false;
    }

    try {
      return await _channel.invokeMethod<bool>('openAppBatterySettings') ??
          false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> isIgnoringBatteryOptimizations() async {
    if (!Platform.isAndroid) {
      return false;
    }

    try {
      return await _channel.invokeMethod<bool>(
            'isIgnoringBatteryOptimizations',
          ) ??
          false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}

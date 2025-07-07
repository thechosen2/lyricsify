import 'package:flutter/services.dart';

class OverlayService {
  static const _platform = MethodChannel('overlay_channel');

  static Future<void> startOverlay(String text) async {
    try {
      await _platform.invokeMethod('startOverlay', {'text': text});
    } on PlatformException catch (e) {
      print("Failed to start overlay: '${e.message}'.");
    }
  }

  static Future<void> updateOverlayText(String text) async {
    try {
      await _platform.invokeMethod('updateOverlay', {'text': text});
    } on PlatformException catch (e) {
      print("Failed to update overlay: '${e.message}'.");
    }
  }

  static Future<void> stopOverlay() async {
    try {
      await _platform.invokeMethod('stopOverlay');
    } on PlatformException catch (e) {
      print("Failed to stop overlay: '${e.message}'.");
    }
  }
}

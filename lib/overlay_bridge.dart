import 'package:flutter/services.dart';
const String ACTION_UPDATE_LYRICS = "com.example.my_app.UPDATE_LYRICS";


class OverlayBridge {
  static const platform = MethodChannel('overlay_channel');

  static Future<void> showOverlay(String text) async {
    try {
      await platform.invokeMethod('startOverlay', {"text": text});
    } on PlatformException catch (e) {
      print("Failed to start overlay: ${e.message}");
    }
  }

  static Future<void> updateOverlay(String text) async {
    try {
      await platform.invokeMethod('updateOverlay', {"text": text});
    } on PlatformException catch (e) {
      print("Failed to update overlay: ${e.message}");
    }
  }

  static Future<void> hideOverlay() async {
    try {
      await platform.invokeMethod('stopOverlay');
    } on PlatformException catch (e) {
      print("Failed to stop overlay: ${e.message}");
    }
  }
}

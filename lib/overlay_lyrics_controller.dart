import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'overlay_bridge.dart';
import 'overlay_service.dart';

class LyricsController with ChangeNotifier {
  static const MethodChannel _channel = MethodChannel('lyricsify.notification');

  List<Map<String, dynamic>> syncedLyrics = [];
  String currentLine = "";
  Timer? _timer;
  String? _currentTrack;
  String? _currentArtist;
  int _progressMs = 0;
  int _startTime = 0;

  Future<void> startFromNotification() async {
    print("[Lyricsify] Starting lyrics overlay (from notification listener)");

    await OverlayService.startOverlay("Lyricsify Running...");

    _channel.setMethodCallHandler((call) async {
      if (call.method == "onMetadataChanged") {
        final Map<String, dynamic> data = Map<String, dynamic>.from(call.arguments);
        _handleMetadata(data);
      }
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsed = now - _startTime;
      updateDisplayedLine(_progressMs + elapsed);
    });
  }

  void _handleMetadata(Map<String, dynamic> data) async {
    final title = data['track'];
    final artist = data['artist'];
    final progress = data['progress'] ?? 0;

    if (title == null || artist == null) return;

    if (_currentTrack != title || _currentArtist != artist) {
      print("[Lyricsify] Now playing: $artist - $title");
      _currentTrack = title;
      _currentArtist = artist;
      _progressMs = progress;
      _startTime = DateTime.now().millisecondsSinceEpoch;
      await fetchLyricsFromLrcLib(artist, title);
    } else {
      _progressMs = progress;
      _startTime = DateTime.now().millisecondsSinceEpoch;
    }
  }

  Future<void> fetchLyricsFromLrcLib(String artist, String title) async {
    final url =
        "https://lrclib.net/api/get?artist_name=${Uri.encodeComponent(artist)}&track_name=${Uri.encodeComponent(title)}";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      final rawLrc = result['syncedLyrics'];
      final lines = rawLrc.split('\n');
      final List<Map<String, dynamic>> parsed = [];

      for (final line in lines) {
        final match = RegExp(r"\[(\d+):(\d+)\.(\d+)\](.*)").firstMatch(line);
        if (match != null) {
          final minutes = int.parse(match.group(1)!);
          final seconds = int.parse(match.group(2)!);
          final millis = int.parse(match.group(3)!);
          final text = match.group(4)!.trim();
          final timeMs = minutes * 60000 + seconds * 1000 + millis * 10;
          parsed.add({"time": timeMs, "text": text, "track": title});
        }
      }

      print("[Lyricsify] Parsed ${parsed.length} lines from LRC");
      syncedLyrics = parsed;
    } else {
      print("[Lyricsify] Failed to fetch lyrics: ${response.statusCode}");
    }
  }

  void updateDisplayedLine(int progressMs) {
    for (int i = 0; i < syncedLyrics.length; i++) {
      if (progressMs < syncedLyrics[i]['time']) {
        final text = i == 0 ? "" : syncedLyrics[i - 1]['text'];
        if (text != currentLine) {
          currentLine = (text == null || text.trim().isEmpty) ? '♫' : text;
          print("[Lyricsify] Showing line: $currentLine");
          OverlayBridge.updateOverlay(currentLine);
        }
        break;
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _channel.setMethodCallHandler(null);
    _stopOverlayService();
    super.dispose();
  }

  Future<void> _stopOverlayService() async {
    try {
      const platform = MethodChannel('overlay_channel');
      await platform.invokeMethod('stopOverlay');
      print("[Lyricsify] Overlay service stopped.");
    } catch (e) {
      print("[Lyricsify] Failed to stop overlay: $e");
    }
  }

}

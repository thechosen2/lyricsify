import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'overlay_lyrics_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const platform = MethodChannel('overlay_channel');

  bool granted = false;
  try {
    granted = await platform.invokeMethod('checkAndRequestPermission');
  } on PlatformException catch (e) {
    print("Failed to request permission: ${e.message}");
  }

  if (!granted) {
    print('Overlay permission not granted!');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lyricsify Overlay',
      home: const LyricsApp(),
    );
  }
}

class LyricsApp extends StatefulWidget {
  const LyricsApp({super.key});

  @override
  State<LyricsApp> createState() => _LyricsAppState();
}

class _LyricsAppState extends State<LyricsApp> {
  late LyricsController controller;

  @override
  void initState() {
    super.initState();
    controller = LyricsController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lyricsify Overlay')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await controller.startFromNotification();
              },
              child: const Text('Start Lyrics Overlay'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // await controller.sendLyricsUpdate("This is the NEW test lyric!");
              },
              child: const Text('Send Test Lyrics Update'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.dispose,
              child: const Text('Stop & Exit'),
            ),
          ],
        ),
      ),
    );
  }
}

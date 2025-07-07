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
      title: 'Lyricsify',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      home: const LyricsApp(),
      debugShowCheckedModeBanner: false,
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
      appBar: AppBar(
        title: const Text('Lyricsify'),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: const Color(0xFF1E1E1E),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Lyrics Overlay Controller',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await controller.startFromNotification();
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Overlay'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      // await controller.sendLyricsUpdate("test lyric");
                    },
                    icon: const Icon(Icons.message),
                    label: const Text('Send Test Lyrics'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: controller.dispose,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop & Exit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

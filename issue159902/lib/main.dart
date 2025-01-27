import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:ui' as ui;
import 'dart:math';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: Center(child: RandomImageWidget())),
    );
  }
}

class RandomImageWidget extends StatefulWidget {
  @override
  _RandomImageWidgetState createState() => _RandomImageWidgetState();
}

class _RandomImageWidgetState extends State<RandomImageWidget>
    with SingleTickerProviderStateMixin {
  ui.Image? _image;
  late Ticker _ticker;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      // Generate a new random image each frame.
      _generateRandomImage();
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  Future<void> _generateRandomImage() async {
    final width = 1000;
    final height = 1000;

    // Create a PictureRecorder and Canvas to draw on.
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final paint = Paint()..style = PaintingStyle.fill;

    // Draw a random color for each pixel.
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        paint.color = Color.fromARGB(
          255,
          _random.nextInt(256),
          _random.nextInt(256),
          _random.nextInt(256),
        );
        canvas.drawRect(Rect.fromLTWH(x.toDouble(), y.toDouble(), 1, 1), paint);
      }
    }

    // Finalize drawing and create an image.
    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);

    // Update the state with the newly generated image.
    setState(() {
      _image?.dispose();
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RawImage(image: _image, width: 200, height: 200);
  }
}

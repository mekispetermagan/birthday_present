import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

// helper function to compute hue rotation for a single color
Color hueRotate(Color color, double angle) {
  final oldHSL = HSLColor.fromColor(color);
  final newHue = (oldHSL.hue + angle) % 360;
  final newHSL = oldHSL.withHue(newHue);
  return newHSL.toColor();
}

// helper function to compute hue rotation for image filtering
ColorFilter hueRotation(double degrees) {
  final radians = degrees * pi / 180;
  final cosA = cos(radians);
  final sinA = sin(radians);

  // The matrix approach is necessary for true hue rotation.
  // ColorFilter.mode() is simpler since it takes a color,
  // but it just tints pixels.
  return ColorFilter.matrix([
    0.213 + cosA * 0.787 - sinA * 0.213,
    0.715 - cosA * 0.715 - sinA * 0.715,
    0.072 - cosA * 0.072 + sinA * 0.928,
    0,
    0,
    0.213 - cosA * 0.213 + sinA * 0.143,
    0.715 + cosA * 0.285 + sinA * 0.140,
    0.072 - cosA * 0.072 - sinA * 0.283,
    0,
    0,
    0.213 - cosA * 0.213 - sinA * 0.787,
    0.715 - cosA * 0.715 + sinA * 0.715,
    0.072 + cosA * 0.928 + sinA * 0.072,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ]);
}

class RotatingHueImage extends StatefulWidget {
  final Image image;
  const RotatingHueImage({required this.image, super.key});

  @override
  State<RotatingHueImage> createState() => _RotatingHueImageState();
}

class _RotatingHueImageState extends State<RotatingHueImage>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _angle = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      // Every 0.1s = 100ms
      final seconds = elapsed.inMilliseconds / 1000;
      final newAngle = (seconds * 10) % 360; // 10°/s → 1° every 0.1s
      setState(() => _angle = newAngle);
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(colorFilter: hueRotation(_angle), child: widget.image);
  }
}

class RotatingHueText extends StatefulWidget {
  final Text text;
  const RotatingHueText({required this.text, super.key});

  @override
  State<RotatingHueText> createState() => _RotatingHueTextState();
}

class _RotatingHueTextState extends State<RotatingHueText>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final Color baseColor;
  double _angle = 0;

  @override
  void initState() {
    super.initState();
    baseColor = widget.text.style?.color ?? Colors.white;
    _ticker = createTicker((elapsed) {
      final seconds = elapsed.inMilliseconds / 1000;
      // 10 degree/s = 1 degree every 0.1s
      final newAngle = (seconds * 10) % 360;
      setState(() => _angle = newAngle);
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text.data!,
      style: widget.text.style!.copyWith(
        // color: HSLColor.fromAHSL(1, _angle, 0.5, 0.5).toColor(),
        color: hueRotate(baseColor, _angle),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Muzungu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal.shade900,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          shadowColor: Color.fromARGB(128, 63, 3, 71),
          elevation: 10,
        ),
      ),
      home: const MyHomePage(title: 'I Am One Lucky Muzungu'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    player.setReleaseMode(ReleaseMode.loop);
    player.play(AssetSource('audio/bg${Random().nextInt(3) + 1}.mp3'));
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title, style: GoogleFonts.baloo2()),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: RotatingHueImage(
                        image: Image.asset(
                          'assets/images/diamond.png',
                          width: 180,
                        ),
                      ),
                    ),
                    RotatingHueText(
                      text: Text(
                        "Patience is beautiful",
                        style: GoogleFonts.baloo2(
                          textStyle: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w500,
                            color: HSLColor.fromAHSL(1, 180, 1, 0.5).toColor(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        player.stop();
                        player.play(AssetSource('audio/bg1.mp3'));
                      },
                      child: Image.asset(
                        'assets/images/heart_red.png',
                        width: 36,
                      ),
                    ),
                  ),
                  const SizedBox(width: 36),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        player.stop();
                        player.play(AssetSource('audio/bg2.mp3'));
                      },
                      child: Image.asset(
                        'assets/images/heart_purple.png',
                        width: 36,
                      ),
                    ),
                  ),
                  const SizedBox(width: 36),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        player.stop();
                        player.play(AssetSource('audio/bg3.mp3'));
                      },
                      child: Image.asset(
                        'assets/images/heart_blue.png',
                        width: 36,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // body: Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: <Widget>[
      //       Padding(
      //         padding: const EdgeInsets.only(bottom: 24.0),
      //         child: RotatingHueImage(
      //           image: Image.asset('assets/images/diamond.png', width: 180),
      //         ),
      //       ),
      //       RotatingHueText(
      //         text: Text(
      //           "Patience is beautiful",
      //           style: GoogleFonts.baloo2(
      //             textStyle: TextStyle(
      //               fontSize: 36,
      //               fontWeight: FontWeight.w500,
      //               color: HSLColor.fromAHSL(1, 180, 1, 0.5).toColor(),
      //             ),
      //           ),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}

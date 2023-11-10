import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magic_8_ball/main.dart';
import 'package:provider/provider.dart';
import 'package:shake/shake.dart';

class MagicBall extends StatefulWidget {
  const MagicBall({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MagicBall> createState() => _MagicBallState();
}

List<String> magicResponses = [
  "assets/images/response_1.png",
  "assets/images/response_2.png",
  "assets/images/response_3.png",
  "assets/images/response_4.png",
  "assets/images/response_5.png",
  "assets/images/response_6.png",
  "assets/images/response_7.png",
  "assets/images/response_8.png",
  "assets/images/response_9.png",
  "assets/images/response_10.png",
  "assets/images/response_11.png",
  "assets/images/response_12.png",
  "assets/images/response_13.png",
  "assets/images/response_14.png",
  "assets/images/response_15.png",
  "assets/images/response_16.png",
  "assets/images/response_17.png",
  "assets/images/response_18.png",
  "assets/images/response_19.png",
  "assets/images/response_20.png",
];

class _MagicBallState extends State<MagicBall> {
  bool _visible = true;
  late Image img;
  Image gif1 = Image.asset("assets/images/waves_1.gif");
  Image gif2 = Image.asset("assets/images/waves_2.gif");
  Image gif3 = Image.asset("assets/images/waves_3.gif");
  Image gif4 = Image.asset("assets/images/waves_4.gif");
  Image gif5 = Image.asset("assets/images/waves_5.gif");
  Image gif6 = Image.asset("assets/images/waves_6.gif");
  Image magicWindow = Image.asset("assets/images/magic_window.png");
  Image bottomBar = Image.asset("assets/images/bottom_bar.png");
  Image ballHole = Image.asset("assets/images/ball_hole.png");
  Image triangle = Image.asset("assets/images/triangle.png");
  Image reveal = Image.asset(
      "assets/images/ball_hole.png"); // this one fades to transparent to reveal the answer, which has text color the same as bg color and a white/contrasting triangle
  Widget holder = Container();
/*   Widget ending = Stack(children: [
    Center(child: Image.asset("assets/images/triangle.png", height: 200)),
    Center(
        child:
            Text('Hello', style: TextStyle(fontSize: 24, color: Colors.green))),
    Center(
        child: AnimatedOpacity(
            opacity: _visible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 2000),
            child: Image.asset(
              "assets/images/ball_hole.png",
              color: Colors.green,
            ))),
  ]); */
  static var _random = new Random();
  static var _diceface = _random.nextInt(6) + 1;

  late ShakeDetector detector;

  void initState() {
    super.initState();
    img = Image.asset("assets/images/empty.png");

    detector = ShakeDetector.autoStart(
      onPhoneShake: () {
        /* ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shake!'),
          ),
        ); */
        _diceface = _random.nextInt(6) + 1;

        _visible = true;
        stop();
        getTimestamp();
        start();
        if (_diceface == 1) {
          heavyImpact();
          setState(() {
            img = gif1;
          });
        } else if (_diceface == 2) {
          heavyImpact();
          heavyImpact();
          setState(() {
            img = gif2;
          });
        } else if (_diceface == 3) {
          heavyImpact();
          setState(() {
            img = gif3;
          });
        } else if (_diceface == 4) {
          heavyImpact();
          setState(() {
            img = gif4;
          });
        } else if (_diceface == 5) {
          heavyImpact();
          heavyImpact();
          setState(() {
            img = gif5;
          });
        } else if (_diceface == 6) {
          heavyImpact();
          setState(() {
            img = gif6;
          });
        }
      },
      minimumShakeCount: 1,
      shakeSlopTimeMS: 670, // this is length of each gif
      shakeCountResetTime: 200,
      shakeThresholdGravity: 2.7,
    );

    /*  if () {
      print('greater than 5');
    } */
    // To close: detector.stopListening();
    // ShakeDetector.waitForStart() waits for user to call detector.startListening();
  }

  void getTimestamp() {
    context.read<ShakeTime>().setShake(detector.mShakeTimestamp);
  }

  static Future<void> heavyImpact() async {
    await SystemChannels.platform.invokeMethod<void>(
      'HapticFeedback.vibrate',
      'HapticFeedbackType.heavyImpact',
    );
  }

  bool active = false;
  Timer? timer;
  Timer? refresh;
  Stopwatch stopwatch = Stopwatch();
  Duration duration = const Duration(seconds: 2);

  String result = '';

  void start() {
    setState(() {
      active = true;
      timer = Timer(duration, () {
        stop();
        //img = reveal;
        //holder = ending;
        _visible = false;

        _diceface = _random.nextInt(20) + 1;
        result = magicResponses[_diceface];
      });
      stopwatch
        ..reset()
        ..start();
    });
  }

  void stop() {
    setState(() {
      active = false;
      timer?.cancel();
      stopwatch.stop();
    });
  }

  int secondsRemaining() {
    return duration.inSeconds -
        context.watch<ShakeTime>().shakeTime; //stopwatch.elapsed.inSeconds;
  }

  @override
  void dispose() {
    timer?.cancel();
    refresh?.cancel();
    stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            magicWindow,
            Align(alignment: Alignment.bottomCenter, child: bottomBar),
            ballHole,
            Stack(alignment: Alignment.center, children: [
              Image.asset(result, height: 200),
              AnimatedOpacity(
                  opacity: _visible ? 1.0 : 0.0,
                  duration: _visible
                      ? const Duration(milliseconds: 0)
                      : const Duration(milliseconds: 2000),
                  child: Image.asset(
                    "assets/images/ball_hole.png",
                  )),
            ]),
            img,
            holder,
          ],
        ),
      ),
    );
  }
}

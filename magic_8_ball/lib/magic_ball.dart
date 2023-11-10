import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magic_8_ball/main.dart';
import 'package:provider/provider.dart';
import 'package:shake/shake.dart';

class MagicBall extends StatefulWidget {
  const MagicBall({super.key, required this.offset});

  final Offset offset;

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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
  late AssetImage img;
  late AssetImage gif1;
  late AssetImage gif2;
  late AssetImage gif3;
  late AssetImage gif4;
  late AssetImage gif5;
  late AssetImage gif6;
  Image magicWindow =
      Image.asset(fit: BoxFit.fitHeight, "assets/images/magic_bg.png");
  Image bottomBar = Image.asset(
      alignment: Alignment.bottomCenter,
      fit: BoxFit.fitWidth,
      "assets/images/bottom_bar.png");
  Image topBar = Image.asset(
      alignment: Alignment.topCenter,
      fit: BoxFit.fitWidth,
      "assets/images/top_bar.png");
  Image ballHole = Image.asset("assets/images/ball_hole.png");
  Image triangle = Image.asset("assets/images/triangle.png");
  Image reveal = Image.asset(
      "assets/images/ball_hole.png"); // this one fades to transparent to reveal the answer, which has text color the same as bg color and a white/contrasting triangle
  Widget holder = Container();

  late Offset _offset = widget.offset;

  Widget dragChild = Image.asset(
    height: 100,
    "assets/images/mouse.png",
  );
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

    //_offset = widget.offset;

    img = const AssetImage("assets/images/empty.png");
    gif1 = const AssetImage("assets/images/waves_1.gif");
    gif2 = const AssetImage("assets/images/waves_2.gif");
    gif3 = const AssetImage("assets/images/waves_3.gif");
    gif4 = const AssetImage("assets/images/waves_4.gif");
    gif5 = const AssetImage("assets/images/waves_5.gif");
    gif6 = const AssetImage("assets/images/waves_6.gif");

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
            gif1 = const AssetImage("assets/images/waves_1.gif")..evict();

            img = gif1;
          });
        } else if (_diceface == 2) {
          Future.delayed(Duration(seconds: 1), () {
            heavyImpact();
          });
          heavyImpact();
          ;
          setState(() {
            gif2 = const AssetImage("assets/images/waves_2.gif")..evict();
            img = gif2;
          });
        } else if (_diceface == 3) {
          Future.delayed(Duration(seconds: 1), () {
            lightImpact();
          });
          heavyImpact();
          setState(() {
            gif3 = const AssetImage("assets/images/waves_3.gif")..evict();
            img = gif3;
          });
        } else if (_diceface == 4) {
          heavyImpact();
          setState(() {
            gif4 = const AssetImage("assets/images/waves_4.gif")..evict();
            img = gif4;
          });
        } else if (_diceface == 5) {
          Future.delayed(Duration(seconds: 1), () {
            heavyImpact();
          });
          lightImpact();
          setState(() {
            gif5 = const AssetImage("assets/images/waves_5.gif")..evict();
            img = gif5;
          });
        } else if (_diceface == 6) {
          Future.delayed(Duration(seconds: 1), () {
            heavyImpact();
          });
          Future.delayed(Duration(seconds: 1), () {
            lightImpact();
          });
          lightImpact();
          setState(() {
            gif6 = const AssetImage("assets/images/waves_6.gif")..evict();
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

  static Future<void> lightImpact() async {
    await SystemChannels.platform.invokeMethod<void>(
      'HapticFeedback.vibrate',
      'HapticFeedbackType.lightImpact',
    );
  }

  bool active = false;
  Timer? timer;
  Timer? refresh;
  Stopwatch stopwatch = Stopwatch();
  Duration duration = const Duration(seconds: 2);

  String result = "assets/images/response_1.png";

  void start() {
    setState(() {
      active = true;
      timer = Timer(duration, () {
        stop();
        //img = reveal;
        //holder = ending;
        _visible = false;

        _diceface = _random.nextInt(19) + 1;
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

    gif1.evict();
    gif2.evict();
    gif3.evict();
    gif4.evict();
    gif5.evict();
    gif6.evict();
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
      body: LayoutBuilder(builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
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
            Image(image: img),
            holder,
            Align(
              alignment: Alignment.topCenter,
              child: DragTarget<bool>(
                builder: (
                  BuildContext context,
                  List<dynamic> accepted,
                  List<dynamic> rejected,
                ) {
                  return topBar;
                },
                onAccept: (bool res) {
                  setState(() {
                    print('offset = ' + _offset.toString());
                    Navigator.pop(context, _offset);
                  });
                },
              ),
            ),
            Positioned(
              left: _offset.dx,
              top: _offset.dy,
              child: Draggable<bool>(
                data: true,
                feedback: Image.asset(
                  height: 100,
                  "assets/images/mouse.png",
                ),
                child: dragChild,
                onDragStarted: () {
                  setState(() {
                    dragChild = Container();
                  });
                },
                onDragEnd: (details) {
                  setState(() {
                    final adjustment = MediaQuery.of(context).size.height -
                        constraints.maxHeight;
                    _offset = Offset(
                        details.offset.dx, details.offset.dy - adjustment);
                    dragChild = Image.asset(
                      height: 100,
                      "assets/images/mouse.png",
                    );
                  });
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}

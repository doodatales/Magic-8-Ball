import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magic_8_ball/magic_ball.dart';
import 'package:provider/provider.dart';
import 'package:shake/shake.dart';

class Desktop extends StatefulWidget {
  const Desktop({super.key});

  @override
  State<Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<Desktop> {
  Offset _offset = Offset.zero;

  Widget dragChild = FlutterLogo(textColor: Colors.green, size: 100);

  Widget loadingBox = Container();

  bool active = false;
  Timer? timer;
  Timer? refresh;
  Stopwatch stopwatch = Stopwatch();
  Duration duration = const Duration(seconds: 5);

  _CountdownState() {
    // this is just so the time remaining text is updated
    refresh = Timer.periodic(
        const Duration(milliseconds: 500), (_) => setState(() {}));
  }

  void start() {
    setState(() {
      active = true;
      timer = Timer(duration, () {
        stop();
        print('here');
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => MagicBall(title: "test")));
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
    return duration.inSeconds - stopwatch.elapsed.inSeconds;
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
    return Scaffold(
      appBar: AppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Center(
                child: DragTarget<bool>(
                  builder: (
                    BuildContext context,
                    List<dynamic> accepted,
                    List<dynamic> rejected,
                  ) {
                    return Container(
                      height: 100.0,
                      width: 100.0,
                      color: Colors.cyan,
                    );
                  },
                  onAccept: (bool res) {
                    print('yay');

                    setState(() {
                      loadingBox = Container(
                        height: 300.0,
                        width: 300.0,
                        color: Colors.black,
                      );
                      start();
                    });
                  },
                ),
              ),
              Center(child: loadingBox),
              Positioned(
                left: _offset.dx,
                top: _offset.dy,
                child: Draggable<bool>(
                  data: true,
                  feedback: FlutterLogo(
                      textColor: const Color.fromARGB(255, 150, 135, 113),
                      size: 100),
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
                      dragChild =
                          FlutterLogo(textColor: Colors.green, size: 100);
                    });
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

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

  Widget dragChild = Image.asset(
    height: 100,
    "assets/images/mouse.png",
  );

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
      timer = Timer(duration, () async {
        stop();
        loadingBox = Container();
        final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MagicBall(offset: _offset)));
        //if (!mounted) return;

        print(result.toString());
        setState(() {
          _offset = result;
        });
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            fit: BoxFit.fitHeight,
            "assets/images/desktop_bg.png",
          ),
          Image.asset(
            alignment: Alignment.bottomCenter,
            fit: BoxFit.fitWidth,
            "assets/images/bottom_bar.png",
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                height: 100,
                                "assets/images/folder_icon.png",
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                height: 100,
                                "assets/images/document_icon.png",
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                height: 100,
                                "assets/images/empty_folder_icon.png",
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            DragTarget<bool>(
                              builder: (
                                BuildContext context,
                                List<dynamic> accepted,
                                List<dynamic> rejected,
                              ) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(
                                    height: 100,
                                    "assets/images/magic_icon.png",
                                  ),
                                );
                              },
                              onAccept: (bool res) {
                                setState(() {
                                  loadingBox = Image.asset(
                                    "assets/images/magic_loader.png",
                                  );
                                  start();
                                });
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Center(child: loadingBox),
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
                          final adjustment =
                              MediaQuery.of(context).size.height -
                                  constraints.maxHeight;
                          _offset = Offset(details.offset.dx,
                              details.offset.dy - adjustment);
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
            },
          ),
        ],
      ),
    );
  }
}

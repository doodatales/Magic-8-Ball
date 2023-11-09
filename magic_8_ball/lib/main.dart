import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shake/shake.dart';

void main() {
  runApp(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ShakeTime())],
      child: const MyApp()));
}

class ShakeTime with ChangeNotifier {
  int _shakeTime = 0;

  int get shakeTime => _shakeTime;

  void setShake(int time) {
    _shakeTime = time;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Desktop(), //MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

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
            MaterialPageRoute(builder: (context) => MyHomePage(title: "test")));
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

List<String> magicText = ["Hi", "How are you", "Howdy", "Yeehaw", "Hoo"];

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late Image img;
  Image gif1 = Image.asset("assets/images/waves_1.gif");
  Image gif2 = Image.asset("assets/images/waves_2.gif");
  Image gif3 = Image.asset("assets/images/waves_3.gif");
  Image ending1 = Image.asset(
      "assets/images/ending_1.gif"); // this one fades to transparent to reveal the answer, which has text color the same as bg color and a white/contrasting triangle

  static var _random = new Random();
  static var _diceface = _random.nextInt(3) + 1;

  late ShakeDetector detector;

  void initState() {
    super.initState();
    img = Image.asset("assets/images/empty.png");

    detector = ShakeDetector.autoStart(
      onPhoneShake: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shake!'),
          ),
        );
        _diceface = _random.nextInt(3) + 1;
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
        }
      },
      minimumShakeCount: 1,
      shakeSlopTimeMS: 500, // this is length of each gif
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
  Duration duration = const Duration(seconds: 5);

  String result = '';

  _CountdownState() {
    // this is just so the time remaining text is updated
    refresh = Timer.periodic(
        const Duration(milliseconds: 100), (_) => setState(() {}));
  }

  void start() {
    setState(() {
      active = true;
      timer = Timer(duration, () {
        stop();
        img = ending1;

        _diceface = _random.nextInt(5) + 1;
        result = magicText[_diceface];
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            img,
            Text(result),
            Text(context.watch<ShakeTime>().shakeTime.toString()),
            if (active) Text(secondsRemaining().toString()),
            if (active)
              TextButton(onPressed: stop, child: const Text('Stop'))
            else
              TextButton(onPressed: start, child: const Text('Start')),
          ],
        ),
      ),
    );
  }
}

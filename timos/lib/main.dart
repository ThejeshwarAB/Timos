import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Isolate isolate;
var timer;

void start() async {
  ReceivePort receivePort =
      ReceivePort(); //port for this main isolate to receive messages.
  isolate = await Isolate.spawn(runTimer, receivePort.sendPort);
  receivePort.listen((data) {
    // stdout.write('RECEIVE: ' + data + ', ');
  });
}

void runTimer(SendPort sendPort) {
  int counter = 0;
  timer = Timer.periodic(new Duration(minutes: 1), (Timer t) {
    counter++;
    String msg = 'notification ' + counter.toString();
    // stdout.write('SEND: ' + msg + ' - ');
    sendPort.send(msg);
  });
}

void stop() {
  if (isolate != null) {
    // stdout.writeln('killing isolate');
    isolate.kill(priority: Isolate.immediate);
    isolate = null;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  // var initializationSettingsIOS = IOSInitializationSettings(
  //     requestAlertPermission: true,
  //     requestBadgePermission: true,
  //     requestSoundPermission: true,
  //     onDidReceiveLocalNotification:
  //         (int id, String title, String body, String payload) async {});
  var initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('Notification payload: ' + payload);
    }
  });
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      home: AppPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppPage extends StatefulWidget {
  AppState createState() => new AppState();
}

class AppState extends State<AppPage> {
  var clicked = true;
  int time = 25;
  int full = 25;
  // var timer;
  int cycle = 1;
  int counter = 0;
  int flagCounter = 0;
  String mode = "WORK MODE";

  void changeApp(value) {
    setState(() {
      clicked = !clicked;
      flagCounter++;
    });
    if (value == "start") {
      if (flagCounter == 1) {
        start();
        // scheduleNow(25);
        schedule25();
      }
      timer = new Timer.periodic(
          Duration(minutes: 1),
          (Timer t) => {
                (time == 0)
                    ? {
                        setState(() {
                          counter++;
                          // cycle++;
                          if (counter == 10) {
                            cycle = 0;
                            counter = 0;
                          }
                          if (counter == 9) {
                            time = 30;
                            full = 30;
                            mode = "LONG BREAK";
                            // scheduleCancel();
                            // scheduleNow(30);
                            schedule30();
                          } else if (counter % 2 == 0) {
                            cycle++;
                            time = 25;
                            full = 25;
                            mode = "WORK MODE";
                            // scheduleCancel();
                            // scheduleNow(25);
                            if (counter != 8)
                              schedule25();
                            else
                              schedule25spl();
                          } else {
                            time = 5;
                            full = 5;
                            mode = "REST MODE";
                            // scheduleCancel();
                            // scheduleNow(5);
                            schedule5();
                          }
                        })
                      }
                    : setState(() {
                        time--;
                      })
              });
    } else if (value == "reset") {
      scheduleCancel();
      stop();
      timer.cancel();
      setState(() {
        time = 25;
        full = 25;
        cycle = 1;
        counter = 0;
        mode = "WORK MODE";
      });
    }
  }

  // void scheduleNow(value) async {
  //   var scheduleNotificationDateTime =
  //       DateTime.now().add(Duration(minutes: value));

  //   var androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //       'alarm_notif', 'alarm_notif', 'Channel for notification',
  //       icon: '@mipmap/ic_launcher',
  //       sound: (value == 25)
  //           ? RawResourceAndroidNotificationSound('sound1')
  //           : (value == 5)
  //               ? RawResourceAndroidNotificationSound('sound2')
  //               : RawResourceAndroidNotificationSound('sound3'),
  //       largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
  //       importance: Importance.max,
  //       priority: Priority.high);

  //   var platformChannelSpecifics =
  //       NotificationDetails(android: androidPlatformChannelSpecifics);

  //   // ignore: deprecated_member_use
  //   await flutterLocalNotificationsPlugin.schedule(
  //       0,
  //       "TIMOS",
  //       (value == 25)
  //           ? "WORK MODE STARTED"
  //           : (value == 5) ? "REST MODE STARTED" : "LONG BREAK STARTED",
  //       scheduleNotificationDateTime,
  //       platformChannelSpecifics);
  // }

  void schedule5() async {
    var scheduleNotificationDateTime = DateTime.now().add(Duration(minutes: 5));

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'alarm_notif', 'alarm_notif', 'Channel for notification',
        icon: '@mipmap/ic_launcher',
        sound: RawResourceAndroidNotificationSound('sound1'),
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        importance: Importance.max,
        priority: Priority.high);

    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // ignore: deprecated_member_use
    await flutterLocalNotificationsPlugin.schedule(
        0,
        "TIMOS",
        "WORK MODE STARTED",
        scheduleNotificationDateTime,
        platformChannelSpecifics);
  }

  void schedule25() async {
    var scheduleNotificationDateTime =
        DateTime.now().add(Duration(minutes: 25));

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'alarm_notif', 'alarm_notif', 'Channel for notification',
        icon: '@mipmap/ic_launcher',
        sound: RawResourceAndroidNotificationSound('sound2'),
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        importance: Importance.max,
        priority: Priority.high);

    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // ignore: deprecated_member_use
    await flutterLocalNotificationsPlugin.schedule(
        0,
        "TIMOS",
        "REST MODE STARTED",
        scheduleNotificationDateTime,
        platformChannelSpecifics);
  }

  void schedule25spl() async {
    var scheduleNotificationDateTime =
        DateTime.now().add(Duration(minutes: 25));

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'alarm_notif', 'alarm_notif', 'Channel for notification',
        icon: '@mipmap/ic_launcher',
        sound: RawResourceAndroidNotificationSound('sound3'),
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        importance: Importance.max,
        priority: Priority.high);

    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // ignore: deprecated_member_use
    await flutterLocalNotificationsPlugin.schedule(
        0,
        "TIMOS",
        "LONG REST STARTED",
        scheduleNotificationDateTime,
        platformChannelSpecifics);
  }

  void schedule30() async {
    var scheduleNotificationDateTime =
        DateTime.now().add(Duration(minutes: 30));

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'alarm_notif', 'alarm_notif', 'Channel for notification',
        icon: '@mipmap/ic_launcher',
        sound: RawResourceAndroidNotificationSound('sound3'),
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        importance: Importance.max,
        priority: Priority.high);

    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // ignore: deprecated_member_use
    await flutterLocalNotificationsPlugin.schedule(
        0,
        "TIMOS",
        "WORK MODE STARTED",
        scheduleNotificationDateTime,
        platformChannelSpecifics);
  }

  void scheduleCancel() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TIMOS",
            style: TextStyle(
              color: Colors.indigo[700],
              fontSize: 30.0,
              fontWeight: FontWeight.w900,
            )),
        centerTitle: true, backgroundColor: Colors.transparent, //No more green
        elevation: 0.0,
      ),
      body: Stack(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
//               Text("$counter"),
//               Text("Hello world!"),
//               Text("Hello world!"),
                    // Text("$time",
                    //     style: TextStyle(
                    //       color: Colors.indigo[700],
                    //       fontSize: 125.0,
                    //       fontWeight: FontWeight.w900,
                    //     )),
                    CircularPercentIndicator(
                        radius: 300.0,
                        lineWidth: 30.0,
                        percent: time / full,
                        center: new Text("$time",
                            style: TextStyle(
                              color: Colors.indigo[700],
                              fontSize: 125.0,
                              fontWeight: FontWeight.w900,
                            )),
                        progressColor:
                            (time > 5) ? Colors.green[500] : Colors.red[500],
                        circularStrokeCap: CircularStrokeCap.round),
                    SizedBox(height: 10),
                    (clicked == true)
                        ? AnimatedSwitcher(
                            duration: Duration(milliseconds: 250),
                            child: FloatingActionButton.extended(
                                label: Text("Start"),
                                elevation: 0.0,
                                splashColor: Colors.transparent,
                                backgroundColor: Colors.indigo[700],
                                hoverElevation: 0.00,
                                highlightElevation: 0.00,
                                icon: Icon(Icons.play_arrow),
                                onPressed: () {
                                  changeApp("start");
                                }))
                        : AnimatedSwitcher(
                            duration: Duration(milliseconds: 250),
                            child: FloatingActionButton.extended(
                                label: Text("Reset"),
                                elevation: 0.0,
                                splashColor: Colors.transparent,
                                backgroundColor: Colors.indigo[700],
                                hoverElevation: 0.00,
                                highlightElevation: 0.00,
                                icon: Icon(Icons.stop),
                                onPressed: () {
                                  changeApp("reset");
                                }),
                          ),
                    SizedBox(
                      height: 25.0,
                    ),
                    Row(
                      children: <Widget>[
                        FloatingActionButton.extended(
                          onPressed: null,
                          label: Text("$mode".toUpperCase()),
                          elevation: 0.0,
                          splashColor: Colors.transparent,
                          backgroundColor: Colors.green[600],
                          hoverElevation: 0.00,
                          highlightElevation: 0.00,
                        ),
                        SizedBox(width: 25.0),
                        FloatingActionButton.extended(
                          onPressed: null,
                          label: Text("SET $cycle"),
                          icon: Icon(Icons.access_time),
                          elevation: 0.0,
                          splashColor: Colors.transparent,
                          backgroundColor: Colors.red[600],
                          hoverElevation: 0.00,
                          highlightElevation: 0.00,
                        ),
                      ],
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              ],
            ),
            SlidingUpPanel(
              backdropEnabled: true,
              // backdropOpacity: 0.1,
              renderPanelSheet: false,
              collapsed: Container(
                child: IconButton(
                  iconSize: 30.0,
                  icon: new Icon(Icons.keyboard_arrow_up),
                  onPressed: null,
                ),
              ),
              panel: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 20.0,
                        color: Colors.grey,
                      ),
                    ]),
                margin: const EdgeInsets.all(20.0),
                child: Column(children: <Widget>[
                  SizedBox(height: 75),
                  Text(
                    "POMODORO",
                    style: TextStyle(
                        color: Colors.indigo[900],
                        fontSize: 25.0,
                        fontWeight: FontWeight.w900),
                  ),
                  Text(
                    "\nTIME MANAGEMENT TECHNIQUE",
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w900),
                  ),
                  Text(
                    "\nPer set = 25 mins work + 5 mins break",
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w900),
                  ),
                  Text(
                    "\nPer cycle = 5 sets as mentioned above",
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w900),
                  ),
                  Text(
                    "\nAfter a complete cycle - 25 mins break",
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w900),
                  ),
                  Text(
                    "\nAlso for long time blue screen viewers",
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w900),
                  ),
                  Text(
                    "\n1 bell WORK 2 bells REST 3 bells LONG",
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w900),
                  ),
                  Text(
                    "\nShare, support & scale up productivity",
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w900),
                  ),
                  Text(
                    "\nThejeshwarAB©",
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w900),
                  ),
                ]),
              ),
            ),
          ]),
    );
  }
}

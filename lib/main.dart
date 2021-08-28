import 'package:basic_application/UI/TabSelector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'bloc/Bloc/googleauth_bloc.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var initializationSettingsAndroid =
      AndroidInitializationSettings('codex_logo');
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {});
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final bloc = new GoogleauthBloc();

  @override
  void initState() {
    bloc.add(InitializeFirebase());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocProvider(
        create: (context) => bloc,
        child: BlocListener(
          bloc: bloc,
          listener: (context, state) {
            if (state is GoogleauthLoadedWithResponse) {
              if (state.response != null) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => TabSelector(),
                  ),
                );
              }
            }
          },
          child: BlocBuilder(
            bloc: bloc,
            builder: (context, state) {
              if (state is GoogleauthInitial) {
                return Container(
                  color: Colors.white,
                );
              } else if (state is GoogleauthLoadedWithResponse) {
                return mainScreen();
              } else if (state is GoogleauthLoading) {
                return CircularProgressIndicator();
              } else {
                return Container();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget mainScreen() {
    final buttonBloc = new GoogleauthBloc();
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                    color: Color.fromRGBO(13, 106, 106, 1),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20))),
                alignment: Alignment.center,
                child: Text(
                  'Basic Application',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                padding: EdgeInsets.all(40),
                child: Text(
                  'An easy solution to measuring distance between two points!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 0,
              child: BlocProvider(
                create: (context) => buttonBloc,
                child: BlocListener(
                  bloc: buttonBloc,
                  listener: (context, state) {
                    if (state is GoogleauthLoadedWithResponse) {
                      if (state.response != null) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => TabSelector(),
                          ),
                        );
                      }
                    }
                  },
                  child: BlocBuilder(
                    bloc: buttonBloc,
                    builder: (context, state) {
                      if (state is GoogleauthInitial ||
                          state is GoogleauthLoadedWithResponse) {
                        return Container(
                          padding: EdgeInsets.only(bottom: 50),
                          child: OutlinedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                            ),
                            onPressed: () {
                              buttonBloc.add(signInWithGoogle());
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image(
                                    image: AssetImage("assets/google_logo.png"),
                                    height: 35.0,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      'Sign in with Google',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      } else if (state is GoogleauthLoading) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 50),
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

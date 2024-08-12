// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:osl_umcollect/components/Utils.dart';
import 'package:osl_umcollect/pages/home.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:osl_umcollect/pages/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final storage = const FlutterSecureStorage();
  bool permission = false;
  var isLoading;
  String erid = '';
  String name = '';

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    PermissionStatus status = await Permission.location.status;
    if (status.isGranted) {
      getToken();
      setState(() {
        permission = true;
      });
    } else {
      setState(() {
        permission = false;
      });
    }
  }

  getToken() async {
    setState(() {
      isLoading = LoadingAnimationWidget.fallingDot(
        color: Colors.deepOrangeAccent,
        size: 100,
      );
    });

    var token = await storage.read(key: "kwstaffjwt");

    var decoded = parseJwt(token.toString());
    if (decoded["error"] == "Invalid token") {
      setState(() {
        isLoading = null;
      });
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const Login()));
    } else {
      setState(() {
        isLoading = null;
      });
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const Home()));
    }
  }

  Future<void> requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      getToken();
    } else if (status == PermissionStatus.denied) {
      openAppSettings();
    } else {
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'UM Collect',
        home: Scaffold(
          body: Stack(
            children: [
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(color: Colors.white54),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 200,
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      const Text(
                        "OSL",
                        style: TextStyle(
                            fontSize: 32,
                            color: Color.fromARGB(255, 28, 100, 140),
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      const Text(
                        "UM Collect",
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      if (!permission)
                        TextButton(
                            onPressed: () => showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                    title: const Text('Location Permission'),
                                    content: const Text(
                                        'This app collects location data to enable route navigation to various assets among other functionalities'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, 'Cancel'),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          requestLocationPermission();
                                          Navigator.pop(context, 'OK');
                                        },
                                        child: const Text('Grant Permissions'),
                                      ),
                                    ],
                                  ),
                                ),
                            child: Container(
                              padding:
                                  const EdgeInsets.fromLTRB(24, 12, 24, 12),
                              decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Review App Permissions",
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                  SizedBox(
                                    width: 12,
                                  ),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                  )
                                ],
                              ),
                            ))
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 64, 24),
                  child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 28, 100, 140),
                          borderRadius: BorderRadius.horizontal(
                              right: Radius.circular(44))),
                      child: const Text(
                        "Powered by \n Oakar Services",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      )),
                ),
              ),
              Center(child: isLoading),
            ],
          ),
        ));
  }
}

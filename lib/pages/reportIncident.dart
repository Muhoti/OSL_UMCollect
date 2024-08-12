import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:osl_umcollect/components/MyTextInputII.dart';
import 'package:osl_umcollect/components/MyDrawer.dart';
import 'package:osl_umcollect/components/SubmitButton.dart';
import 'package:osl_umcollect/components/Utils.dart';
import 'package:osl_umcollect/models/Map.dart';
import 'package:osl_umcollect/pages/TextOakar.dart';
import 'package:osl_umcollect/pages/incidences.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart';
import 'package:geolocator/geolocator.dart';

class ReportIncident extends StatefulWidget {
  final String incident;

  const ReportIncident(this.incident, {super.key});

  @override
  State<ReportIncident> createState() => _ReportIncidentState();
}

class _ReportIncidentState extends State<ReportIncident> {
  final storage = const FlutterSecureStorage();
  var long = 36.0, lat = -2.0, acc = 100.0;
  String image = '#';
  String description = '';
  String phone = '';
  String accountno = '';
  String name = '';
  String reportertype = 'Public';
  String route = '';
  String location = '';
  String error = '';
  var isLoading;
  late File? _image;
  final imagePicker = ImagePicker();
  bool servicestatus = false;
  late LocationPermission permission;
  bool haspermission = false;
  late Position position;
  String userid = '';
  bool successful = false;
  String myimage = '';
  StreamSubscription<Position>? positionStreamSubscription;

  getUserLocation() async {
    try {
      var token = await storage.read(key: "mwjwt");
      var decoded = parseJwt(token.toString());
      var id = decoded["UserID"];
      setState(() {
        userid = id.toString();
      });
    } catch (e) {}

    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.always ||
          perm == LocationPermission.whileInUse) {
        position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        setState(() {
          long = position.longitude;
          lat = position.latitude;
          acc = position.accuracy;
        });

        LocationSettings locationSettings = const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 1,
        );

        positionStreamSubscription =
            Geolocator.getPositionStream(locationSettings: locationSettings)
                .listen((Position position) {
          setState(() {
            long = position.longitude;
            lat = position.latitude;
            acc = position.accuracy;
          });
        });
      } else {
        promptUserForLocation();
      }
    } catch (e) {}
  }

  Future<String> convertFileToBase64(XFile file) async {
    List<int> fileBytes = await file.readAsBytes();
    String base64String = base64Encode(fileBytes);
    return base64String;
  }

  promptUserForLocation() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if (servicestatus) {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        } else if (permission == LocationPermission.deniedForever) {
          permission = await Geolocator.requestPermission();
        } else {
          haspermission = true;
        }
      } else {
        haspermission = true;
      }
    }
  }

  Future<void> takePhoto() async {
    final pickedFile = await imagePicker.pickImage(
      source: ImageSource.camera, // Open the camera to take a photo
    );

    if (pickedFile != null) {
      String base64Image = await convertFileToBase64(pickedFile);
      setState(() {
        _image = File(pickedFile.path);
        myimage = base64Image;
      });
    } else {}
  }

  Future<void> getStaffUser() async {
    try {
      var token = await storage.read(key: "kwstaffjwt");
      var decoded = parseJwt(token.toString());

      if (decoded["error"] == "Invalid token") {
      } else {
        setState(() {
          phone = decoded["Phone"];
          name = decoded["Name"];
          reportertype = "Staff";
        });
      }
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    _image = null;
    getUserLocation();
    getStaffUser();
  }

  @override
  void dispose() {
    positionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Report Incident',
      theme: ThemeData(),
      home: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const Incidences()));
              },
            ),
          ],
          title: Text(
            "Report - ${widget.incident}",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 28, 100, 140),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        drawer: const MyDrawer(),
        body: Stack(
          children: [
            SafeArea(
                child: Container(
                    padding: const EdgeInsets.all(12.0),
                    child: SizedBox(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              '${widget.incident} Location',
                              style: const TextStyle(
                                color: Color.fromARGB(255, 28, 100, 140),
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: SizedBox(
                                height: 250,
                                child: MyMap(
                                  lat: lat,
                                  lon: long,
                                  acc: acc,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Take a Photo',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 28, 100, 140),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                Card(
                                  elevation: 2,
                                  clipBehavior: Clip.hardEdge,
                                  child: Stack(
                                    children: [
                                      SizedBox(
                                        height: 250,
                                        width: double.infinity,
                                        child: _image == null
                                            ? const Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  "No image selected",
                                                  style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 28, 100, 140),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              )
                                            : GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return Dialog(
                                                        child: Container(
                                                          color: Colors.black,
                                                          child:
                                                              InteractiveViewer(
                                                            child: Image.file(
                                                                _image!),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Image.file(
                                                  _image!,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.photo_camera,
                                            size: 50,
                                            color: Color.fromARGB(
                                                255, 28, 100, 140),
                                          ),
                                          onPressed: () => takePhoto(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 24,
                                ),
                                const Text(
                                  'Write a Comment',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 28, 100, 140),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                MyTextInputII(
                                  hint: 'Describe Incident (Mandatory)',
                                  lines: 1,
                                  value: description,
                                  type: TextInputType.text,
                                  onSubmit: (value) {
                                    setState(() {
                                      description = value;
                                    });
                                  },
                                  customIcon: Icons.description,
                                  mycolor:
                                      const Color.fromARGB(255, 28, 100, 140),
                                  iconcolor:
                                      const Color.fromARGB(255, 28, 100, 140),
                                ),
                                MyTextInputII(
                                  hint: 'Reporter\'s Name',
                                  lines: 1,
                                  value: name,
                                  type: TextInputType.text,
                                  onSubmit: (value) {
                                    setState(() {
                                      name = value;
                                    });
                                  },
                                  customIcon: Icons.account_box,
                                  mycolor:
                                      const Color.fromARGB(255, 28, 100, 140),
                                  iconcolor:
                                      const Color.fromARGB(255, 28, 100, 140),
                                ),
                                reportertype == "Public"
                                    ? MyTextInputII(
                                        hint:
                                            'Reporter\'s Phone Number (Mandatory)',
                                        lines: 1,
                                        value: phone,
                                        type: TextInputType.text,
                                        onSubmit: (value) {
                                          setState(() {
                                            phone = value;
                                          });
                                        },
                                        customIcon: Icons.phone,
                                        mycolor: const Color.fromARGB(
                                            255, 28, 100, 140),
                                        iconcolor: const Color.fromARGB(
                                            255, 28, 100, 140),
                                      )
                                    : const SizedBox(),
                                if (widget.incident == "Illegal Connection")
                                  MyTextInputII(
                                    hint: 'Route',
                                    lines: 1,
                                    value: "",
                                    type: TextInputType.text,
                                    onSubmit: (value) {
                                      setState(() {
                                        route = value;
                                      });
                                    },
                                    customIcon: Icons.route,
                                    mycolor:
                                        const Color.fromARGB(255, 28, 100, 140),
                                    iconcolor:
                                        const Color.fromARGB(255, 28, 100, 140),
                                  ),
                                if (widget.incident == "Illegal Connection")
                                  MyTextInputII(
                                    hint: 'Location',
                                    lines: 1,
                                    value: "",
                                    type: TextInputType.text,
                                    onSubmit: (value) {
                                      setState(() {
                                        location = value;
                                      });
                                    },
                                    customIcon: Icons.location_city,
                                    mycolor:
                                        const Color.fromARGB(255, 28, 100, 140),
                                    iconcolor:
                                        const Color.fromARGB(255, 28, 100, 140),
                                  ),
                                const SizedBox(
                                  height: 12,
                                ),
                                reportertype == "Public"
                                    ? MyTextInputII(
                                        hint: 'Reporter\'s Account Number',
                                        lines: 1,
                                        value: accountno,
                                        type: TextInputType.text,
                                        onSubmit: (value) {
                                          setState(() {
                                            accountno = value;
                                          });
                                        },
                                        customIcon: Icons.account_balance,
                                        mycolor: const Color.fromARGB(
                                            255, 28, 100, 140),
                                        iconcolor: const Color.fromARGB(
                                            255, 28, 100, 140),
                                      )
                                    : const SizedBox(),
                                TextOakar(
                                    label: error, issuccessful: successful),
                                const SizedBox(
                                  height: 12,
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: SubmitButton(
                                    label: "Submit",
                                    onButtonPressed: () async {
                                      setState(() {
                                        error = "";
                                        isLoading = LoadingAnimationWidget
                                            .staggeredDotsWave(
                                          color: const Color.fromARGB(
                                              255, 28, 100, 140),
                                          size: 100,
                                        );
                                      });

                                      var res = await submitData(
                                          userid,
                                          myimage,
                                          widget.incident,
                                          description,
                                          phone,
                                          accountno,
                                          lat,
                                          long,
                                          name,
                                          reportertype,
                                          route,
                                          location);
                                      setState(() {
                                        isLoading = null;
                                        if (res.error == null) {
                                          successful = true;
                                          error = res.success;
                                        } else {
                                          successful = false;
                                          error = res.error;
                                        }
                                      });
                                      if (res.error == null) {
                                        Timer(const Duration(seconds: 2), () {
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      const Incidences()));
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ))),
            Center(
              child: isLoading ?? const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}

Future<Message> submitData(
  String userid,
  String myimage,
  String incident,
  String description,
  String phone,
  String accountno,
  double lat,
  double long,
  String name,
  String reportertype,
  String route,
  String location,
) async {
  if (phone.length != 10) {
    return Message(token: null, success: null, error: "Invalid phone number!");
  }

  if (accountno.length != 5) {
    return Message(
        token: null, success: null, error: "Account number must be 5 digits!");
  }

  if (myimage.isEmpty) {
    return Message(
        token: null, success: null, error: "Take Photo of $incident!");
  }

  if (description.isEmpty || phone.isEmpty) {
    return Message(token: null, success: null, error: "Empty Mandatory Field!");
  }

  print("reporter type: $reportertype");

  try {
    final response = await post(
      Uri.parse("${getUrl()}reports/create"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'Type': incident,
        'Description': description,
        'Phone': phone,
        'AccountNo': accountno,
        'Latitude': lat.toString(),
        'Longitude': long.toString(),
        'UserID': userid,
        'Image': myimage,
        'Name': name,
        'ReporterType': reportertype,
        'Route': route,
        'Location': location,
        'Status': "Received"
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 203) {
      return Message.fromJson(jsonDecode(response.body));
    } else {
      return Message(
        token: null,
        success: null,
        error: "Server error! Contact administrator.",
      );
    }
  } catch (e) {
    return Message(
      token: null,
      success: null,
      error: "Connection failed! Check your internet connection.!",
    );
  }
}

class Message {
  var token;
  var success;
  var error;

  Message({
    required this.token,
    required this.success,
    required this.error,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      token: json['token'],
      success: json['success'],
      error: json['error'],
    );
  }
}

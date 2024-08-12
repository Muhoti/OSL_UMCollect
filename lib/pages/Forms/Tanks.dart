// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, file_names

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:osl_umcollect/components/MySelectInput.dart';
import 'package:osl_umcollect/components/MyTextInput.dart';
import 'package:osl_umcollect/components/StaffDrawer.dart';
import 'package:osl_umcollect/components/SubmitButton.dart';
import 'package:osl_umcollect/components/TextResponse.dart';
import 'package:osl_umcollect/components/Utils.dart';
import 'package:osl_umcollect/models/Map.dart';
import 'package:osl_umcollect/pages/Assets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;

class Tanks extends StatefulWidget {
  final String staffid;
  const Tanks({super.key, required this.staffid});

  @override
  State<Tanks> createState() => _TanksState();
}

class _TanksState extends State<Tanks> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final storage = const FlutterSecureStorage();
  late Position position;

  var long = 36.0, lat = -2.0, acc = 100.0;
  String error = '';
  String? editing = 'false';
  String tankID = '';
  String name = '';
  String zone = '';
  String elevation = '';
  String area = '';
  String location = '';
  String inletpipe = '';
  String outletpipe = '';
  String material = '';
  String capacity = '';
  String status = '';
  String remarks = '';
  String user = '';
  dynamic data;

  var isLoading;

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  void initState() {
    fetchStoredData();
    getLocation();
    super.initState();
  }

  Future<void> fetchStoredData() async {
    try {
      var token = await storage.read(key: "kwstaffjwt");
      var decoded = parseJwt(token.toString());
      editing = await storage.read(key: "editing");

      setState(() {
        user = decoded["Name"];
      });

      if (editing == 'true') {
        prefillForm(data);
      } else {}
    } catch (e) {}
  }

  prefillForm(data) async {
    var fetchedData = await storage.read(key: "data");
    data = json.decode(fetchedData!);

    setState(() {
      tankID = data[0]["ID"];
      name = data[0]["Name"];
      zone = data[0]["Zone"];
      elevation = data[0]["Elevation"].toString();
      area = data[0]["Area"];
      location = data[0]["Location"];
      inletpipe = data[0]["InletPipe"];
      outletpipe = data[0]["OutletPipe"];
      material = data[0]["Material"];
      capacity = data[0]["Capacity"];
      status = data[0]["Status"];
      remarks = data[0]["Remarks"];
      user = data[0]["User"];
    });
  }

  getLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      long = position.longitude;
      lat = position.latitude;
      acc = position.accuracy;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => Assets(
                            staffid: widget.staffid,
                          )));
            },
          ),
        ],
        title: const Text(
          'Tanks Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 28, 100, 140),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: StaffDrawer(
        staffid: widget.staffid,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(color: Colors.white),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 8,
                    ),
                    const Text(
                      "All fields marked with * are required",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
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
                            ))),
                    MyTextInput(
                      lines: 1,
                      value: name,
                      type: TextInputType.text,
                      onSubmit: (value) {
                        setState(() {
                          name = value;
                        });
                      },
                      title: 'Name',
                    ),
                    MySelectInput(
                      onSubmit: (value) {
                        setState(() {
                          zone = value;
                        });
                      },
                      list: const [
                        "--Select--",
                        "001 Gathugu",
                        "Urban Giakairu",
                        "002 Urban Institution",
                        "003 Indian",
                        "004 Industrial",
                        "005 Karindundu",
                        "006 Mathaithi",
                        "007 Ragati",
                        "008 Saigon 1",
                        "009 Sofia",
                        "010 Muthua",
                        "011 Blue Valley",
                        "012 83",
                        "013 84",
                        "014 85",
                        "015 86",
                        "016 87",
                        "017 88",
                        "018 Jambo-88",
                        "019 Tumutumu-87",
                        "020 90",
                        "021 91",
                        "022 92",
                        "023 82(Inst.Rural)",
                        "024 90",
                        "024 92",
                        "024 93",
                      ],
                      label: 'Zone',
                      value: zone,
                    ),
                    MyTextInput(
                      lines: 1,
                      value: elevation,
                      type: TextInputType.number,
                      onSubmit: (value) {
                        setState(() {
                          elevation = value;
                        });
                      },
                      title: 'Elevation',
                    ),
                    MyTextInput(
                      lines: 1,
                      value: area,
                      type: TextInputType.text,
                      onSubmit: (value) {
                        setState(() {
                          area = value;
                        });
                      },
                      title: 'Area',
                    ),
                    MyTextInput(
                      lines: 1,
                      value: location,
                      type: TextInputType.text,
                      onSubmit: (value) {
                        setState(() {
                          location = value;
                        });
                      },
                      title: 'Location',
                    ),
                    MyTextInput(
                      lines: 1,
                      value: inletpipe,
                      type: TextInputType.text,
                      onSubmit: (value) {
                        setState(() {
                          inletpipe = value;
                        });
                      },
                      title: 'Inlet Pipe',
                    ),
                    MyTextInput(
                      lines: 1,
                      value: outletpipe,
                      type: TextInputType.text,
                      onSubmit: (value) {
                        setState(() {
                          outletpipe = value;
                        });
                      },
                      title: 'Outlet Pipe',
                    ),
                    MyTextInput(
                      lines: 1,
                      value: material,
                      type: TextInputType.text,
                      onSubmit: (value) {
                        setState(() {
                          material = value;
                        });
                      },
                      title: 'Material',
                    ),
                    MyTextInput(
                      lines: 1,
                      value: capacity,
                      type: TextInputType.text,
                      onSubmit: (value) {
                        setState(() {
                          capacity = value;
                        });
                      },
                      title: 'Capacity',
                    ),
                    MySelectInput(
                      onSubmit: (value) {
                        setState(() {
                          status = value;
                        });
                      },
                      list: const [
                        "--Select--",
                        "Active",
                        "Inactive",
                      ],
                      label: 'Status',
                      value: status,
                    ),
                    MyTextInput(
                      lines: 1,
                      value: remarks,
                      type: TextInputType.text,
                      onSubmit: (value) {
                        setState(() {
                          remarks = value;
                        });
                      },
                      title: 'Remarks',
                    ),
                    MyTextInput(
                      lines: 1,
                      value: user,
                      type: TextInputType.text,
                      onSubmit: (value) {
                        setState(() {
                          user = value;
                        });
                      },
                      title: 'User',
                    ),
                    Center(
                      child: TextResponse(
                        label: error,
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SubmitButton(
                        label: "Submit",
                        onButtonPressed: () async {
                          setState(() {
                            isLoading =
                                LoadingAnimationWidget.staggeredDotsWave(
                                    color: Color.fromARGB(255, 28, 100, 140),
                                    size: 100);
                          });
                          var res = await submitData(
                              tankID,
                              lat.toString(),
                              long.toString(),
                              name,
                              zone,
                              elevation,
                              area,
                              location,
                              inletpipe,
                              outletpipe,
                              material,
                              capacity,
                              status,
                              remarks,
                              user,
                              editing);

                          setState(() {
                            isLoading = null;
                            if (res.error == null) {
                              error = res.success;
                            } else {
                              error = res.error;
                            }
                          });
                          if (res.error == null) {
                            // PROCEED TO NEXT PAGE
                            Timer(const Duration(seconds: 2), () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => Assets(
                                            staffid: widget.staffid,
                                          )));
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: isLoading ?? const SizedBox(),
          ),
        ],
      ),
    );
  }
}

Future<Message> submitData(
    String tankID,
    String lat,
    String long,
    String name,
    String zone,
    String elevation,
    String area,
    String location,
    String inletpipe,
    String outletpipe,
    String material,
    String capacity,
    String status,
    String remarks,
    String user,
    String? editing) async {
  try {
    var response;

    if (editing == 'true') {
      response = await http.put(
        Uri.parse("${getUrl()}tanks/$tankID"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'Name': name,
          'Zone': zone,
          'Elevation': elevation,
          'Area': area,
          'Location': location,
          'Inletpipe': inletpipe,
          'Outlet': outletpipe,
          'Material': material,
          'Capacity': capacity,
          'Status': status,
          'Remarks': remarks,
          'User': user,
        }),
      );
    } else {
      response = await http.post(
        Uri.parse("${getUrl()}tanks/create"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'Latitude': lat,
          'Longitude': long,
          'Name': name,
          'Zone': zone,
          'Elevation': elevation,
          'Area': area,
          'Location': location,
          'Inletpipe': inletpipe,
          'Outlet': outletpipe,
          'Material': material,
          'Capacity': capacity,
          'Status': status,
          'Remarks': remarks,
          'User': user,
        }),
      );
    }

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

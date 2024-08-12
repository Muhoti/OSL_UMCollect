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
import 'package:osl_umcollect/pages/Forms/CustomerMeters2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;

class CustomerMeters1 extends StatefulWidget {
  final String staffid;
  const CustomerMeters1({super.key, required this.staffid});

  @override
  State<CustomerMeters1> createState() => _CustomerMeters1State();
}

class _CustomerMeters1State extends State<CustomerMeters1> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final storage = const FlutterSecureStorage();
  late Position position;

  var long = 36.0, lat = -2.0, acc = 100.0;
  String error = '';
  String? editing = 'false';
  String name = '';
  String phone = '';
  String accnum = '';
  String metnum = '';
  String metsize = '';
  String metstatus = '';
  String user = '';
  String userid = '';
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
      userid = data[0]["ID"];
      name = data[0]["Name"];
      phone = data[0]["Phone"];
      accnum = data[0]["AccountNo"].toString();
      metnum = data[0]["MeterNo"];
      metsize = data[0]["MeterSize"];
      metstatus = data[0]["MeterStatus"];
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
          'Customer Details',
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
                            width: double.infinity,
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
                      title: 'Name ',
                    ),
                    MyTextInput(
                      lines: 1,
                      value: phone,
                      type: TextInputType.phone,
                      onSubmit: (value) {
                        setState(() {
                          phone = value;
                        });
                      },
                      title: 'Customer\'s Phone Number ',
                    ),
                    MyTextInput(
                      lines: 1,
                      value: accnum,
                      type: TextInputType.number,
                      onSubmit: (value) {
                        setState(() {
                          accnum = value;
                        });
                      },
                      title: 'Account Number *',
                    ),
                    MyTextInput(
                      lines: 1,
                      value: metnum,
                      type: TextInputType.text,
                      onSubmit: (value) {
                        setState(() {
                          metnum = value;
                        });
                      },
                      title: 'Meter Number *',
                    ),
                    MySelectInput(
                      onSubmit: (value) {
                        setState(() {
                          metsize = value;
                        });
                      },
                      list: const [
                        "--Select--",
                        "0.5",
                        "0.75",
                        "1",
                        "1.5",
                        "2",
                        "3",
                        "4",
                        "5",
                        "6",
                        "8"
                      ],
                      label: 'Meter Size',
                      value: metsize,
                    ),
                    MySelectInput(
                      onSubmit: (value) {
                        setState(() {
                          metstatus = value;
                        });
                      },
                      list: const [
                        "--Select--",
                        "Metered",
                        "Unmetered",
                      ],
                      label: 'Meter Status',
                      value: metstatus,
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
                        label: "Next",
                        onButtonPressed: () async {
                          setState(() {
                            isLoading =
                                LoadingAnimationWidget.staggeredDotsWave(
                                    color: Color.fromARGB(255, 28, 100, 140),
                                    size: 100);
                          });
                          var res = await submitData(
                              userid,
                              lat.toString(),
                              long.toString(),
                              name,
                              phone,
                              accnum,
                              metnum,
                              metsize,
                              metstatus,
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
                            await storage.write(
                                key: 'meterid', value: res.token);

                            Timer(const Duration(seconds: 2), () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => CustomerMeters2(
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
    String userid,
    String lat,
    String long,
    String name,
    String phone,
    String accountnumber,
    String meternumber,
    String metersize,
    String meterstatus,
    String user,
    String? editing) async {
  if (accountnumber.isEmpty) {
    return Message(
      token: null,
      success: null,
      error: "Account number must be filled!",
    );
  }

  if (accountnumber.length != 5) {
    return Message(
      token: null,
      success: null,
      error: "Account number must be 5 digits!",
    );
  }

  if (name.isEmpty) {
    return Message(
      token: null,
      success: null,
      error: "Name must be filled!",
    );
  }

  try {
    var response;

    if (editing == 'true') {
      response = await http.put(
        Uri.parse("${getUrl()}customers/$userid"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'Name': name,
          'Phone': phone,
          'AccountNo': accountnumber,
          'MeterNo': meternumber,
          'MeterSize': metersize,
          'MeterStatus': meterstatus,
          'User': user,
        }),
      );
    } else {
      response = await http.post(
        Uri.parse("${getUrl()}customers/create"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'Latitude': lat,
          'Longitude': long,
          'Name': name,
          'Phone': phone,
          'AccountNo': accountnumber,
          'MeterNo': meternumber,
          'MeterSize': metersize,
          'MeterStatus': meterstatus,
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

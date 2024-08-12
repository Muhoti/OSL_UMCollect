// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, file_names

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:osl_umcollect/components/MyDrawer.dart';
import 'package:osl_umcollect/components/MySelectInput.dart';
import 'package:osl_umcollect/components/MyTextInput.dart';
import 'package:osl_umcollect/components/SubmitButton.dart';
import 'package:osl_umcollect/components/TextResponse.dart';
import 'package:osl_umcollect/components/Utils.dart';
import 'package:osl_umcollect/pages/Assets.dart';
import 'package:osl_umcollect/pages/Forms/CustomerMeters2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;

class CustomerMeters3 extends StatefulWidget {
  final String staffid;
  const CustomerMeters3({super.key, required this.staffid});

  @override
  State<CustomerMeters3> createState() => _CustomerMeters3State();
}

class _CustomerMeters3State extends State<CustomerMeters3> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final storage = const FlutterSecureStorage();
  late Position position;

  String error = '';
  String schemename = '';
  String zone = '';
  String route = '';
  String dma = '';
  String location = '';
  String parcelno = '';
  String remarks = '';
  String? editing = 'false';
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
      schemename = data[0]["SchemeName"];
      zone = data[0]["Zone"];
      route = data[0]["Route"];
      dma = data[0]["DMA"];
      location = data[0]["Location"];
      parcelno = data[0]["ParcelNo"];
      remarks = data[0]["Remarks"];
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
                      builder: (_) => CustomerMeters2(
                            staffid: widget.staffid,
                          )));
            },
          ),
        ],
        title: const Text(
          'Other Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 28, 100, 140),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const MyDrawer(),
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
                    MySelectInput(
                      onSubmit: (value) {
                        setState(() {
                          schemename = value;
                        });
                      },
                      list: const [
                        "--Select--",
                        "Rural",
                        "Urban",
                      ],
                      label: 'Scheme Name',
                      value: schemename,
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
                      value: route,
                      type: TextInputType.text,
                      onSubmit: (value) {
                        setState(() {
                          route = value;
                        });
                      },
                      title: 'Route',
                    ),
                    MySelectInput(
                      onSubmit: (value) {
                        setState(() {
                          dma = value;
                        });
                      },
                      list: const [
                        "--Select--",
                        "Saigon",
                        "Blue Valley",
                        "Karindundu",
                        "Mathaithi",
                        "Gathugu",
                        "Sofia",
                        "Indian",
                        "Industrial",
                        "Muthua",
                        "Ragati",
                        "Kiamariga Factory Line",
                        "Kiamariga Lower",
                        "Mbari ya Miiria",
                        "Karogogo",
                        "Kaiyaba",
                        "Ikonju",
                        "Gitumbi",
                        "Karembu",
                        "Mukangu",
                        "Kiangai",
                        "Ndiriti",
                        "Ihwagi",
                        "Jambo",
                        "Mugugutu",
                        "Gatheu",
                        "Kiunjugi/Kirima",
                        "Migingo/Giakaburi",
                        "Magutu",
                        "Giakimuru",
                        "Kanjuri",
                        "Gikore",
                      ],
                      label: 'DMA',
                      value: dma,
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
                      value: parcelno,
                      type: TextInputType.text,
                      onSubmit: (value) {
                        setState(() {
                          parcelno = value;
                        });
                      },
                      title: 'Parcel Number',
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
                                    color:
                                        const Color.fromARGB(255, 28, 100, 140),
                                    size: 100);
                          });
                          var res = await submitData(userid, schemename, zone,
                              route, dma, location, parcelno, remarks, editing);

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
    String userid,
    String schemename,
    String zone,
    String route,
    String dma,
    String location,
    String parcelno,
    String remarks,
    String? editing) async {
  if (zone == "--Select--") {
    return Message(
      token: null,
      success: null,
      error: "Select Zone!!",
    );
  }

  if (dma == "--Select--") {
    return Message(
      token: null,
      success: null,
      error: "Select DMA!!",
    );
  }

  if (route.isEmpty) {
    return Message(
      token: null,
      success: null,
      error: "Route must be filled!",
    );
  }

  try {
    const storage = FlutterSecureStorage();
    var meterid = await storage.read(key: 'meterid');
    var response;

    if (editing == 'true') {
      response = await http.put(
        Uri.parse("${getUrl()}customers/$userid"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'SchemeName': schemename,
          'Zone': zone,
          'Route': route,
          'DMA': dma,
          'Location': location,
          'ParcelNo': parcelno,
          'Remarks': remarks,
        }),
      );
    } else {
      response = await http.put(
        Uri.parse("${getUrl()}customers/$meterid"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'SchemeName': schemename,
          'Zone': zone,
          'Route': route,
          'DMA': dma,
          'Location': location,
          'ParcelNo': parcelno,
          'Remarks': remarks,
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

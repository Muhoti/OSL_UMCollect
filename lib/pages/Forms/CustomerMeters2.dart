// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, file_names

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:osl_umcollect/components/MyDrawer.dart';
import 'package:osl_umcollect/components/MySelectInput.dart';
import 'package:osl_umcollect/components/SubmitButton.dart';
import 'package:osl_umcollect/components/TextResponse.dart';
import 'package:osl_umcollect/components/Utils.dart';
import 'package:osl_umcollect/pages/Forms/CustomerMeters1.dart';
import 'package:osl_umcollect/pages/Forms/CustomerMeters3.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:http/http.dart' as http;

class CustomerMeters2 extends StatefulWidget {
  final String staffid;
  const CustomerMeters2({super.key, required this.staffid});

  @override
  State<CustomerMeters2> createState() => _CustomerMeters2State();
}

class _CustomerMeters2State extends State<CustomerMeters2> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final storage = const FlutterSecureStorage();
  late Position position;

  String error = '';
  String accstatus = '';
  String acctype = '';
  String instituteMeterType = '';
  String metbrand = '';
  String metmaterial = '';
  String category = '';
  String? editing = '';
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
      accstatus = data[0]["AccountStatus"];
      acctype = data[0]["AccountType"];
      instituteMeterType = data[0]["Institution"];
      metbrand = data[0]["Brand"];
      metmaterial = data[0]["Material"];
      category = data[0]["Class"];
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
                      builder: (_) => CustomerMeters1(
                            staffid: widget.staffid,
                          )));
            },
          ),
        ],
        title: const Text(
          'Account Details',
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
                          accstatus = value;
                        });
                      },
                      list: const [
                        "--Select--",
                        "Active",
                        "Sealed",
                        "Dormant",
                        "Closed",
                        "Cut Off",
                      ],
                      label: 'Account Status',
                      value: accstatus,
                    ),
                    MySelectInput(
                      onSubmit: (value) {
                        setState(() {
                          acctype = value;
                        });
                      },
                      list: const [
                        "--Select--",
                        "Domestic",
                        "Commercial",
                      ],
                      label: 'Account Type',
                      value: acctype,
                    ),
                    MySelectInput(
                      onSubmit: (value) {
                        setState(() {
                          instituteMeterType = value;
                        });
                      },
                      list: const [
                        "--Select--",
                        "Large",
                        "Medium",
                        "Small",
                      ],
                      label:
                          'Is it an Institution Meter? If yes, select type...',
                      value: instituteMeterType,
                    ),
                    MySelectInput(
                      onSubmit: (value) {
                        setState(() {
                          metbrand = value;
                        });
                      },
                      list: const [
                        "--Select--",
                        "YUONSO",
                        "TWSB",
                        "ARAD",
                        "AIMEI",
                        "SUPER",
                        "DUNWELLS",
                        "OTHER",
                      ],
                      label: 'Meter Brand',
                      value: metbrand,
                    ),
                    MySelectInput(
                      onSubmit: (value) {
                        setState(() {
                          metmaterial = value;
                        });
                      },
                      list: const [
                        "--Select--",
                        "Polymer",
                        "Brass",
                        "Plastic",
                      ],
                      label: 'Meter Material',
                      value: metmaterial,
                    ),
                    MySelectInput(
                      onSubmit: (value) {
                        setState(() {
                          category = value;
                        });
                      },
                      list: const [
                        "--Select--",
                        "A",
                        "B",
                        "C",
                        "R160",
                        "R200",
                        "R250",
                      ],
                      label: 'Class',
                      value: category,
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
                              accstatus,
                              acctype,
                              instituteMeterType,
                              metbrand,
                              metmaterial,
                              category,
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
                                      builder: (_) => CustomerMeters3(
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
    String accountstatus,
    String acctype,
    String institution,
    String meterbrand,
    String metermaterial,
    String category,
    String? editing) async {
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
          'AccountStatus': accountstatus,
          'AccountType': acctype,
          'Institution': institution,
          'Brand': meterbrand,
          'Material': metermaterial,
          'Class': category,
        }),
      );
    } else {
      response = await http.put(
        Uri.parse("${getUrl()}customers/$meterid"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'AccountStatus': accountstatus,
          'AccountType': acctype,
          'Institution': institution,
          'Brand': meterbrand,
          'Material': metermaterial,
          'Class': category,
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

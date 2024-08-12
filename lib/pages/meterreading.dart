// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, unused_import, empty_catches

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:osl_umcollect/components/MyDrawer.dart';
import 'package:osl_umcollect/components/MyRow.dart';
import 'package:osl_umcollect/components/MyRowIII.dart';
import 'package:osl_umcollect/components/StaffDrawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:osl_umcollect/pages/asset_navigation.dart';
import 'package:osl_umcollect/pages/home.dart';
import 'package:osl_umcollect/pages/login.dart';
import '../Components/Utils.dart';

class MeterReading extends StatefulWidget {
  final String staffid;
  const MeterReading({super.key, required this.staffid});

  @override
  State<MeterReading> createState() => _MeterReadingState();
}

class _MeterReadingState extends State<MeterReading> {
  final storage = const FlutterSecureStorage();
  String name = '';
  String phone = '';
  String station = '';
  String total_farmers = '';
  String reached_farmers = '';
  String workplans = '';
  String active = 'Pending';
  String id = '';
  String status = 'Pending';
  String nationalId = '';
  String formattedDate = '';
  String activities = '';
  String reports = '';
  String updates = '';
  String mapped = '';

  List stats = [];

  @override
  void initState() {
    getDefaultValues();
    super.initState();
  }

  Future<void> getDefaultValues() async {
    var token = await storage.read(key: "kwstaffjwt");
    var decoded = parseJwt(token.toString());

    formattedDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());
    if (decoded["error"] == "Invalid token") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const Login()));
    } else {
      setState(() {
        name = decoded["Name"];
        phone = decoded["Phone"];
        //  station = decoded["Department"];
        id = decoded["UserID"];
      });

      fetchStats(decoded["UserID"]);
      getFarmersSectionStats(decoded["Name"]);
    }
  }

  Future<void> fetchStats(String id) async {
    try {
      final dynamic response;

      response = await http.get(
        Uri.parse("${getUrl()}workplan/mobile/stats/$id"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      var data = json.decode(response.body);
      setState(() {
        activities = data["acToday"].toString();
        workplans = data["wpToday"].toString();
        reports = data["repToday"].toString();
      });
    } catch (e) {}
  }

  Future<void> getFarmersSectionStats(user) async {
    try {
      final response = await http.get(
        Uri.parse("${getUrl()}farmerdetails/mapped/$user"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
      );

      var body = json.decode(response.body);
      var mystats = body;

      List<int> numbers = [
        body["FD"],
        body["FA"],
        body["FR"],
        body["FG"],
        body["VC"]
      ];
      int minimum = numbers.reduce(
        (currentMin, element) => element < currentMin ? element : currentMin,
      );

      setState(() {
        total_farmers = mystats["TF"].toString(); // Convert to string
        mapped = minimum.toString();
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UM Navigator',
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Asset Navigation",
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
          backgroundColor: const Color.fromARGB(255, 28, 100, 140),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        drawer: StaffDrawer(
          staffid: widget.staffid,
        ),
        body: Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Column(
            children: <Widget>[
              Stack(
                children: [
                  Positioned(child: extendAppBar()),
                  Positioned(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                      child: displayUserInfo(),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 44,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => AssetNavigation(
                                          label: 'Customer Meters',
                                          staffid: widget.staffid,
                                        )));
                          },
                          child: MyRow(
                              no: activities,
                              title: 'Customer Meters',
                              image: 'assets/images/customer-meter.png'),
                        ),
                        const SizedBox(
                          height: 32,
                        ),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Asset Navigation",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 28, 100, 140),
                              )),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => AssetNavigation(
                                                label: 'Tanks',
                                                staffid: widget.staffid,
                                              )));
                                },
                                child: MyRowIII(
                                    no: workplans,
                                    title: 'Tanks',
                                    image: 'assets/images/water-tank.png'),
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => AssetNavigation(
                                                label: 'Valves',
                                                staffid: widget.staffid,
                                              )));
                                },
                                child: MyRowIII(
                                    no: reports,
                                    title: 'Valves',
                                    image: 'assets/images/valve.png'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => AssetNavigation(
                                                label: 'Manholes',
                                                staffid: widget.staffid,
                                              )));
                                },
                                child: MyRowIII(
                                  no: total_farmers,
                                  title: 'Manholes',
                                  image: 'assets/images/manhole.png',
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => AssetNavigation(
                                                label: 'Master Meters',
                                                staffid: widget.staffid,
                                              )));
                                },
                                child: MyRowIII(
                                    no: mapped,
                                    title: 'Master Meters',
                                    image: 'assets/images/water-meter.png'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => AssetNavigation(
                                                label: 'Facilities',
                                                staffid: widget.staffid,
                                              )));
                                },
                                child: MyRowIII(
                                  no: total_farmers,
                                  title: 'Facilities',
                                  image: 'assets/images/facility.png',
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => AssetNavigation(
                                                label: 'Incidences',
                                                staffid: widget.staffid,
                                              )));
                                },
                                child: MyRowIII(
                                    no: mapped,
                                    title: 'Incidences',
                                    image: 'assets/images/incident.png'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 48,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container extendAppBar() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color:
            Color.fromARGB(255, 28, 100, 140), // Set solid green color directly
      ),
      child: const Padding(
        padding: EdgeInsets.all(40),
      ),
    );
  }

  Container displayUserInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(137, 158, 158, 158),
              offset: Offset(2.0, 2.0),
              blurRadius: 5.0,
              spreadRadius: 2.0,
            ),
          ],
          borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Column(
                  children: [
                    const Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Welcome",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w800))),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        name,
                        style: const TextStyle(
                            color: Color.fromARGB(255, 28, 100, 140),
                            fontSize: 24,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          formattedDate,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        )),
                    const SizedBox(
                      height: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Image.asset(
                'assets/images/stat1.png', width: 84, // Set width of the image
                height: 84, // Set height of the image
                color: Colors.orange,
              )
            ],
          ),
          Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$activities Activity Today',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 28, 100, 140),
                ),
              )),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, unused_import, prefer_typing_uninitialized_variables

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:osl_umcollect/components/MyDrawer.dart';
import 'package:osl_umcollect/components/MyRow.dart';
import 'package:osl_umcollect/components/MyRowIII.dart';
import 'package:osl_umcollect/components/StaffDrawer.dart';
import 'package:osl_umcollect/components/Utils.dart';
import 'package:osl_umcollect/pages/Assets.dart';
import 'package:osl_umcollect/pages/Routing.dart';
import 'package:osl_umcollect/pages/complete.dart';
import 'package:osl_umcollect/pages/incidences.dart';
import 'package:osl_umcollect/pages/incidences_home.dart';
import 'package:osl_umcollect/pages/meterreading.dart';
import 'package:osl_umcollect/pages/pending.dart';
import 'package:osl_umcollect/pages/login.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:osl_umcollect/pages/stafflogin.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final storage = const FlutterSecureStorage();
  String name = '';
  String staffid = '';
  String position = '';
  String pending = '';
  String complete = '';
  String formattedDate = '';
  String offset = '0';
  bool isnew = false;
  var isLoading;

  List stats = [];

  @override
  void initState() {
    getDefaultValues();
    super.initState();
  }

  Future<void> getDefaultValues() async {
    try {
      var token = await storage.read(key: "kwstaffjwt");
      var decoded = parseJwt(token.toString());
      formattedDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());

      if (decoded["error"] == "Invalid token") {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const Login()));
      } else {
        setState(() {
          name = decoded["Name"];
          staffid = decoded["UserID"];
          position = decoded["Position"];
          isnew = true;
        });

        await storage.write(key: 'staffid', value: staffid);

        fetchStats(staffid, isnew);
      }
    } catch (e) {}
  }

  Future<void> fetchStats(String id, bool isnew) async {
    try {
      setState(() {
        isnew
            ? isLoading = LoadingAnimationWidget.horizontalRotatingDots(
                color: const Color.fromARGB(255, 28, 100, 140),
                size: 100,
              )
            : null;
      });
      final response = await get(
        Uri.parse("${getUrl()}reports/assigned/$id/0"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 203) {
        var data = json.decode(response.body);

        setState(() {
          pending = data['countP'];
          complete = data['countR'];
          isLoading = null;
        });
      } else {}
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UM Collect',
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Home",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 28, 100, 140),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        drawer: Drawer(
            child: StaffDrawer(
          staffid: staffid,
        )),
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
                height: 24,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => MeterReading(
                                staffid: staffid,
                              ),
                            ));
                          },
                          child: const MyRow(
                              no: "",
                              title: 'Asset Navigation',
                              image: 'assets/images/navigation.png'),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Incidences Management",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => IncidencesHome(
                                      staffid: staffid,
                                      selectedItem: 0,
                                    ), // Replace with the page you want to navigate to
                                  ));
                                },
                                child: MyRowIII(
                                    no: pending,
                                    title: 'Pending',
                                    image: 'assets/images/pending.png'),
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => IncidencesHome(
                                      staffid: staffid,
                                      selectedItem: 1,
                                    ), // Replace with the page you want to navigate to
                                  ));
                                },
                                child: MyRowIII(
                                    no: complete,
                                    title: 'Completed',
                                    image: 'assets/images/complete.png'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Asset Mapping",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Assets(
                                staffid: staffid,
                              ), // Replace with the page you want to navigate to
                            ));
                          },
                          child: const MyRow(
                            no: "",
                            title: 'Map Water & Sewer Network',
                            image: 'assets/images/map.png',
                          ),
                        ),
                        const SizedBox(
                          height: 24,
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
        color: Color.fromARGB(255, 28, 100, 140),
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
              color: Color.fromARGB(82, 158, 158, 158),
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
                  )),
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
                'Role: $position',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              )),
        ],
      ),
    );
  }
}

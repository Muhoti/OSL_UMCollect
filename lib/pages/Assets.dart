import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:osl_umcollect/components/StaffDrawer.dart';
import 'package:osl_umcollect/components/Utils.dart';
import 'package:osl_umcollect/components/gridview_assets.dart';
import 'package:osl_umcollect/pages/home.dart';
import 'package:geolocator/geolocator.dart';

class Assets extends StatefulWidget {
  final String staffid;
  const Assets({super.key, required this.staffid});

  @override
  State<Assets> createState() => _AssetsState();
}

class _AssetsState extends State<Assets> {
  final storage = const FlutterSecureStorage();
  String user = '';
  String id = '';
  bool servicestatus = false;

  late LocationPermission permission;
  bool haspermission = false;
  late Position position;

  getUserDetails() async {
    var token = await storage.read(key: "kwstaffjwt");
    var decoded = parseJwt(token.toString());

    setState(() {
      user = decoded["Name"];
      id = decoded["UserID"];
      storage.write(key: "UserName", value: user);
      storage.write(key: "UserID", value: id);
    });
  }

  @override
  void initState() {
    getUserDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map Assets',
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
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const Home()));
              },
            ),
          ],
          title: const Text(
            'Map Assets',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 28, 100, 140),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        drawer: StaffDrawer(
          staffid: widget.staffid,
        ),
        body: SafeArea(
          child: GridViewAssets(
            staffid: widget.staffid,
          ),
        ),
      ),
    );
  }
}

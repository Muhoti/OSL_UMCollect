import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:osl_umcollect/components/IRItem.dart';
import 'package:osl_umcollect/components/MyDrawer.dart';
import 'package:osl_umcollect/components/StaffDrawer.dart';
import 'package:osl_umcollect/pages/home.dart';

class Incidences extends StatefulWidget {
  const Incidences({super.key});

  @override
  State<Incidences> createState() => _IncidencesState();
}

class _IncidencesState extends State<Incidences> {
  final storage = const FlutterSecureStorage();

  var isstaff;
  var staffid;

  @override
  void initState() {
    checkStaff();
    super.initState();
  }

  checkStaff() async {
    var staff = await storage.read(key: "isstaff");
    var id = await storage.read(key: "staffid");

    print("staff is $staff");

    setState(() {
      isstaff = staff;
      staffid = id;
    });

    print("isstaff is $isstaff, $staffid");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Incidences',
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
            'Report an Incident',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 28, 100, 140),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        drawer: isstaff == 'true'
            ? StaffDrawer(staffid: staffid)
            : const MyDrawer(),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                  child: Row(
                children: [
                  IRItem(
                    incident: 'Leakage',
                    asset: 'assets/images/leakage.png',
                    image: 'assets/images/leaks.png',
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  IRItem(
                    incident: 'Supply Fail',
                    asset: 'assets/images/supfail.png',
                    image: 'assets/images/supplyfail.png',
                  ),
                ],
              )),
              SizedBox(
                height: 16,
              ),
              Expanded(
                  child: Row(
                children: [
                  IRItem(
                    incident: 'Vandalism',
                    asset: 'assets/images/vandal.png',
                    image: 'assets/images/vandalism.png',
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  IRItem(
                    incident: 'Illegal Connection',
                    asset: 'assets/images/illegal.png',
                    image: 'assets/images/illegalconnection.png',
                  ),
                ],
              )),
              SizedBox(
                height: 16,
              ),
              Expanded(
                  child: Row(
                children: [
                  IRItem(
                    incident: 'Sewer Burst',
                    asset: 'assets/images/sewerb.png',
                    image: 'assets/images/burst.png',
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  IRItem(
                    incident: 'Other',
                    asset: 'assets/images/otherb.png',
                    image: 'assets/images/other.jpeg',
                  ),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
}

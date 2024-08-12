// ignore_for_file: must_be_immutable, unused_import

import 'package:flutter/material.dart';
import 'package:osl_umcollect/models/grid_icons.dart';
import 'package:osl_umcollect/pages/Forms/CustomerMeters1.dart';
import 'package:osl_umcollect/pages/Forms/CustomerMeters3.dart';
import 'package:osl_umcollect/pages/Forms/ManHoles.dart';
import 'package:osl_umcollect/pages/Forms/MasterMeters.dart';
import 'package:osl_umcollect/pages/Forms/PointProjects.dart';
import 'package:osl_umcollect/pages/Forms/Tanks.dart';
import 'package:osl_umcollect/pages/Forms/Valves.dart';
import 'package:osl_umcollect/pages/Forms/Washouts.dart';
import 'package:osl_umcollect/pages/MappingLines.dart';

class GridViewAssets extends StatefulWidget {
  final String staffid;
  GridViewAssets({super.key, required this.staffid});
  @override
  State<GridViewAssets> createState() => _GridViewAssetsState();
}

class _GridViewAssetsState extends State<GridViewAssets> {
  List<String> waterNetworkImages = GridIcons().getWaterNetworkImages();
  List<String> waterNetworkTitles = GridIcons().getWaterNetworkTitles();
  List<String> sewerNetworkImages = GridIcons().getSewerNetworkImages();
  List<String> sewerNetworkTitles = GridIcons().getSewerNetworkTitles();
  List<String> newProjectImages = GridIcons().getNewProjectImages();
  List<String> newProjectTitles = GridIcons().getNewProjectTitles();

  void _showDialog(BuildContext context, assetName) async {
    switch (assetName) {
      case 'Customer Meters':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => CustomerMeters1(
                      staffid: widget.staffid,
                    )));
        break;
      case 'Water Pipes':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => MappingLines(
                    assetName: assetName,
                    staffid: widget.staffid,
                  )),
        );
        break;
      case 'Water Tanks':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => Tanks(
                    staffid: widget.staffid,
                  )),
        );
        break;
      case 'Valves':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => Valves(
                    staffid: widget.staffid,
                  )),
        );
        break;
      case 'Master Meters':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => MasterMeters(
                    staffid: widget.staffid,
                  )),
        );
        break;
      case 'Washouts':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => Washouts(
                    staffid: widget.staffid,
                  )),
        );
        break;
      case 'Sewer Lines':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => MappingLines(
                    assetName: assetName,
                    staffid: widget.staffid,
                  )),
        );
        break;
      case 'Manholes':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ManHoles(
                    staffid: widget.staffid,
                  )),
        );
        break;
      case 'Projects (Point)':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => PointProjects(
                    staffid: widget.staffid,
                  )),
        );
        break;
      case 'Projects (Linear)':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => MappingLines(
                    assetName: assetName,
                    staffid: widget.staffid,
                  )),
        );
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Water Networks', // Title here
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 28, 100, 140),
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap:
                true, // Added to prevent the grid from taking extra space
            physics:
                const NeverScrollableScrollPhysics(), // Added to prevent scrolling within the grid
            itemCount: waterNetworkImages.length,
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250,
            ),
            scrollDirection: Axis.vertical,
            clipBehavior: Clip.hardEdge,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  _showDialog(context, waterNetworkTitles[index]);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: const Color(0xffEC7C24),
                    elevation: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Material(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8)),
                          clipBehavior: Clip.hardEdge,
                          color: const Color.fromARGB(255, 207, 236, 252),
                          child: Image.asset(
                            waterNetworkImages[index],
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          waterNetworkTitles[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Sewer Networks', // Title here
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 28, 100, 140),
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap:
                true, // Added to prevent the grid from taking extra space
            physics:
                const NeverScrollableScrollPhysics(), // Added to prevent scrolling within the grid
            itemCount: sewerNetworkImages.length,
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250,
            ),
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  _showDialog(context, sewerNetworkTitles[index]);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: const Color(0xffEC7C24),
                    elevation: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Material(
                          color: const Color.fromARGB(255, 252, 230, 224),
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8)),
                          clipBehavior: Clip.hardEdge,
                          child: Image.asset(
                            sewerNetworkImages[index],
                            width: double.infinity,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          sewerNetworkTitles[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'New Project', // Title here
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 28, 100, 140),
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap:
                true, // Added to prevent the grid from taking extra space
            physics:
                const NeverScrollableScrollPhysics(), // Added to prevent scrolling within the grid
            itemCount: newProjectImages.length,
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250,
            ),
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  _showDialog(context, newProjectTitles[index]);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: const Color(0xffEC7C24),
                    elevation: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Material(
                          color: const Color.fromARGB(255, 215, 247, 216),
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8)),
                          child: Image.asset(
                            newProjectImages[index],
                            width: double.infinity,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          newProjectTitles[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

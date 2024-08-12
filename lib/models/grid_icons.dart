// ignore_for_file: unused_import

import 'package:flutter/material.dart';

class GridIcons {
  List<String> getImagePaths() {
    return [
      'assets/images/leaks.png',
      'assets/images/burst.png',
      'assets/images/supplyfail.png',
      'assets/images/illegalconnection.png',
      'assets/images/vandalism.png',
      'assets/images/other.png',
    ];
  }

  List<String> getIncidences() {
    return [
      'Leakage',
      'Sewer Burst',
      'Supply Fail',
      'Illegal Connection',
      'Vandalism',
      'Other',
    ];
  }

  List<String> getWaterNetworkImages() {
    return [
      'assets/images/customer-meter.png',
      'assets/images/water-pipe.png',
      'assets/images/water-tank.png',
      'assets/images/valve.png',
      'assets/images/water-meter.png',
      'assets/images/washout.png',
    ];
  }

  List<String> getWaterNetworkTitles() {
    return [
      'Customer Meters',
      'Water Pipes',
      'Water Tanks',
      'Valves',
      'Master Meters',
      'Washouts',
    ];
  }

  List<String> getSewerNetworkImages() {
    return [
      'assets/images/sewer.png',
      'assets/images/manhole.png',
    ];
  }

  List<String> getSewerNetworkTitles() {
    return [
      'Sewer Lines',
      'Manholes',
    ];
  }

  List<String> getNewProjectImages() {
    return [
      'assets/images/points.png',
      'assets/images/lines.png',
    ];
  }

  List<String> getNewProjectTitles() {
    return [
      'Projects (Point)',
      'Projects (Linear)',
    ];
  }
}

import 'dart:convert';
import 'package:flutter_html/flutter_html.dart' as html;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'package:osl_umcollect/Components/Utils.dart';
import 'package:osl_umcollect/components/MyDrawer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' show cos, sqrt, asin;
import 'dart:math' as math;
import 'package:http/http.dart' as http;

class AssetNavigation extends StatefulWidget {
  final String label;
  final String staffid;
  const AssetNavigation({
    Key? key,
    required this.label,
    required this.staffid,
  }) : super(key: key);

  @override
  _AssetNavigationState createState() => _AssetNavigationState();
}

class _AssetNavigationState extends State<AssetNavigation> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Completer<GoogleMapController?> _controller = Completer();
  Map<PolylineId, Polyline> polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  Location location = Location();
  Marker? sourcePosition, destinationPosition;
  late BitmapDescriptor _vehicleIcon;
  LatLng curLocation = const LatLng(-1.2940491, 36.8076449);
  StreamSubscription<LocationData>? locationSubscription;
  bool _isVisible = false;
  bool routing = false;
  String html_instructions = "";
  String distance = "";
  String duration = "";
  String maneuver = "";
  String small_duration = "";
  String small_distance = "";
  var lat = 0.0, lon = 0.0;
  var selected;
  var choice;
  LatLng destination = const LatLng(0.0, 0.0);
  var loading;

  @override
  void initState() {
    super.initState();
    initializeServices();
  }

  initializeServices() async {
    _vehicleIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 0.5),
      'assets/images/car.png',
    );
    _getCurrentLocation();
    addMarker(_vehicleIcon);
    getNavigation(_vehicleIcon);
  }

  void _getCurrentLocation() async {
    try {
      geolocator.Position position =
          await geolocator.Geolocator.getCurrentPosition(
        desiredAccuracy: geolocator.LocationAccuracy.high,
      );

      setState(() {
        curLocation = LatLng(position.latitude, position.longitude);
        sourcePosition = Marker(
          markerId: MarkerId(position.toString()),
          icon: _vehicleIcon,
          position: LatLng(position.latitude, position.longitude),
          anchor: const Offset(0.5, 0.5),
        );
      });

      _updateCameraPosition(
          LatLng(position.latitude, position.longitude), position.heading);
    } catch (e) {}
  }

  Future<void> _fitCameraToBounds(LatLng position1, LatLng position2) async {
    _updateCameraPosition(position1, 0);
    try {
      final GoogleMapController? controller = await _controller.future;
      LatLngBounds bounds = LatLngBounds(
        southwest: position1,
        northeast: position2,
      );
      CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 50);
      controller?.animateCamera(cameraUpdate);
    } catch (e) {
      _updateCameraPosition(position1, 0);
    }
  }

  void _updateCameraPosition(LatLng newPosition, double newRotation) async {
    try {
      final GoogleMapController? controller = await _controller.future;
      await controller?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: newPosition,
            zoom: 16,
            bearing: newRotation,
          ),
        ),
      );
    } catch (e) {}
  }

  getNavigation(BitmapDescriptor _vehicleIcon) async {
    try {
      bool _serviceEnabled;
      PermissionStatus _permissionGranted;
      location.changeSettings(
          accuracy: LocationAccuracy.navigation, distanceFilter: 5);
      _serviceEnabled = await location.serviceEnabled();

      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }
      if (_permissionGranted == PermissionStatus.granted) {
        locationSubscription =
            location.onLocationChanged.listen((LocationData currentLocation) {
          if (routing && destination.latitude != 0.0) {
            setState(() {
              curLocation =
                  LatLng(currentLocation.latitude!, currentLocation.longitude!);
              sourcePosition = Marker(
                markerId: MarkerId(currentLocation.toString()),
                icon: _vehicleIcon,
                position: LatLng(
                    currentLocation.latitude!, currentLocation.longitude!),
                anchor: const Offset(0.5, 0.5),
              );
            });

            getDirections(destination);
            getNavigationInstructions(destination);
          }
        });
      }
    } catch (e) {}
  }

  getDirections(LatLng dst) async {
    try {
      List<LatLng> polylineCoordinates = [];
      List<dynamic> points = [];
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          'AIzaSyAuvt2CB5r1jLoA5k00VnDkJmrAM3cL52g',
          PointLatLng(curLocation.latitude, curLocation.longitude),
          PointLatLng(dst.latitude, dst.longitude),
          travelMode: TravelMode.driving);

      setState(() {
        distance = result.distance!;
        duration = result.duration!;
      });

      if (result.points.isNotEmpty) {
        if (result.points.length > 1 && routing) {
          PointLatLng point0 = result.points[0];
          PointLatLng point1 = result.points[1];
          double bearing = calculateHeading(
              LatLng(point0.latitude, point0.longitude),
              LatLng(point1.latitude, point1.longitude));
          _updateCameraPosition(curLocation, bearing);
        }

        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          points.add({'lat': point.latitude, 'lng': point.longitude});
        });
      } else {}
      addPolyLine(polylineCoordinates);
    } catch (e) {}
  }

  Future<void> getNavigationInstructions(LatLng dst) async {
    try {
      double originLat = curLocation.latitude; // Origin latitude
      double originLng = curLocation.longitude; // Origin longitude
      double destinationLat = dst.latitude; // Destination latitude
      double destinationLng = dst.longitude; // Destination longitude
      String apiKey = 'AIzaSyAuvt2CB5r1jLoA5k00VnDkJmrAM3cL52g';

      String url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=$originLat,$originLng&destination=$destinationLat,$destinationLng&key=$apiKey&steps=true';
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'OK') {
          List<dynamic> routes = data['routes'];
          if (routes.isNotEmpty) {
            List<dynamic> steps = routes[0]['legs'][0]['steps'];

            setState(() {
              html_instructions = steps[0]["html_instructions"];
              small_duration = steps[0]["duration"]["text"];
              small_distance = steps[0]["distance"]["text"];
              maneuver = steps[0]["maneuver"];
            });
          }
        }
      } else {}
    } catch (e) {}
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: const Color.fromARGB(255, 23, 117, 126),
      points: polylineCoordinates,
      width: 5,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return double.parse((12742 * asin(sqrt(a))).toStringAsFixed(2));
  }

  double calculateHeading(LatLng from, LatLng to) {
    // Convert coordinates from degrees to radians
    double fromLat = from.latitude * math.pi / 180;
    double fromLng = from.longitude * math.pi / 180;
    double toLat = to.latitude * math.pi / 180;
    double toLng = to.longitude * math.pi / 180;

    // Calculate bearing using Haversine formula
    double deltaLng = toLng - fromLng;
    double y = math.sin(deltaLng) * math.cos(toLat);
    double x = math.cos(fromLat) * math.sin(toLat) -
        math.sin(fromLat) * math.cos(toLat) * math.cos(deltaLng);
    double bearing = math.atan2(y, x);

    // Convert bearing from radians to degrees
    bearing = bearing * 180 / math.pi;

    // Normalize the bearing to be in the range [0, 360]
    bearing = (bearing + 360) % 360;

    return bearing;
  }

  double getDistance(LatLng destposition) {
    return calculateDistance(curLocation.latitude, curLocation.longitude,
        destposition.latitude, destposition.longitude);
  }

  addMarker(BitmapDescriptor _vehicleIcon) {
    setState(() {
      sourcePosition = Marker(
        markerId: const MarkerId('source'),
        position: curLocation,
        icon: _vehicleIcon,
      );
    });
  }

  IconData _getMeneuverIcon(String mn) {
    switch (mn) {
      case 'turn-left':
        return Icons.turn_left;
      case 'turn-right':
        return Icons.turn_right;
      case 'turn-slight-left':
        return Icons.turn_slight_left;
      case 'turn-slight-right':
        return Icons.turn_slight_right;
      case 'turn-sharp-left':
        return Icons.turn_sharp_left;
      case 'turn-sharp-right':
        return Icons.turn_sharp_right;
      case 'merge':
        return Icons.merge;
      case 'fork-left':
        return Icons.fork_left;
      case 'fork-right':
        return Icons.fork_right;
      case 'ramp-left':
        return Icons.trending_down;
      case 'ramp-right':
        return Icons.trending_up;
      case 'keep-left':
        return Icons.straight;
      case 'keep-right':
        return Icons.straight;
      case 'roundabout-left':
        return Icons.roundabout_left;
      case 'roundabout-right':
        return Icons.roundabout_right;
      case 'uturn-left':
        return Icons.u_turn_left;
      case 'uturn-right':
        return Icons.u_turn_right;
      case 'straight':
        return Icons.straight;
      case 'depart':
        return Icons.trip_origin;
      case 'arrive':
        return Icons.flag;
      default:
        return Icons.straight;
    }
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    super.dispose();
  }

  void searchIncidenID(String v) async {
    try {
      final response = await http.get(
        Uri.parse("${getUrl()}reports/serial/search/$v"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 203) {
        List<dynamic> body = jsonDecode(response.body);

        if (body.isNotEmpty) {
          setState(() {
            selected = body.first;
          });
        } else {
          setState(() {
            selected = null;
          });
        }
      } else {}
    } catch (e) {
      setState(() {
        selected = null;
      });
    }
  }

  void searchFacilityByName(String v) async {
    try {
      final response = await http.get(
        Uri.parse("${getUrl()}facilities/search/$v"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 203) {
        List<dynamic> body = jsonDecode(response.body);

        print("facilities: $body");

        if (body.isNotEmpty) {
          setState(() {
            selected = body.first;
          });
        } else {
          setState(() {
            selected = null;
          });
        }
      } else {}
    } catch (e) {
      setState(() {
        selected = null;
      });
    }
  }

  void searchObjectID(String v) async {
    try {
      final response = await http.get(
        Uri.parse(
            "${getUrl()}customers/searchothers/${widget.label.replaceAll(RegExp(" "), "")}/$v"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 203) {
        List<dynamic> body = jsonDecode(response.body);
        if (body.isNotEmpty) {
          setState(() {
            selected = body.first;
          });
        } else {
          setState(() {
            selected = null;
          });
        }
      }
    } catch (e) {
      setState(() {
        selected = null;
      });
    }
  }

  void searchAccounts(String v) async {
    try {
      final response = await http.get(
        Uri.parse("${getUrl()}customers/searchone/$v"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 203) {
        List<dynamic> body = jsonDecode(response.body);

        if (body.isNotEmpty) {
          setState(() {
            selected = body.first;
          });
        } else {
          setState(() {
            selected = null;
          });
        }
      } else {}
    } catch (e) {
      setState(() {
        selected = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                "Navigation - ${widget.label}",
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back),
            )
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 28, 100, 140),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
              height: double.infinity,
              width: double.infinity,
              decoration: const BoxDecoration(color: Colors.white54),
              child: Stack(
                children: [
                  GoogleMap(
                    zoomControlsEnabled: false,
                    polylines: Set<Polyline>.of(polylines.values),
                    initialCameraPosition: CameraPosition(
                      target: curLocation,
                      zoom: 18,
                    ),
                    markers:
                        sourcePosition != null && destinationPosition != null
                            ? {sourcePosition!, destinationPosition!}
                            : {},
                    onTap: (latLng) {},
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                  ),
                  !routing
                      ? AnimatedPositioned(
                          left: 0,
                          right: 0,
                          curve: Curves.easeInOut,
                          bottom: _isVisible ? 0 : -50,
                          duration: const Duration(milliseconds: 300),
                          child: GestureDetector(
                            onVerticalDragEnd: (details) {
                              if (details.primaryVelocity! > 0) {
                                // Swipe down
                                setState(() {
                                  _isVisible = false;
                                });
                              } else {
                                // Swipe up
                                setState(() {
                                  _isVisible = true;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(30),
                                      topRight: Radius.circular(30)),
                                  color: Color.fromARGB(255, 255, 255, 255)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        50, 0, 50, 12),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                          color: Color.fromARGB(
                                              255, 226, 226, 226),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      height: 10,
                                      width: double.infinity,
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(
                                        color: Color(0xffF6F5F2),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12))),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        selected != null
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 0, 0, 16),
                                                child: TextButton(
                                                    onPressed: () {
                                                      print(
                                                          "selected: $selected");
                                                      FocusScope.of(context)
                                                          .unfocus();
                                                      setState(() {
                                                        choice = selected;
                                                        selected = null;
                                                        destination = LatLng(
                                                            double.tryParse(choice[
                                                                    "Latitude"]
                                                                .toString())!,
                                                            double.tryParse(choice[
                                                                    "Longitude"]
                                                                .toString())!);
                                                        destinationPosition =
                                                            Marker(
                                                          markerId:
                                                              const MarkerId(
                                                                  'destination'),
                                                          position: LatLng(
                                                              destination
                                                                  .latitude,
                                                              destination
                                                                  .longitude),
                                                          icon: BitmapDescriptor
                                                              .defaultMarkerWithHue(
                                                                  BitmapDescriptor
                                                                      .hueOrange),
                                                        );
                                                        _updateCameraPosition(
                                                            destination, 0);
                                                      });
                                                    },
                                                    child: Container(
                                                      width: double.infinity,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                      0.2), // shadow color
                                                              spreadRadius:
                                                                  2, // spread radius
                                                              blurRadius:
                                                                  2, // blur radius
                                                              offset: const Offset(
                                                                  0,
                                                                  2), // changes position of shadow
                                                            )
                                                          ],
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          5))),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          widget.label ==
                                                                  "Incidences"
                                                              ? Text(
                                                                  'Serial: ${selected["SerialNo"]}',
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .grey,
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                )
                                                              : Text(
                                                                  selected[
                                                                      "Name"],
                                                                  style: const TextStyle(
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          28,
                                                                          100,
                                                                          140),
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          widget.label ==
                                                                  "Customer Meters"
                                                              ? Text(
                                                                  'Account No: ${selected["AccountNo"]}',
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .grey,
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                )
                                                              : widget.label ==
                                                                      "Incidences"
                                                                  ? Text(
                                                                      'Type: ${selected["Type"]}',
                                                                      style: const TextStyle(
                                                                          color: Colors
                                                                              .grey,
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    )
                                                                  : Text(
                                                                      'Object ID: ${selected["ObjectID"]}',
                                                                      style: const TextStyle(
                                                                          color: Colors
                                                                              .grey,
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                        ],
                                                      ),
                                                    )),
                                              )
                                            : const SizedBox(),
                                        Stack(
                                          children: [
                                            TextField(
                                              onChanged: (value) {
                                                if (value != "") {
                                                  if (widget.label ==
                                                      "Customer Meters") {
                                                    searchAccounts(value);
                                                  } else if (widget.label ==
                                                      "Incidences") {
                                                    searchIncidenID(value);
                                                  } else if (widget.label ==
                                                      "Facilities") {
                                                    searchFacilityByName(value);
                                                  } else {
                                                    searchObjectID(value);
                                                  }
                                                } else {
                                                  setState(() {
                                                    selected = null;
                                                  });
                                                }
                                              },
                                              decoration: InputDecoration(
                                                  contentPadding:
                                                      const EdgeInsets.all(12),
                                                  border:
                                                      const OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          44)),
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          28,
                                                                          100,
                                                                          140))),
                                                  filled: false,
                                                  label: Text(
                                                    widget.label ==
                                                            "Customer Meters"
                                                        ? "Name/Account No"
                                                        : widget.label ==
                                                                "Incidences"
                                                            ? "Name/Serial No"
                                                            : "Name/ObjectID",
                                                    style: const TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 28, 100, 140)),
                                                  ),
                                                  floatingLabelBehavior:
                                                      FloatingLabelBehavior
                                                          .auto),
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 12, 12, 0),
                                              child: Align(
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: Icon(
                                                  Icons.search,
                                                  color: Color.fromARGB(
                                                      255, 28, 100, 140),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10.0),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(
                                        color: Color(0xffF6F5F2),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12))),
                                    child: Column(
                                      children: [
                                        Text(
                                          "Trip Details: ${choice != null ? choice["Name"] : "Not Selected"}",
                                          softWrap: true,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            const Icon(
                                              Icons.directions_car,
                                              size: 44,
                                              color: Color.fromARGB(
                                                  255, 28, 100, 140),
                                            ),
                                            const SizedBox(
                                              width: 12,
                                            ),
                                            Expanded(
                                              child: TextButton(
                                                  onPressed: () {
                                                    if (choice != null) {
                                                      setState(() {
                                                        routing = true;
                                                        choice = null;
                                                      });
                                                      getDirections(
                                                          destination);
                                                      getNavigationInstructions(
                                                          destination);
                                                    } else {
                                                      _showSnackbar(
                                                          context,
                                                          'No asset is selected!',
                                                          Colors.orange);
                                                    }
                                                  },
                                                  style: const ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStatePropertyAll(
                                                    Color.fromARGB(
                                                        255, 28, 100, 140),
                                                  )),
                                                  child: const Text(
                                                    "Start Trip",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  )),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10.0),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(
                                        color: Color(0xffF6F5F2),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12))),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        const Icon(
                                          Icons.map,
                                          size: 44,
                                          color:
                                              Color.fromARGB(255, 28, 100, 140),
                                        ),
                                        const SizedBox(
                                          width: 12,
                                        ),
                                        Expanded(
                                          child: TextButton(
                                              onPressed: () async {
                                                if (choice != null) {
                                                  await launchUrl(Uri.parse(
                                                      'google.navigation:q=${destination.latitude}, ${destination.longitude}&key=AIzaSyAuvt2CB5r1jLoA5k00VnDkJmrAM3cL52g'));
                                                } else {
                                                  _showSnackbar(
                                                      context,
                                                      'No asset is selected!',
                                                      Colors.orange);
                                                }
                                              },
                                              style: const ButtonStyle(
                                                  side:
                                                      MaterialStatePropertyAll(
                                                          BorderSide(
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      28,
                                                                      100,
                                                                      140),
                                                              width: 1)),
                                                  backgroundColor:
                                                      MaterialStatePropertyAll(
                                                          Colors.transparent)),
                                              child: const Text(
                                                "Get Directions on Google Map",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Color.fromARGB(
                                                        255, 28, 100, 140),
                                                    fontWeight:
                                                        FontWeight.w400),
                                              )),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10.0),
                                ],
                              ),
                            ),
                          ),
                        )
                      : AnimatedPositioned(
                          bottom: 8,
                          left: 8,
                          right: 8,
                          duration: const Duration(milliseconds: 0),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(12)),
                              color: const Color.fromARGB(255, 255, 255, 255),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey
                                      .withOpacity(0.5), // Shadow color
                                  spreadRadius: 5, // Spread radius
                                  blurRadius: 7, // Blur radius
                                  offset: const Offset(
                                      0, 3), // Offset from the top-left corner
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Text(
                                    "Trip Details: $distance - $duration",
                                    style: const TextStyle(
                                        color:
                                            Color.fromARGB(255, 23, 117, 126),
                                        fontSize: 16),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        child: Column(
                                          children: [
                                            Icon(
                                              _getMeneuverIcon(maneuver),
                                              size: 44,
                                              color: const Color.fromARGB(
                                                  255, 23, 117, 126),
                                            ),
                                            const SizedBox(
                                              height: 2,
                                            ),
                                            Text(
                                              small_duration,
                                              softWrap: true,
                                            ),
                                            Text(
                                              small_distance,
                                              softWrap: true,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      flex: 5, // Adjust flex value as needed
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Color(0xffF6F5F2),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                        padding: const EdgeInsets.all(8.0),
                                        child: SingleChildScrollView(
                                          // Wrap with SingleChildScrollView to handle overflow
                                          child: html.Html(
                                            data: html_instructions,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              routing = false;
                                            });
                                            locationSubscription?.cancel();
                                          },
                                          child: const Icon(
                                            Icons.close_rounded,
                                            size: 32,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                ],
              )),
        ],
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
    ));
  }

  DateTime parsePostgresTimestamp(String timestamp) {
    return DateTime.parse(timestamp)
        .toLocal(); // Parse timestamp and convert to local time
  }

  Future<void> _makePhoneCall(String scheme, String phoneNumber) async {
    try {
      if (scheme == "tel") {
        canLaunchUrl(Uri(scheme: scheme, path: phoneNumber))
            .then((bool result) async {
          if (result) {
            final Uri launchUri = Uri(
              scheme: 'tel',
              path: phoneNumber,
            );
            await launchUrl(launchUri);
          }
        });
      } else {
        final Uri smsLaunchUri = Uri(
          scheme: 'sms',
          path: phoneNumber.replaceFirst(RegExp(r'^.'), '+254'),
          queryParameters: <String, String>{
            'body': 'Hi, hold on. I am on the way!',
          },
        );
        await launchUrl(smsLaunchUri);
      }
    } catch (e) {}
  }
}

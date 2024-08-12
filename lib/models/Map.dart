import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MyMap extends StatefulWidget {
  final double lat;
  final double lon;
  final double acc;

  const MyMap(
      {Key? key, required this.lat, required this.lon, required this.acc})
      : super(key: key);

  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  final Completer<GoogleMapController?> _controller = Completer();
  Marker? sourcePosition;
  late BitmapDescriptor _vehicleIcon;
  var isLoading = true; // Changed to bool for simplicity
  LatLng curLocation = const LatLng(-1.2940491, 36.8076449);

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
      curLocation = LatLng(widget.lat, widget.lon);
    });
    addMarker();
  }

  addMarker() async {
    _vehicleIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 0.5),
      'assets/images/loc.png',
    );
    setState(() {
      sourcePosition = Marker(
        markerId: const MarkerId('source'),
        position: curLocation,
        icon: _vehicleIcon,
        anchor: const Offset(0.5, 0.5),
      );
    });
  }

  @override
  void didUpdateWidget(covariant MyMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lat != widget.lat || oldWidget.lon != widget.lon) {
      _updateCameraPosition(LatLng(widget.lat, widget.lon));
      setState(() {
        curLocation = LatLng(widget.lat, widget.lon);
        sourcePosition = sourcePosition!
            .copyWith(positionParam: LatLng(widget.lat, widget.lon));
      });
    }
  }

  void _updateCameraPosition(LatLng newPosition) async {
    try {
      final GoogleMapController? controller = await _controller.future;
      await controller?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: newPosition,
            zoom: 20,
          ),
        ),
      );
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          clipBehavior: Clip.hardEdge,
          elevation: 2,
          child: GoogleMap(
            zoomControlsEnabled: false,
            mapType: MapType.satellite,
            initialCameraPosition: CameraPosition(
              target: curLocation,
              zoom: 12,
            ),
            markers: sourcePosition != null ? {sourcePosition!} : {},
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              setState(() {
                isLoading = false;
              });
            },
          ),
        ),
        Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                    child: Text("Accuracy: ${widget.acc.floorToDouble()}"),
                  )),
            )),
        Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                    child: Text("Lat: ${widget.lat}"),
                  )),
            )),
        Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                    child: Text("Lon: ${widget.lon}"),
                  )),
            )),
        if (isLoading)
          Center(
            child: LoadingAnimationWidget.horizontalRotatingDots(
                color: Colors.yellow, size: 100),
          ),
      ],
    );
  }
}

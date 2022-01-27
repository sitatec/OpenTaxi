import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared/shared.dart';

class MapWidget extends StatefulWidget {
  final EdgeInsets padding;
  final Set<Polyline> polylines;
  final Completer<GoogleMapController> controller;
  final Set<Marker> markers;
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;
  final Coordinates? initialCoordinates;

  const MapWidget({
    Key? key,
    this.padding = EdgeInsets.zero,
    this.polylines = const {},
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = false,
    this.initialCoordinates,
    required this.controller,
    this.markers = const {},
  }) : super(key: key);

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  LatLng _getInitalLocation() {
    if (widget.initialCoordinates != null) {
      return LatLng(
        widget.initialCoordinates!.latitude,
        widget.initialCoordinates!.longitude,
      );
    } else {
      return const LatLng(-34.2973267, 18.252956); // South Africa
    }
  }

  CameraPosition _getInitialCameraPosition() {
    return CameraPosition(
      target: _getInitalLocation(),
      zoom: 5,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      padding: widget.padding,
      initialCameraPosition: _getInitialCameraPosition(),
      zoomControlsEnabled: false,
      markers: widget.markers,
      polylines: widget.polylines,
      onMapCreated: (GoogleMapController controller) {
        widget.controller.complete(controller);
      },
      myLocationEnabled: widget.myLocationEnabled,
      myLocationButtonEnabled: widget.myLocationButtonEnabled,
    );
  }
}

List<LatLng> decodePolyline(String input) {
  var list = input.codeUnits;
  List lList = [];
  int index = 0;
  int len = input.length;
  int c = 0;
  List<LatLng> positions = [];
  // repeating until all attributes are decoded
  do {
    var shift = 0;
    int result = 0;

    // for decoding value of one attribute
    do {
      c = list[index] - 63;
      result |= (c & 0x1F) << (shift * 5);
      index++;
      shift++;
    } while (c >= 32);
    /* if value is negetive then bitwise not the value */
    if (result & 1 == 1) {
      result = ~result;
    }
    var result1 = (result >> 1) * 0.00001;
    lList.add(result1);
  } while (index < len);

  /*adding to previous value as done in encoding */
  for (int i = 2; i < lList.length; i++) {
    lList[i] += lList[i - 2];
  }

  for (int i = 0; i < lList.length; i += 2) {
    positions.add(LatLng(lList[i], lList[i + 1]));
  }

  return positions;
}

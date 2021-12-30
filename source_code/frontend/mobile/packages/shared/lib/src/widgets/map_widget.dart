import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatefulWidget {
  final EdgeInsets padding;
  final Map<String, String> encodedPolylines;
  final Completer<GoogleMapController> controller;
  final Set<Marker> markers;
  const MapWidget({
    Key? key,
    this.padding = EdgeInsets.zero,
    this.encodedPolylines = const {},
    required this.controller,
    this.markers = const {},
  }) : super(key: key);

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  static const CameraPosition _southAfrica = CameraPosition(
    target: LatLng(-34.2973267, 18.252956),
    zoom: 5,
  );

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      padding: widget.padding,
      initialCameraPosition: _southAfrica,
      zoomControlsEnabled: false,
      markers: widget.markers,
      polylines: _getPolylines(),
      onMapCreated: (GoogleMapController controller) {
        widget.controller.complete(controller);
      },
    );
  }

  Set<Polyline> _getPolylines() {
    final polylines = <Polyline>{};
    widget.encodedPolylines.forEach((polylineId, encodedPolyline) {
      polylines.add(
        Polyline(
          polylineId: PolylineId(polylineId),
          points: _decodePolyline(encodedPolyline),
        ),
      );
    });
    return polylines;
  }
}

List<LatLng> _decodePolyline(String input) {
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

import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared/shared.dart';

class ChoosePlaceOnMapPage extends StatefulWidget {
  const ChoosePlaceOnMapPage({Key? key}) : super(key: key);

  @override
  _ChoosePlaceOnMapPageState createState() => _ChoosePlaceOnMapPageState();
}

class _ChoosePlaceOnMapPageState extends State<ChoosePlaceOnMapPage> {
  final markerKey = GlobalKey();
  final Completer<GoogleMapController> controller = Completer();
  Coordinates? currentLocation;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _showCustomMarker();
  }

  Future<void> _showCustomMarker() async {
    currentLocation = await LocationManager().getCurrentCoordinates();
    final markerIcon = await _getCustomIcon(markerKey);
    setState(() {
      markers = {
        Marker(
          markerId: const MarkerId("location_marker"),
          icon: markerIcon,
          draggable: true,
          position: LatLng(
            currentLocation!.latitude,
            currentLocation!.longitude,
          ),
        )
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: Colors.black87,
        title: const Text(
          "Choose Address On Map",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          RepaintBoundary(
            key: markerKey,
            child: Column(
              children: [
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                    side: const BorderSide(color: Color(0xFF0A84FF)),
                  ),
                ),
                Container(
                  width: 10,
                  height: 100,
                  color: Colors.black87,
                ),
              ],
            ),
          ),
          MapWidget(
            controller: controller,
            markers: markers,
            initialCoordinates: currentLocation,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            padding: const EdgeInsets.only(bottom: 250),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40, left: 24, right: 24),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        // TODO return choosen stree address
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: const Text(
                          "Choose",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        elevation: 3,
                        backgroundColor: theme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<Uint8List> _capturePng(GlobalKey iconKey) async {
  RenderRepaintBoundary boundary =
      iconKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  if (boundary.debugNeedsPaint) {
    log("Waiting for boundary to be painted.");
    await Future.delayed(const Duration(milliseconds: 20));
    return _capturePng(iconKey);
  }
  ui.Image image = await boundary.toImage(pixelRatio: 3.0);

  ByteData byteData = (await image.toByteData(format: ui.ImageByteFormat.png))!;

  return byteData.buffer.asUint8List();
}

Future<BitmapDescriptor> _getCustomIcon(GlobalKey iconKey) async {
  Uint8List imageData = await _capturePng(iconKey);
  return BitmapDescriptor.fromBytes(imageData);
}

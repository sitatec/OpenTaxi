import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';

class FavoritePlaceFormWideget extends StatefulWidget {
  final TextEditingController _placeLabelController;
  final TextEditingController _placeAddressController;
  final GoogleMapsPlaces _googleMapsPlaces;
  FavoritePlaceFormWideget(
    this._googleMapsPlaces, {
    Key? key,
    TextEditingController? placeLabelController,
    TextEditingController? placeAddressController,
  })  : _placeAddressController =
            placeAddressController ?? TextEditingController(),
        _placeLabelController = placeLabelController ?? TextEditingController(),
        super(key: key);

  @override
  State<FavoritePlaceFormWideget> createState() =>
      _FavoritePlaceFormWidegetState();
}

class _FavoritePlaceFormWidegetState extends State<FavoritePlaceFormWideget> {
  var _placeSuggestions = <String?>[];

  @override
  void initState() {
    super.initState();
    widget._placeAddressController.addListener(_loadSuggestions);
  }

  void _loadSuggestions() async {
    final response = await widget._googleMapsPlaces
        .autocomplete(widget._placeAddressController.text);
    setState(() {
      _placeSuggestions =
          response.predictions.map((element) => element.description).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: widget._placeLabelController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            labelText: "Label (e.g. Home, Work)",
          ),
        ),
        TextField(
          controller: widget._placeAddressController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            labelText: "Address",
          ),
        ),
        SingleChildScrollView(
          child: Column(
            children: [
              for (String? suggestion in _placeSuggestions)
                if (suggestion != null) Text(suggestion),
            ],
          ),
        ),
      ],
    );
  }
}

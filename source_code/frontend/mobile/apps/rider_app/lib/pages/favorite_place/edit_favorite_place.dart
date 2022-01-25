import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:rider_app/pages/favorite_place/form_widget.dart';

class AddFavoritePlacePage extends StatelessWidget {
  final _googleMapsPlaces = GoogleMapsPlaces();
  final TextEditingController _placeLabelController;
  final TextEditingController _placeAddressController;

  AddFavoritePlacePage(String placeLabel, String placeAddress, {Key? key})
      : _placeAddressController = TextEditingController(text: placeAddress),
        _placeLabelController = TextEditingController(text: placeLabel),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Favorite Place"),
        actions: [
          IconButton(
            onPressed: _deleteFavoritePlace,
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FavoritePlaceFormWideget(
              _googleMapsPlaces,
              placeLabelController: _placeLabelController,
              placeAddressController: _placeAddressController,
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: _updateFavoritePlace,
              child: const Text("UPDATE"),
            ),
          ],
        ),
      ),
    );
  }

  void _updateFavoritePlace() {}

  void _deleteFavoritePlace() {}
}

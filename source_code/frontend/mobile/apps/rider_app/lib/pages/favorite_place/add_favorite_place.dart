import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:rider_app/pages/favorite_place/form_widget.dart';

class AddFavoritePlacePage extends StatelessWidget {
  final _googleMapsPlaces = GoogleMapsPlaces();
  final _placeLabelController = TextEditingController();
  final _placeAddressController = TextEditingController();

  AddFavoritePlacePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Favorite Place"),
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
              onPressed: _addFavoritePlace,
              child: const Text("ADD TO FAVORITES"),
            ),
          ],
        ),
      ),
    );
  }

  void _addFavoritePlace() {}
}

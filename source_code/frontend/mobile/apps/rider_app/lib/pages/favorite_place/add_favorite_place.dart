import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:rider_app/pages/favorite_place/form_widget.dart';
import 'package:shared/shared.dart';

class AddFavoritePlacePage extends StatelessWidget {
  final _googleMapsPlaces = GoogleMapsPlaces();
  final _placeLabelController = TextEditingController();
  final _placeAddressController = TextEditingController();
  final Account _riderAccount;

  AddFavoritePlacePage(this._riderAccount, {Key? key}) : super(key: key);

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
              onPressed: () async {
                await _addFavoritePlace();
                _showConfirmationDialog(context);
              },
              child: const Text("ADD TO FAVORITES"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addFavoritePlace() async {
    final favoritePlaceRepository = FavoritePlaceRepository();
    final accessToken = await _riderAccount.accessToken;

    await favoritePlaceRepository.create(
      {
        "street_address": _placeAddressController.text,
        "rider_id": _riderAccount.id,
        "place_label": _placeLabelController.text
      },
      accessToken!,
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "${_placeLabelController.text} Successfully added to your favorite places.",
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            )
          ],
        );
      },
    );
  }
}

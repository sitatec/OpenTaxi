import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:shared/shared.dart';
import 'form_widget.dart';

class EditFavoritePlacePage extends StatelessWidget {
  final _googleMapsPlaces = GoogleMapsPlaces();
  final TextEditingController _placeLabelController;
  final TextEditingController _placeAddressController;
  final String _accessToken;
  final String _id;
  final _favoritePlaceRepository = FavoritePlaceRepository();
  final _formKey = GlobalKey<FormState>();

  EditFavoritePlacePage(
      String placeLabel, String placeAddress, this._accessToken, this._id,
      {Key? key})
      : _placeAddressController = TextEditingController(text: placeAddress),
        _placeLabelController = TextEditingController(text: placeLabel),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit ${_placeLabelController.text}"),
        actions: [
          IconButton(
            onPressed: () async {
              await _deleteFavoritePlace();
              _showConfirmationDialog(context, updated: false);
            },
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
              _formKey,
              _googleMapsPlaces,
              placeLabelController: _placeLabelController,
              placeAddressController: _placeAddressController,
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () async {
                await _updateFavoritePlace();
                _showConfirmationDialog(context);
              },
              child: const Text("UPDATE"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateFavoritePlace() async {
    if (_formKey.currentState!.validate()) {
      await _favoritePlaceRepository.update(
        _id,
        {
          "street_address": _placeAddressController.text,
          "place_label": _placeLabelController.text
        },
        _accessToken,
      );
    }
  }

  Future<void> _deleteFavoritePlace() async {
    await _favoritePlaceRepository.delete(_id, _accessToken);
  }

  void _showConfirmationDialog(BuildContext context, {bool updated = true}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "${_placeLabelController.text} Successfully ${updated ? 'added to' : 'deleted from'} your favorite places.",
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

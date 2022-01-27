import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:rider_app/configs/secrets.dart';
import 'package:shared/shared.dart';

class PlaceSelectionPage extends StatefulWidget {
  final Account _riderAccount;
  const PlaceSelectionPage(this._riderAccount, {Key? key}) : super(key: key);

  @override
  State<PlaceSelectionPage> createState() => _PlaceSelectionPageState();
}

class _PlaceSelectionPageState extends State<PlaceSelectionPage> {
  String origin = "";
  String destination = "";
  String originTextFieldHint = "Current location";
  bool originTextFieldHasFocus = false;
  bool destinationTextFieldHasFocus = false;
  final List<String> originAutocompletedAddresses = [];
  final List<String> destinationAutocompletedAddresses = [];
  bool isKeyboardVisible = false;
  late StreamSubscription<bool> keyboardSubscription;
  final keyboardVisibilityController = KeyboardVisibilityController();
  final _googlePlacesApi = GoogleMapsPlaces(apiKey: googlePlacesAPIKey);
  Location? autocompleteOrigin, autocompleteLocation;
  final locationManager = LocationManager();
  final stopAddresses = <String>[];
  bool _isLoadingFavoritePlaces = true;
  List<Map<String, String>> _favoritePlaces = [];
  final _favoritePlaceRepository = FavoritePlaceRepository();

  bool get buttonsEnabled {
    for (String address in stopAddresses) {
      if (address.length < 5) {
        return false;
      }
    }
    return origin.length > 5 && destination.length > 5;
  }

  @override
  void initState() {
    super.initState();
    locationManager.initialize().then((_) {
      locationManager.getCurrentCoordinates().then((value) {
        final location = Location(lat: value.latitude, lng: value.longitude);
        autocompleteLocation = location;
        autocompleteOrigin = location;
      });
    });
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      setState(() {
        isKeyboardVisible = visible;
      });
    });
    _fetchFavoritePlaces();
  }

  Future<void> _fetchFavoritePlaces() async {
    final accessToken = await widget._riderAccount.accessToken;
    final response = await _favoritePlaceRepository.get(
      {"rider_id": widget._riderAccount.id},
      accessToken!,
    );
    setState(() {
      _favoritePlaces = List.from(response["data"]);
      _isLoadingFavoritePlaces = false;
    });
  }

  @override
  void dispose() {
    keyboardSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: 50),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Image.asset(
                        "assets/images/pickup.png",
                        width: 23,
                        height: 23,
                      ),
                    ),
                    Expanded(
                      child: Autocomplete<Prediction>(
                        optionsBuilder:
                            (TextEditingValue textEditingValue) async {
                          if (textEditingValue.text.trim().isEmpty) {
                            return const <Prediction>[];
                          }
                          final autocompleteResponse =
                              await _googlePlacesApi.autocomplete(
                            textEditingValue.text,
                            origin: autocompleteOrigin,
                            location: autocompleteLocation,
                          );
                          print(autocompleteResponse.status);
                          print(autocompleteResponse.predictions.length);
                          return autocompleteResponse.predictions;
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return ListView.builder(
                              itemBuilder: (context, index) {
                            final prediction = options.elementAt(index);
                            return ListTile(
                              title: Text(prediction.description ?? ""),
                            );
                          });
                        },
                        displayStringForOption: (prediction) =>
                            prediction.description!,
                        fieldViewBuilder: (
                          context,
                          textEditingController,
                          focusNode,
                          onFieldSubmitted,
                        ) {
                          focusNode.addListener(() {
                            setState(() {
                              originTextFieldHint = focusNode.hasFocus
                                  ? "From"
                                  : "Current location";
                            });
                          });
                          return TextField(
                            controller: textEditingController,
                            onChanged: (value) => origin = value,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              hintText: originTextFieldHint,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(
                                  color: Color(0xFFDADADA),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: SizedBox(
                        width: 26,
                      ),
                    )
                  ],
                ),
                for (int i = 0; i < stopAddresses.length; i++) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(
                          Icons.stop_circle_outlined,
                          color: theme.accentColor,
                        ),
                      ),
                      Expanded(
                        child: Autocomplete<Prediction>(
                          optionsBuilder: (textEditingValue) async {
                            if (textEditingValue.text.trim().isEmpty) {
                              return const <Prediction>[];
                            }
                            final autocompleteResponse =
                                await _googlePlacesApi.autocomplete(
                              textEditingValue.text,
                              origin: autocompleteOrigin,
                              location: autocompleteLocation,
                            );
                            return autocompleteResponse.predictions;
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            return ListView.builder(
                                itemBuilder: (context, index) {
                              final prediction = options.elementAt(index);
                              return ListTile(
                                title: Text(prediction.description ?? ""),
                              );
                            });
                          },
                          displayStringForOption: (prediction) =>
                              prediction.description!,
                          fieldViewBuilder: (
                            context,
                            textEditingController,
                            focusNode,
                            onFieldSubmitted,
                          ) {
                            return TextField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              onChanged: (value) => stopAddresses[i] = value,
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                hintText: "Stop",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFDADADA),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            stopAddresses.removeAt(i);
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.close,
                            size: 26,
                            color: theme.disabledColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(
                        Icons.location_on,
                        color: theme.errorColor,
                      ),
                    ),
                    Expanded(
                      child: Autocomplete<Prediction>(
                        optionsBuilder: (textEditingValue) async {
                          if (textEditingValue.text.trim().isEmpty) {
                            return const <Prediction>[];
                          }
                          final autocompleteResponse =
                              await _googlePlacesApi.autocomplete(
                            textEditingValue.text,
                            origin: autocompleteOrigin,
                            location: autocompleteLocation,
                          );
                          return autocompleteResponse.predictions;
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return ListView.builder(
                              itemBuilder: (context, index) {
                            final prediction = options.elementAt(index);
                            return ListTile(
                              title: Text(prediction.description ?? ""),
                            );
                          });
                        },
                        displayStringForOption: (prediction) =>
                            prediction.description!,
                        fieldViewBuilder: (context, textEditingController,
                            focusNode, onFieldSubmitted) {
                          return TextField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            onChanged: (value) => destination = value,
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              hintText: "To",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(
                                  color: Color(0xFFDADADA),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (stopAddresses.isNotEmpty &&
                            stopAddresses.last.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Please enter the address of the previous stop first."),
                            ),
                          );
                          return;
                        }
                        setState(() {
                          stopAddresses.add("");
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.add,
                          size: 26,
                          color: gray,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          "FAVORITE ADDRESSES",
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      _isLoadingFavoritePlaces
                          ? const Center(
                              child: SizedBox(
                                height: 26,
                                width: 26,
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _favoritePlaces.length,
                              itemBuilder: (context, index) {
                                final place = _favoritePlaces[index];
                                final placeLabel = place["place_label"]!;
                                final lowerCaseLabel =
                                    placeLabel.trim().toLowerCase();
                                return _FavoritePlaceWidget(
                                  icon: lowerCaseLabel == "home"
                                      ? Icon(
                                          Icons.house,
                                          color: theme.disabledColor,
                                        )
                                      : lowerCaseLabel == "work"
                                          ? Icon(
                                              Icons.work,
                                              color: theme.disabledColor,
                                            )
                                          : Icon(
                                              Icons.place,
                                              color: theme.disabledColor,
                                            ),
                                  title: Text(placeLabel, textScaleFactor: 1.2),
                                  address: Text(
                                    place["street_address"]!,
                                    style:
                                        TextStyle(color: theme.disabledColor),
                                  ),
                                );
                              }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: isKeyboardVisible
                ? TextButton(
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "Choose on map",
                          style: TextStyle(fontSize: 17),
                        )
                      ],
                    ),
                    style: TextButton.styleFrom(
                      elevation: 5,
                      backgroundColor: Colors.white,
                      // primary: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                    ),
                  )
                : Container(
                    color: theme.scaffoldBackgroundColor,
                    padding: const EdgeInsets.only(
                      top: 8,
                      left: 16,
                      right: 16,
                      bottom: 24,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: !buttonsEnabled ? null : () {},
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: const Text(
                                "Ride Later",
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
                              backgroundColor: buttonsEnabled
                                  ? theme.primaryColor
                                  : theme.scaffoldBackgroundColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextButton(
                            onPressed: !buttonsEnabled ? null : () {},
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: const Text(
                                "Ride Now",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            style: TextButton.styleFrom(
                              primary: Colors.white,
                              backgroundColor: buttonsEnabled
                                  ? theme.primaryColor
                                  : theme.scaffoldBackgroundColor,
                              elevation: 3,
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

  // bool _shouldShowAutocompletedAddresses() {
  //   if (destinationTextFieldHasFocus) {
  //     return destinationAutocompletedAddresses.isNotEmpty;
  //   } else if (originTextFieldHasFocus) {
  //     return originAutocompletedAddresses.isNotEmpty;
  //   } else {
  //     return false;
  //   }
  // }
}

class _FavoritePlaceWidget extends StatelessWidget {
  final Widget icon;
  final Widget title;
  final Widget address;
  const _FavoritePlaceWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.address,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: lightGray,
        border: Border.all(color: gray.withAlpha(100)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          icon,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: title,
          ),
          Expanded(
            child: Align(alignment: Alignment.centerRight, child: address),
          ),
        ],
      ),
    );
  }
}

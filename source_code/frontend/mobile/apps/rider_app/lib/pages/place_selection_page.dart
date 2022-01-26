import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:rider_app/configs/secrets.dart';
import 'package:shared/shared.dart';

class PlaceSelectionPage extends StatefulWidget {
  const PlaceSelectionPage({Key? key}) : super(key: key);

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 75),
                Autocomplete<Prediction>(
                  optionsBuilder: (TextEditingValue textEditingValue) async {
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
                    return ListView.builder(itemBuilder: (context, index) {
                      final prediction = options.elementAt(index);
                      return ListTile(
                        title: Text(prediction.description ?? ""),
                      );
                    });
                  },
                  fieldViewBuilder: (
                    context,
                    textEditingController,
                    focusNode,
                    onFieldSubmitted,
                  ) {
                    focusNode.addListener(() {
                      setState(() {
                        originTextFieldHint =
                            focusNode.hasFocus ? "From" : "Current location";
                      });
                    });
                    return TextField(
                      controller: textEditingController,
                      onChanged: (value) => origin = value,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        hintText: originTextFieldHint,
                        border: InputBorder.none,
                        prefixIcon: Transform.rotate(
                          angle: 0.7,
                          child: Icon(
                            Icons.navigation,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const Divider(indent: 48, height: 1),
                Autocomplete<Prediction>(
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
                    return ListView.builder(itemBuilder: (context, index) {
                      final prediction = options.elementAt(index);
                      return ListTile(
                        title: Text(prediction.description ?? ""),
                      );
                    });
                  },
                  fieldViewBuilder: (context, textEditingController, focusNode,
                      onFieldSubmitted) {
                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      onChanged: (value) => destination = value,
                      decoration: InputDecoration(
                        hintText: "To",
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.location_on,
                          color: theme.errorColor,
                        ),
                      ),
                    );
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(
                        left: 16,
                        top: 16,
                        bottom: 5,
                      ),
                      child: Text(
                        "FAVORITE ADDRESSES",
                        style: TextStyle(color: gray, fontSize: 13),
                      ),
                    ),
                    _FavoritePlaceWidget(
                      icon: Icon(
                        Icons.house,
                        color: theme.disabledColor,
                        size: 26,
                      ),
                      title: const Text("Home", textScaleFactor: 1.2),
                      address: Text(
                        "Ponomarenko 98",
                        style: TextStyle(color: theme.disabledColor),
                      ),
                    ),
                    const Divider(indent: 56, height: 1),
                    _FavoritePlaceWidget(
                      icon: Icon(
                        Icons.work,
                        color: theme.disabledColor,
                        size: 26,
                      ),
                      title: const Text("Work", textScaleFactor: 1.2),
                      address: Text(
                        "prospekt Dzerzhinskogo, 123lsjflsjflksqljd",
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          color: theme.disabledColor,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          isKeyboardVisible
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
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextButton(
                        onPressed: origin.length < 5 && destination.length < 5
                            ? null
                            : () {},
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
                          backgroundColor:
                              origin.length < 5 && destination.length < 5
                                  ? null
                                  : theme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: origin.length < 5 && destination.length < 5
                            ? null
                            : () {},
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
                          backgroundColor:
                              origin.length < 5 && destination.length < 5
                                  ? null
                                  : theme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:rider_app/cache/recent_trips_addresses_cache.dart';
import 'package:rider_app/configs/secrets.dart';
import 'package:rider_app/entities/address.dart';
import 'package:rider_app/entities/dispatch_request_data.dart';
import 'package:rider_app/pages/choose_place_on_map_page.dart';
import 'package:rider_app/pages/order_page.dart';
import 'package:shared/shared.dart';

class PlaceSelectionPage extends StatefulWidget {
  final Account _riderAccount;
  const PlaceSelectionPage(this._riderAccount, {Key? key}) : super(key: key);

  @override
  State<PlaceSelectionPage> createState() => _PlaceSelectionPageState();
}

// TODO refactor
class _PlaceSelectionPageState extends State<PlaceSelectionPage> {
  Address origin = Address(streetAddress: "");
  Address destination = Address(streetAddress: "");
  String originTextFieldHint = "Current location";
  bool originTextFieldHasFocus = false;
  bool destinationTextFieldHasFocus = false;
  bool isKeyboardVisible = false;
  late StreamSubscription<bool> keyboardSubscription;
  final keyboardVisibilityController = KeyboardVisibilityController();
  final _googlePlacesApi = GoogleMapsPlaces(apiKey: googlePlacesAPIKey);
  Location? autocompleteOrigin, autocompleteLocation;
  final locationManager = LocationManager();
  final stopAddresses = <Address>[];
  bool _isLoadingFavoritePlaces = true;
  bool _isLoadingRecentPlaces = true;
  List<Map<String, String>> _favoritePlaces = [];
  List<Map<String, dynamic>> _recentPlaces = [];
  final _favoritePlaceRepository = FavoritePlaceRepository();
  final _recentPlacesCache = RecentTripsAddressesCache();

  bool get buttonsEnabled {
    for (Address address in stopAddresses) {
      if (address.streetAddress.trim().isEmpty) {
        return false;
      }
    }
    return origin.streetAddress.trim().isNotEmpty &&
        destination.streetAddress.trim().isNotEmpty;
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
    _fetchRecentPlaces();
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

  Future<void> _fetchRecentPlaces() async {
    await _recentPlacesCache.initCacheStore();
    _recentPlaces = await _recentPlacesCache.get();
    setState(() {
      _isLoadingRecentPlaces = false;
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
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Select Locations",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: theme.primaryColor,
            ),
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
          foregroundColor: theme.primaryColor,
          centerTitle: true,
          toolbarHeight: 50,
          elevation: 3,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(height: 24),
                  Row(
                    key: const ValueKey("origin_address_field"),
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
                              language: "en",
                            );
                            return autocompleteResponse.predictions;
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4,
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxHeight:
                                        MediaQuery.of(context).size.height *
                                            0.6,
                                  ),
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  child: ListView.separated(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (context, index) {
                                      final prediction =
                                          options.elementAt(index);
                                      return InkWell(
                                        onTap: () {
                                          onSelected(prediction);
                                          setState(() {
                                            origin.streetAddress =
                                                prediction.description!;
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 16),
                                          child: Text(
                                            prediction.description ?? "error",
                                            style:
                                                const TextStyle(fontSize: 15),
                                          ),
                                        ),
                                      );
                                    },
                                    separatorBuilder:
                                        (BuildContext context, int index) =>
                                            const Divider(
                                      thickness: 1,
                                      height: 0,
                                    ),
                                  ),
                                ),
                              ),
                            );
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
                              onChanged: (value) =>
                                  origin.streetAddress = value,
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
                      key: ValueKey(stopAddresses[i].createdAt),
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
                                language: "en",
                              );
                              return autocompleteResponse.predictions;
                            },
                            optionsViewBuilder: (context, onSelected, options) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  elevation: 4,
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxHeight:
                                          MediaQuery.of(context).size.height *
                                              0.6,
                                    ),
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    child: ListView.separated(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: options.length,
                                      itemBuilder: (context, index) {
                                        final prediction =
                                            options.elementAt(index);
                                        return InkWell(
                                          onTap: () {
                                            onSelected(prediction);
                                            setState(() {
                                              stopAddresses[i].streetAddress =
                                                  prediction.description!;
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 16),
                                            child: Text(
                                              prediction.description ?? "error",
                                              style:
                                                  const TextStyle(fontSize: 15),
                                            ),
                                          ),
                                        );
                                      },
                                      separatorBuilder:
                                          (BuildContext context, int index) =>
                                              const Divider(
                                        thickness: 1,
                                        height: 0,
                                      ),
                                    ),
                                  ),
                                ),
                              );
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
                                onChanged: (value) =>
                                    stopAddresses[i].streetAddress = value,
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
                    key: const ValueKey("destination_address_field"),
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
                              language: "en",
                            );
                            return autocompleteResponse.predictions;
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4,
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxHeight:
                                        MediaQuery.of(context).size.height *
                                            0.6,
                                  ),
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  child: ListView.separated(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (context, index) {
                                      final prediction =
                                          options.elementAt(index);
                                      return InkWell(
                                        onTap: () {
                                          onSelected(prediction);
                                          setState(() {
                                            destination.streetAddress =
                                                prediction.description!;
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 16),
                                          child: Text(
                                            prediction.description ??
                                                "Load Error",
                                            style:
                                                const TextStyle(fontSize: 15),
                                          ),
                                        ),
                                      );
                                    },
                                    separatorBuilder:
                                        (BuildContext context, int index) =>
                                            const Divider(
                                      thickness: 1,
                                      height: 0,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          displayStringForOption: (prediction) =>
                              prediction.description!,
                          fieldViewBuilder: (context, textEditingController,
                              focusNode, onFieldSubmitted) {
                            return TextField(
                              autofocus: true,
                              controller: textEditingController,
                              focusNode: focusNode,
                              onChanged: (value) =>
                                  destination.streetAddress = value,
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
                              stopAddresses.last.streetAddress.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Please enter the address of the previous stop first."),
                              ),
                            );
                            return;
                          }
                          setState(() {
                            stopAddresses.add(Address(streetAddress: ""));
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
                  const Divider(thickness: 1),
                  Container(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.7),
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 40,
                            child: TabBar(
                                padding: EdgeInsets.zero,
                                indicatorColor: theme.primaryColor,
                                labelColor: theme.primaryColor,
                                unselectedLabelColor: gray,
                                labelStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                                tabs: const [
                                  Tab(text: "Favourite Addresses"),
                                  Tab(text: "Recent Addresses")
                                ]),
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child:
                                      // Column(
                                      //   crossAxisAlignment: CrossAxisAlignment.start,
                                      //   children: [
                                      // const Padding(
                                      //   padding: EdgeInsets.symmetric(vertical: 8),
                                      //   child: Text(
                                      //     "Favourite Addresses",
                                      //     style: TextStyle(fontSize: 13),
                                      //   ),
                                      // ),
                                      _isLoadingFavoritePlaces
                                          ? const Center(
                                              child: SizedBox(
                                                height: 26,
                                                width: 26,
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            )
                                          : _favoritePlaces.isEmpty
                                              ? const Center(
                                                  child: Text(
                                                    "You don't have Favourite Addresses yet.",
                                                  ),
                                                )
                                              : ListView.builder(
                                                  itemCount:
                                                      _favoritePlaces.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final place =
                                                        _favoritePlaces[index];
                                                    final placeLabel =
                                                        place["place_label"]!;
                                                    final lowerCaseLabel =
                                                        placeLabel
                                                            .trim()
                                                            .toLowerCase();
                                                    return _FavoritePlaceWidget(
                                                      icon: lowerCaseLabel ==
                                                              "home"
                                                          ? Icon(
                                                              Icons.house,
                                                              color: theme
                                                                  .disabledColor,
                                                            )
                                                          : lowerCaseLabel ==
                                                                  "work"
                                                              ? Icon(
                                                                  Icons.work,
                                                                  color: theme
                                                                      .disabledColor,
                                                                )
                                                              : Icon(
                                                                  Icons
                                                                      .star_rate_rounded,
                                                                  color: theme
                                                                      .disabledColor,
                                                                ),
                                                      title: Text(placeLabel,
                                                          textScaleFactor: 1.2),
                                                      address: Text(
                                                        place[
                                                            "street_address"]!,
                                                        style: TextStyle(
                                                          color: theme
                                                              .disabledColor,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                  //   ],
                                  // ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: _isLoadingRecentPlaces
                                      ? const Center(
                                          child: SizedBox(
                                            height: 26,
                                            width: 26,
                                            child: CircularProgressIndicator(),
                                          ),
                                        )
                                      : _recentPlaces.isEmpty
                                          ? const Center(
                                              child: Text(
                                                "You don't have Recent Addresses yet.",
                                              ),
                                            )
                                          : ListView.builder(
                                              itemCount: _recentPlaces.length,
                                              itemBuilder: (context, index) {
                                                final place =
                                                    _recentPlaces[index];
                                                final streetAddress =
                                                    place["street_address"]!;
                                                return ListTile(
                                                  title: Text(streetAddress),
                                                );
                                              },
                                            ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: isKeyboardVisible
                  ? TextButton(
                      onPressed: () async {
                        final result = await Navigator.of(context).push<String>(
                          MaterialPageRoute(
                            builder: (_) => const ChoosePlaceOnMapPage(),
                          ),
                        );
                        if (result != null) {
                          // TODO
                        }
                      },
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
                      child: Column(
                        children: [
                          TextButton(
                            onPressed: !buttonsEnabled
                                ? null
                                : () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) {
                                          return OrderPage(
                                            DispatchRequestData(
                                              origin,
                                              destination,
                                              stopAddresses,
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
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
                                  : Colors.white,
                              elevation: buttonsEnabled ? 0 : 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: !buttonsEnabled
                                ? null
                                : _showTripDateAndTimePickers,
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
                              primary: buttonsEnabled
                                  ? theme.primaryColor
                                  : theme.scaffoldBackgroundColor,
                              backgroundColor: Colors.white,
                              elevation: buttonsEnabled ? 0 : 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: buttonsEnabled
                                    ? BorderSide(
                                        color: theme.primaryColor,
                                        width: 1.5,
                                      )
                                    : BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTripDateAndTimePickers() async {
    // TODO refactor
    final todaysDate = DateTime.now();
    final selectedDate = await showDatePicker(
      helpText: "SELECT TRIP DATE",
      context: context,
      initialDate: todaysDate,
      firstDate: todaysDate,
      lastDate: todaysDate.add(const Duration(days: 30)),
      builder: (context, picker) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: ColorScheme.light(primary: theme.primaryColor),
            dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          child: picker!,
        );
      },
    );
    final selectedDateIsToday =
        todaysDate.difference(selectedDate!).inDays == 0;
    final selectedTime = await showTimePicker(
      helpText: "SELECT TRIP TIME",
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, picker) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: ColorScheme.light(primary: theme.primaryColor),
            dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          child: picker!,
        );
      },
    );
    final selectedDateAndTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime!.hour,
      selectedTime.minute,
    );
    // TODO navigate to the next screen
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

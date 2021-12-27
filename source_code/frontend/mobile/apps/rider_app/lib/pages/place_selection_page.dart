import 'dart:math';

import 'package:flutter/material.dart';
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
                Container(height: 75, color: lightGray),
                Focus(
                  onFocusChange: (hasFocus) => setState(() {
                    originTextFieldHasFocus = hasFocus;
                    originTextFieldHint =
                        hasFocus ? "From" : "Current location";
                  }),
                  child: TextField(
                    onChanged: (value) => origin = value,
                    decoration: InputDecoration(
                      hintText: originTextFieldHint,
                      border: InputBorder.none,
                      prefixIcon: Transform.rotate(
                        angle: 0.7,
                        child: IconButton(
                          icon: Icon(
                            Icons.navigation,
                            color: theme.primaryColor,
                          ),
                          onPressed: null,
                        ),
                      ),
                    ),
                  ),
                ),
                const Divider(indent: 48, height: 1),
                Focus(
                  onFocusChange: (hasFocus) => setState(() {
                    destinationTextFieldHasFocus = hasFocus;
                  }),
                  child: TextField(
                    onChanged: (value) => destination = value,
                    decoration: InputDecoration(
                      hintText: "To",
                      border: InputBorder.none,
                      prefixIcon: IconButton(
                        icon: Icon(
                          Icons.location_on,
                          color: theme.errorColor,
                        ),
                        onPressed: null,
                      ),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  width: double.infinity,
                  color: lightGray,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text("+ Add stop"),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  ),
                ),
                if (!_shouldShowAutocompletedAddresses())
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                          left: 16,
                          top: 16,
                          bottom: 5,
                        ),
                        width: double.infinity,
                        color: lightGray,
                        child: const Text(
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
          TextButton(
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
        ],
      ),
    );
  }

  bool _shouldShowAutocompletedAddresses() {
    if (destinationTextFieldHasFocus) {
      return destinationAutocompletedAddresses.isNotEmpty;
    } else if (originTextFieldHasFocus) {
      return originAutocompletedAddresses.isNotEmpty;
    } else {
      return false;
    }
  }
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String selectedCar = _CarInfo.economy.type;
  bool isSearchingForDriver = false;

  @override
  Widget build(BuildContext context) {
    final Completer<GoogleMapController> _mapController = Completer();
    final theme = Theme.of(context);
    final iconsBackgroundColor = theme.disabledColor.withAlpha(100);
    return Scaffold(
      body: Stack(
        children: [
          MapWidget(controller: _mapController),
          SafeArea(
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
              ),
              child: const Icon(
                Icons.menu,
                color: gray,
                size: 28,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: isSearchingForDriver
                  ? Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      direction: Axis.vertical,
                      children: [
                        const SizedBox(height: 30),
                        CircularProgressIndicator(
                          color: theme.primaryColor.withAlpha(200),
                        ),
                        Container(
                          padding: const EdgeInsets.all(20),
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            "Searching for driver...",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Wrap(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            child: SvgPicture.asset(
                                "assets/images/pickup_icon.svg",
                                package: "shared"),
                            backgroundColor: iconsBackgroundColor,
                          ),
                          title: Text(
                            "PICK UP",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                              color: theme.disabledColor,
                            ),
                          ),
                          subtitle: Text("bookingRequestData.pickUpAddress"),
                        ),
                        ListTile(
                          leading: CircleAvatar(
                            child: SvgPicture.asset(
                                "assets/images/dropoff_icon.svg",
                                package: "shared"),
                            backgroundColor: iconsBackgroundColor,
                          ),
                          title: Text(
                            "DROP OFF",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                              color: theme.disabledColor,
                            ),
                          ),
                          subtitle: Text("bookingRequestData.dropOfAddress"),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              "+ Add stop",
                              style: TextStyle(fontSize: 16),
                            ),
                            style:
                                TextButton.styleFrom(padding: EdgeInsets.zero),
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              bottom: 20,
                              top: 8,
                            ),
                            child: Row(
                              children: [
                                _CarInfoWidget(
                                  _CarInfo.economy,
                                  isSelected:
                                      selectedCar == _CarInfo.economy.type,
                                  onClicked: () => setState(
                                    () => selectedCar = _CarInfo.economy.type,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _CarInfoWidget(
                                  _CarInfo.minivan,
                                  isSelected:
                                      selectedCar == _CarInfo.minivan.type,
                                  onClicked: () => setState(
                                    () => selectedCar = _CarInfo.minivan.type,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _CarInfoWidget(
                                  _CarInfo.comfort,
                                  isSelected:
                                      selectedCar == _CarInfo.comfort.type,
                                  onClicked: () => setState(
                                    () => selectedCar = _CarInfo.comfort.type,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              IconButton(
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  bottom: 8,
                                  left: 8,
                                  right: 24,
                                ),
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              Expanded(
                                child: RoundedCornerButton(
                                  onPressed: () {},
                                  child: const Text(
                                    "Order",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            ],
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

class _CarInfo {
  final String type;
  final String price;
  final String imageUrl;

  const _CarInfo(
      {required this.type, required this.price, required this.imageUrl});

  static const economy = _CarInfo(
    type: "Economy",
    price: "\$4.50",
    imageUrl: "assets/images/economy.svg",
  );

  static const minivan = _CarInfo(
    type: "Minivan",
    price: "\$6.32",
    imageUrl: "assets/images/minivan.svg",
  );

  static const comfort = _CarInfo(
    type: "Comfort",
    price: "\$10.99",
    imageUrl: "assets/images/comfort.svg",
  );
}

class _CarInfoWidget extends StatelessWidget {
  final _CarInfo _carInfo;
  final bool isSelected;
  final VoidCallback? onClicked;
  const _CarInfoWidget(this._carInfo,
      {this.isSelected = false, this.onClicked, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClicked,
      child: Card(
        elevation: isSelected ? 8 : 0,
        shadowColor: lightGray,
        color: isSelected ? Colors.white : lightGray.withAlpha(150),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: lightGray),
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          width: 116,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(_carInfo.imageUrl),
              Text(_carInfo.type),
              Text(
                _carInfo.price,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              )
            ],
          ),
        ),
      ),
    );
  }
}

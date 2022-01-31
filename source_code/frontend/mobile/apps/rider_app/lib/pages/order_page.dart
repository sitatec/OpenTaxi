import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rider_app/entities/dispatch_request_data.dart';
import 'package:rider_app/pages/trip_page.dart';
import 'package:rider_app/utils/widget_utils.dart';
import 'package:shared/shared.dart';

class OrderPage extends StatefulWidget {
  final DispatchRequestData _bookingData;
  const OrderPage(this._bookingData, {Key? key}) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String selectedCar = _CarInfo.economy.type;
  String notificationMessage = "";
  late final dispatchRequestData = widget._bookingData;
  final dispatcher = Dispatcher();
  StreamSubscription? dispatcherDataStreamSub;
  Map<String, dynamic>? currentDriverCandidate;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    dispatcherDataStreamSub = dispatcher.dataStream.listen((data) {
      switch (data.key) {
        case FramType.BOOKING_ID:
          // TODO
          break;
        case FramType.ACCEPT_BOOKING:
          setState(() {
            notificationMessage =
                "${currentDriverCandidate!['nam']} has accepted the request.\n Wait a moment please...";
          });
          break;
        case FramType.TRIP_ROOM:
          final tripRoom = TripRoom(data.value);
          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            return TripPage(
              tripRoom,
              dispatchRequestData.originAddress,
              dispatchRequestData.destinationAddress.streetAddress,
            );
          }));
          break;
        case FramType.REFUSE_BOOKING:
          setState(() {
            if (currentDriverCandidate != null &&
                currentDriverCandidate!["idx"].toString() ==
                    data.value.toString()) {
              notificationMessage =
                  "${currentDriverCandidate!['nam']} has declined the request, sending request to the next available driver...";
            } else {
              notificationMessage =
                  "The ${_numberToOrdinal(data.value)} driver has declined the request, sending request to the next available driver...";
            }
          });
          break;
        case FramType.NO_MORE_DRIVER_AVAILABLE:
          setState(() {
            notificationMessage = "Oops! No more available drivers.";
          });
          break;
        case FramType.PAIR_DISCONNECTED:
          final driverName = currentDriverCandidate?['nam'] ?? "The Driver";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor:
                  Theme.of(context).errorColor.withBlue(80).withGreen(80),
              duration: const Duration(seconds: 5),
              content: Text(
                "$driverName got disconnected.",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
          break;
        case FramType.BOOKING_SENT:
          currentDriverCandidate = jsonDecode(data.value);
          setState(() {
            notificationMessage =
                """A ride Request has been sent to ${currentDriverCandidate!['nam']}.
Estimations:
Distance to the driver's location: ${currentDriverCandidate!['dis']}
Duration of the trip from the driver's location to yours: ${currentDriverCandidate!['dur']}""";
          });
          break;
        default:
          debugPrint(
            "Invalid data fram type received from the dispatcher server : " +
                data.key.toString(),
          );
      }
    });
  }

  String _numberToOrdinal(String number) {
    switch (number) {
      case "1":
        return "first";
      case "2":
        return "second";
      case "3":
        return "third";
      case "4":
        return "fourth";
      default:
        return number; // support only the first 4 number yet.
    }
  }

  @override
  void dispose() {
    dispatcherDataStreamSub?.cancel();
    super.dispose();
  }

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
              child: notificationMessage.isNotEmpty
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
                            notificationMessage,
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
                              package: "shared",
                            ),
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
                          subtitle: Text(
                            widget._bookingData.originAddress.streetAddress,
                          ),
                        ),
                        ListTile(
                          leading: CircleAvatar(
                            child: Image.asset(
                              "assets/images/dropoff_icon.png",
                              package: "shared",
                              width: 20,
                              height: 20,
                            ),
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
                          subtitle: Text(
                            widget
                                ._bookingData.destinationAddress.streetAddress,
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
                                  onPressed: () async {
                                    try {
                                      await dispatcher.connect(
                                          onServerDisconnect: (serverMessage) {
                                        if (serverMessage?.isNotEmpty ??
                                            false) {
                                          showInfoDialog(
                                            "Server Disconnected",
                                            serverMessage!,
                                            context,
                                          );
                                        }
                                      });
                                      dispatcher.sendData(
                                        MapEntry(
                                          FramType.DISPATCH_REQUEST,
                                          await dispatchRequestData.data,
                                        ),
                                      );
                                      setState(() {
                                        notificationMessage =
                                            "Searching for driver...";
                                      });
                                    } catch (e) {
                                      setState(() {
                                        notificationMessage =
                                            "Oops! An error occurred.";
                                      });
                                      // TODO show proper error message to user.
                                      debugPrint(e.toString());
                                    }
                                  },
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

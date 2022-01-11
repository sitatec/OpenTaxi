import 'dart:async';
import 'dart:convert';

import 'package:driver_app/utils/data_converters.dart';
import 'package:driver_app/widgets/countdown_slider.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:app_settings/app_settings.dart';

import 'entities/driver.dart';
import 'widgets/custom_switch.dart';

// TODO refactor
class HomePage extends StatefulWidget {
  final Dispatcher _dispatcher;
  final Driver _driver;
  final LocationManager _locationManager;
  final ReviewRepository _reveiwRepository;
  HomePage(
    this._driver,
    this._dispatcher,
    this._locationManager, {
    ReviewRepository? reviewRepository,
    Key? key,
  })  : _reveiwRepository = reviewRepository ?? ReviewRepository(),
        super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isDriverOnline = false;
  bool _isOnlineStatusChanging = false;
  bool _locationServiceInitialized = false;
  bool _bookingAccepted = false;
  bool _inTrip = false;
  Widget? _notification = null; //_StatusNotification.offline;
  final Completer<GoogleMapController> _mapController = Completer();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  StreamSubscription? _onlineStatusSubscription;
  StreamSubscription? _dataStreamSubscription;
  StreamSubscription? _locationStreamSubscription;
  late Dispatcher _dispatcher;
  BitmapDescriptor? _myLocationIcon;
  BitmapDescriptor? _whiteCarIcon;
  BitmapDescriptor? _rideRequestIcon;
  BitmapDescriptor? _pickupIcon;
  List<VoidCallback> _onStateResetedListenners = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool _hasUnRedNotification = false;
  TripRoom? _tripRoom;

  @override
  void initState() {
    super.initState();
    _assetToBitmapDescriptor("assets/images/my_location.png")
        .then((value) => _myLocationIcon = value);
    _assetToBitmapDescriptor("assets/images/car_white.png")
        .then((value) => _whiteCarIcon = value);
    _assetToBitmapDescriptor("assets/images/ride_request.png")
        .then((value) => _rideRequestIcon = value);
    _assetToBitmapDescriptor("assets/images/pickup_icon.png")
        .then((value) => _pickupIcon = value);

    _dispatcher = widget._dispatcher;
    _onlineStatusSubscription = _dispatcher.isConnected.listen((_isConnected) {
      if (_isConnected) {
        _dataStreamSubscription =
            _dispatcher.dataStream?.listen(_onDataRecieved);
        widget._locationManager
            .getCurrentCoordinates()
            .then(_sendDriverInitialDataToDispatcher);
        _locationStreamSubscription = widget._locationManager
            .getCoordinatesStream()
            .listen(_sendDriverLocationToDispatcher);
      } else {
        _locationStreamSubscription?.cancel();
      }
      setState(() {
        _isDriverOnline = _isConnected;
        _notification = _isConnected
            ? null
            : _buildStatusNotification(_StatusNotification.offline);
      });
    });
  }

  @override
  void dispose() {
    _onlineStatusSubscription?.cancel();
    _dataStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      key: _scaffoldKey,
      drawer: NavigationDrawer(widget._driver),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          color: theme.scaffoldBackgroundColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    idToProfilePicture(widget._driver.account.id),
                  ),
                  radius: 24,
                ),
              ),
              FlutterSwitch(
                value: _isDriverOnline || _inTrip,
                onToggle: _toggleDriverOnlineStatus,
                activeText: const Text(
                  "Online",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                inactiveText: const Text(
                  "Offline",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                inactiveIcon:
                    SvgPicture.asset("assets/images/offline_icon.svg"),
                activeIcon: SvgPicture.asset("assets/images/online_icon.svg"),
                valueFontSize: 18,
                inactiveColor: theme.disabledColor.withAlpha(200),
                activeColor: theme.accentColor,
                showOnOff: true,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: lightGray, width: 2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Image.asset(
                    "assets/images/${_hasUnRedNotification ? 'notification_received' : 'notification'}.png",
                    package: "shared",
                    width: 19,
                  ),
                  onPressed: () {
                    // Payment().updateTokenPaymentCard("token", context);
                    // _drowDirectionToDropOff(
                    //     r"gv_dAd`ejAY`CE?oFi@qAImDG}@Iu@?wCJKkCQ{DIgDCuECmEEoLMiQK_\EaBQ_CaBuNwA}LYiCUcBKWMUg@a@YKk@GkBO{@Uk@_@U[c@iA{EuNs@wBaAiESw@UqAQ{Ac@mLQmDCm@CIEIGGGCIAOJAHAD[b@ENaHvGsElEwAxAaAfAS\_@?{@NiE~@aB\w@Hk@Ny@XeAf@}Af@{Bv@wErBeHvCQ@GJSL{Aj@aBl@yATMHCH?VFRj@z@");
                    // _showQrCodeDialog("slfs");
                    // _showReviewNotification(
                    //   MapEntry(4.5, "Sita Bérété left a 4.5 star Review"),
                    // );
                    // _showRatingBottomSheet(
                    //   _RiderData(
                    //     imageURL: idToProfilePicture(""),
                    //     rating: "4.5",
                    //     paymentMethod: "By Cash",
                    //     name: "Sita Bérété",
                    //   ),
                    // );
                    _showBottomSheetActions(
                      _RiderData(
                        imageURL: idToProfilePicture(""),
                        rating: "4.5",
                        paymentMethod: "CASH",
                        name: "Sita Berete",
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          MapWidget(
            controller: _mapController,
            markers: _markers,
            polylines: _polylines,
          ),
          Column(
            children: [
              if (_notification != null) _notification!,
              if (_bookingAccepted)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: InkWell(
                      child: Container(
                        child: Icon(
                          Icons.close,
                          color: theme.scaffoldBackgroundColor,
                        ),
                        decoration: BoxDecoration(
                          color: theme.errorColor.withAlpha(190),
                          shape: BoxShape.circle,
                        ),
                      ),
                      onTap: _showTripCancellationDialog,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 46,
        child: FloatingActionButton(
          backgroundColor: theme.scaffoldBackgroundColor,
          onPressed: _showMyLocation,
          child: const Icon(Icons.my_location, color: Colors.black87),
        ),
      ),
    );
  }

  Future<BitmapDescriptor> _assetToBitmapDescriptor(String assetName) =>
      BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(60, 60)),
        assetName,
        package: "shared",
      );

  Widget _buildStatusNotification(_StatusNotification _statusNotification) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: _statusNotification.backgroundColor,
      child: Row(
        children: [
          _statusNotification.imageURL.isNotEmpty
              ? SvgPicture.asset(_statusNotification.imageURL)
              : const CircularProgressIndicator(color: Colors.white),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _statusNotification.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                _statusNotification.subtitle,
                style: TextStyle(
                  color: Colors.white.withAlpha(200),
                  fontSize: 12,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _onDataRecieved(MapEntry<FramType, dynamic> dataJson) async {
    // TODO refactor
    switch (dataJson.key) {
      case FramType.BOOKING_REQUEST:
        final data = jsonDecode(dataJson.value) as JsonObject;
        final accessToken = await widget._driver.account.accessToken!;
        var riderRatingData = (await widget._reveiwRepository.getRating(
          {"recipient_id": data["id"]},
          accessToken,
        ));
        riderRatingData = (riderRatingData as JsonObject)["data"];
        final riderRating = int.parse(riderRatingData["count"]) > 0
            ? riderRatingData["avg"]
            : "NEW USER";
        final riderData = _RiderData(
          imageURL: idToProfilePicture(data["id"]),
          rating: riderRating,
          paymentMethod: data["pym"],
          name: data["nam"],
        );
        final bookingRequestData = _BookingRequestData(
          id: data["id"],
          riderData: riderData,
          pickUpAddress: data["pic"],
          dropOfAddress: data["drp"],
          distance: data["dis"],
          duration: data["dur"],
          stops: List.from(data["stp"], growable: false),
        );
        _showBookingRequest(bookingRequestData);
        break;
      case FramType.CANCEL_BOOKING:
        await _showInfoDialog(
          "Booking Cancelled",
          "The rider has cancelled the booking",
        );
        _onStateResetedListenners.forEach(_callFunction);
        break;
      case FramType.INVALID_DISPATCH_ID:
        await _showInfoDialog(
          "Error",
          "Something bad happend.",
        );
        break;
      case FramType.PAIR_DISCONNECTED:
        await _showInfoDialog(
          "Rider Disconnected",
          "Rider connection lost.",
        );
        _onStateResetedListenners.forEach(_callFunction);
        break;
      case FramType.BOOKING_REQUEST_TIMEOUT:
        await _showInfoDialog(
          "Trip request timout",
          "You haven't reacted the booking request for one minute.",
        );
        _onStateResetedListenners.forEach(_callFunction);
        break;
      case FramType.TRIP_ROOM:
        _tripRoom = TripRoom(
          dataJson.value,
          locationSourceStream: widget._locationManager.getCoordinatesStream(
            distanceFilterInMeter: 0,
            timeInterval: 1000,
          ),
        );
        final tripRoom = _tripRoom!; // To avoid null check all the time.
        tripRoom.join();
        tripRoom.tripEventsStream.listen((event) async {
          switch (event) {
            case TripEvent.joined:
              _locationStreamSubscription?.cancel();
              _locationStreamSubscription =
                  tripRoom.locationStream.listen(_updateDriverLocation);
              // Reduce the dispatcher workload while the driver is in trip.
              _dispatcher.disconnect();
              _showInfoDialog("Trip Successfully Initialized", "");
              break;
            case TripEvent.joinFailed:
              _showInfoDialog(
                  "Error", "An error happend while initializing the trip.",
                  actionButton: TextButton(
                    onPressed: () => tripRoom.join(),
                    child: const Text("RETRY"),
                  ));
              break;
            case TripEvent.viewerJoined:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    "A user joined the trip.",
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Theme.of(context).accentColor,
                ),
              );
              break;
            case TripEvent.cantJoinTwice:
              _showSimpleSnakbar("Trip already joinned.");
              break;
            default:
          }
        });
        // TODO: Handle this case.
        break;
      default:
    }
  }

  void _callFunction(VoidCallback function) => function();

  Future<void> _showInfoDialog(String title, String message,
      {String? dismissButtonText, Widget? actionButton}) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: message.isEmpty ? null : Text(message),
            actions: [
              if (actionButton != null) actionButton,
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(dismissButtonText ?? "OK"),
              )
            ],
          );
        });
  }

  Future<void> _sendDriverInitialDataToDispatcher(Coordinates location) async {
    final data = await driverToDispatcherData(widget._driver);
    data["loc"] = locationToJson(location);
    _dispatcher.sendData(MapEntry(FramType.ADD_DRIVER_DATA, data));
  }

  void _sendDriverLocationToDispatcher(Coordinates location) {
    _dispatcher.sendData(MapEntry(
      FramType.UPDATE_DRIVER_DATA,
      "${location.latitude},${location.longitude}",
    ));
  }

  Future<void> _toggleDriverOnlineStatus(bool mustConnect) async {
    if (_isOnlineStatusChanging) return;
    setState(() {
      _isOnlineStatusChanging = true;
      _notification = _buildStatusNotification(
        mustConnect
            ? _StatusNotification.connecting
            : _StatusNotification.disconnecting,
      );
    });
    if (mustConnect) {
      if (!(await _initializeLocationServices())) {
        return setState(() {
          _isOnlineStatusChanging = false;
          _notification = _buildStatusNotification(_StatusNotification.offline);
        });
      }
      await widget._dispatcher.connect();
    } else {
      await widget._dispatcher.disconnect();
    }
    setState(() => _isOnlineStatusChanging = false);
  }

  void _showMyLocation() async {
    if (!await _initializeLocationServices()) {
      _showSimpleSnakbar("Location Permission not allowed");
      return;
    }
    final currentCordinates =
        await widget._locationManager.getCurrentCoordinates();
    if (_isDriverOnline) {
      _updateDriverLocation(currentCordinates);
    } else {
      _updateDriverLocation(currentCordinates, _myLocationIcon);
    }
    print("\n\n${currentCordinates.orientation}\n\n");
  }

  void _showRideRequestMarker(Coordinates coordinates) {
    _markers.removeWhere((marker) => marker.markerId.value == "pickup");
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId("pickup"),
          position: LatLng(coordinates.latitude, coordinates.longitude),
          icon: _rideRequestIcon ?? BitmapDescriptor.defaultMarker,
        ),
      );
    });
  }

  void _showPickupLocationMarker(Coordinates coordinates) {
    _markers.removeWhere((marker) => marker.markerId.value == "pickup");
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId("pickup"),
          position: LatLng(coordinates.latitude, coordinates.longitude),
          icon: _pickupIcon ?? BitmapDescriptor.defaultMarker,
        ),
      );
    });
  }

  void _updateDriverLocation(
    Coordinates newCoordinates, [
    BitmapDescriptor? icon,
  ]) async {
    icon ??= _whiteCarIcon;
    final latlng = LatLng(newCoordinates.latitude, newCoordinates.longitude);
    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == "driver");
      _markers.add(
        Marker(
          markerId: const MarkerId("driver"),
          position: latlng,
          icon: icon ?? BitmapDescriptor.defaultMarker,
          rotation: newCoordinates.orientation,
        ),
      );
    });
    (await _mapController.future).animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: latlng, zoom: 14)),
    );
  }

  void _showSimpleSnakbar(String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(SnackBar(content: Text(message)));
  }

  void _drowDirectionToPickUp(String encodedPolyline) {
    setState(() {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId("to_picup"),
          points: decodePolyline(encodedPolyline),
          width: 4,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      );
    });
  }

  void _drowDirectionToDropOff(String encodedPolyline) {
    setState(() {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId("to_picup"),
          points: decodePolyline(encodedPolyline),
          width: 4,
          color: const Color(0xFFE50027),
        ),
      );
    });
  }

  Future<bool> _initializeLocationServices() async {
    try {
      if (_locationServiceInitialized) {
        return true;
      } else {
        if (!(await _askLocationPermission())) {
          return false;
        }
        await widget._locationManager.initialize(requireBackground: true);
        _locationServiceInitialized = true;
        return true;
      }
      // TODO catche exceptions from dispatcher connect() and disconnect().
    } on LocationManagerException catch (e) {
      setState(() => _notification = null);
      if (e.exceptionType == LocationManagerExceptionType.permissionDenied) {
        // Do nothing, when the driver try going online the permission dialog will be shown again
      }
      if (e.exceptionType ==
          LocationManagerExceptionType.insufficientPermission) {
        //TODO handle
      }
      if (e.exceptionType ==
          LocationManagerExceptionType.permissionPermanentlyDenied) {
        await AppSettings.openLocationSettings();
        // TODO use the appropriated seettings page.
      } else {
        rethrow;
      }
      return false;
    }
  }

  Future<bool> _askLocationPermission() async {
    return await widget._locationManager.backgroundEnabled &&
            await widget._locationManager.hasPermission ||
        (await showDialog<bool>(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: LocationPermissionPage(
                    onEnableButtonClicked: () =>
                        Navigator.of(context).pop(true),
                  ),
                );
              },
            ) ??
            false);
  }

  Future<void> _showTripCancellationDialog() {
    final theme = Theme.of(context);
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Are you sure you want to Cancel?",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            "You will be charged an additional 200 cancellation",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SmallRoundedCornerButton(
              "YES",
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
              backgroundColor: theme.errorColor.withAlpha(190),
              onPressed: () async {
                // TODO notify admin by email.
                await _tripRoom?.sendCustomEvent("driver_cancel");
                await _tripRoom?.leave("driver");
                _onStateResetedListenners.forEach(_callFunction);
              },
            ),
            const SizedBox(width: 16),
            SmallRoundedCornerButton(
              "GO BACK",
              backgroundColor: theme.disabledColor,
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  void _showBookingRequest(_BookingRequestData bookingRequestData) {
    final theme = Theme.of(context);
    final iconsBackgroundColor = theme.disabledColor.withAlpha(100);
    const requestTimeoutDuration = Duration(minutes: 1);
    const requestTimeoutWarningDuration = Duration(seconds: 12); // A warning
    // color will be shown if it remains only this duration.
    final countdownController = CountdownSliderController();
    const price =
        20.0; // TODO set fare settings and calculate price based on that
    showBottomSheet(
        elevation: 4,
        context: context,
        builder: (context) {
          bool isBottomSheetOpened = true;
          void closeBottomSheet() {
            if (isBottomSheetOpened) {
              isBottomSheetOpened = false;
              Navigator.of(context).pop();
            }
          }

          _onStateResetedListenners.add(closeBottomSheet);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: _BottomSheetHeader(
                    // _RiderData(
                    //   imageURL:
                    //       "https://news.cornell.edu/sites/default/files/styles/breakout/public/2020-05/0521_abebegates.jpg?itok=OdW8otpB",
                    //   rating: 4.8,
                    //   paymentMethod: "By cash",
                    //   name: "Rediet Abebe",
                    // ),
                    bookingRequestData.riderData,
                    trailingWidget: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          price.toCurrencyString(
                            leadingSymbol: "R",
                            useSymbolPadding: true,
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 19,
                          ),
                        ),
                        Text(
                          bookingRequestData.distance,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: gray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                CountdownSlider(
                  duration: requestTimeoutDuration,
                  activeColor: theme.accentColor,
                  inactiveColor: lightGray,
                  warningColor: theme.errorColor,
                  controller: countdownController,
                  warningDuration: requestTimeoutWarningDuration,
                  onTimeout: closeBottomSheet,
                ),
                ListTile(
                  leading: CircleAvatar(
                    child: SvgPicture.asset(
                      "assets/images/pickup_icon.svg",
                      package: "shared",
                    ),
                    backgroundColor: iconsBackgroundColor,
                  ),
                  title: RichText(
                    text: TextSpan(
                      text: "PICK UP",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                        color: theme.disabledColor,
                      ),
                      children: [
                        TextSpan(
                          text: " (1.7km away from your location)",
                          style: TextStyle(
                            color: theme.disabledColor.withAlpha(180),
                          ),
                        ),
                      ],
                    ),
                  ),
                  subtitle: Text(bookingRequestData.pickUpAddress),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: CircleAvatar(
                    child: Image.asset(
                      "assets/images/dropoff_icon.png",
                      package: "shared",
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
                  subtitle: Text(bookingRequestData.dropOfAddress),
                ),
                const Divider(height: 1),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SmallRoundedCornerButton(
                        "Decline",
                        backgroundColor: theme.errorColor.withAlpha(200),
                        onPressed: () {
                          countdownController.cancel();
                          _dispatcher.sendData(
                            MapEntry(
                              FramType.REFUSE_BOOKING,
                              bookingRequestData.id,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 30),
                      SmallRoundedCornerButton(
                        "Accept",
                        backgroundColor: theme.accentColor,
                        onPressed: () {
                          countdownController.cancel();
                          _dispatcher.sendData(
                            MapEntry(
                              FramType.ACCEPT_BOOKING,
                              bookingRequestData.id,
                            ),
                          );
                          Navigator.of(context).pop();
                          _showBottomSheetActions(bookingRequestData.riderData,
                              (actionName) async {
                            // TODO create update trip object and set status to arrived pickup
                            if (actionName ==
                                _CollapsibleBottomSheet.arrivedPickup) {
                              await _tripRoom
                                  ?.sendCustomEvent("driver_arrived_pickup");
                            } else if (actionName ==
                                _CollapsibleBottomSheet.showQrCode) {
                              _showQrCodeDialog(
                                  "qrCodeData"); // TODO generate qr code data.
                            } else if (actionName ==
                                _CollapsibleBottomSheet.endTrip) {
                              // TODO check if the current location of the driver is near the drop off location, if not near there ask him confirmation and say we detect his location far from drop off
                              await _tripRoom
                                  ?.sendCustomEvent("driver_end_trip");
                            }
                          });
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  void _showBottomSheetActions(
    _RiderData _riderData, [
    Function(String)? onBottomSheetButtonPressed,
  ]) {
    final theme = Theme.of(context);
    showBottomSheet(
      backgroundColor: Colors.transparent,
      elevation: 0,
      context: context,
      builder: (context) {
        return _CollapsibleBottomSheet(
          _riderData,
          onBottomButtonPressed: onBottomSheetButtonPressed,
        );
      },
    );
  }

  // void _showReviewNotification(MapEntry<double, String> notificationData) {
  //   setState(() {
  //     _notification = Container(
  //         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
  //         color: Theme.of(context).primaryColor,
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Column(
  //               children: [
  //                 RatingBarIndicator(
  //                   itemSize: 22,
  //                   rating: notificationData.key,
  //                   itemBuilder: (BuildContext context, int index) =>
  //                       const Icon(
  //                     Icons.star,
  //                     color: yellow,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 5),
  //                 Text(
  //                   notificationData.value,
  //                   style: const TextStyle(
  //                     color: Colors.white,
  //                     fontSize: 13,
  //                     fontWeight: FontWeight.w500,
  //                   ),
  //                 )
  //               ],
  //             ),
  //           ],
  //         ));
  //   });
  // }

  void _showRatingBottomSheet(_RiderData riderData) {
    double rating = 0.0;
    showBottomSheet(
      elevation: 4,
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return Wrap(
          alignment: WrapAlignment.center,
          children: [
            Container(
              color: lightGray,
              padding: const EdgeInsets.only(
                left: 24,
                right: 16,
                top: 10,
                bottom: 10,
              ),
              child: _BottomSheetHeader(riderData),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: RatingBar(
                glow: false,
                itemSize: 50,
                minRating: 1,
                initialRating: 1,
                allowHalfRating: true,
                onRatingUpdate: (newValue) => rating = newValue,
                ratingWidget: RatingWidget(
                  empty: Icon(
                    Icons.star_rate,
                    color: theme.disabledColor.withAlpha(200),
                  ),
                  half: const Icon(
                    Icons.star_half,
                    color: yellow,
                  ),
                  full: const Icon(
                    Icons.star_rate,
                    color: yellow,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 24,
                    ),
                    child: TextButton(
                      onPressed: () {
                        // TODO Submit rating
                      },
                      child: const Text(
                        "Submit",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _showQrCodeDialog(String qrCodeData) {
    final dialogSize = MediaQuery.of(context).size.width * 0.8;
    final theme = Theme.of(context);
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.accentColor,
        title: const Text(
          "QR Code",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Container(
          alignment: Alignment.center,
          width: dialogSize,
          height: dialogSize * 0.8,
          child: QrImage(
            backgroundColor: Colors.white,
            data: qrCodeData,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              "CLOSE",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusNotification {
  final String title;
  final String subtitle;
  final String imageURL;
  final Color backgroundColor;

  const _StatusNotification(
    this.title,
    this.subtitle,
    this.imageURL, {
    this.backgroundColor = const Color(0xB0FE1B17),
  });

  static const offline = _StatusNotification(
    "You are offline!",
    "Go online to start accepting rides.",
    "assets/images/offline_notification_icon.svg",
  );

  static const bookingIgnored = _StatusNotification(
    "Request has been ignored",
    "Beware! It affects your Acceptance Rate",
    "assets/images/warning_icon.svg",
  );

  static const connecting = _StatusNotification(
    "Connecting, please wait...",
    "It may take a few seconds",
    "",
    backgroundColor: Color(0xFF008dd4),
  );

  static const disconnecting = _StatusNotification(
    "Disconnecting, please wait...",
    "It may take a few seconds",
    "",
    backgroundColor: Color(0xFF008dd4),
  );
}

class _CollapsibleBottomSheet extends StatefulWidget {
  static const arrivedPickup = "Arrived Pickup location";
  static const showQrCode = "Show Qr Code";
  static const endTrip = "End Trip";
  final _RiderData _riderData;
  final Function(String)? onBottomButtonPressed;

  const _CollapsibleBottomSheet(this._riderData,
      {Key? key, this.onBottomButtonPressed})
      : super(key: key);

  @override
  _CollapsibleBottomSheetState createState() => _CollapsibleBottomSheetState();
}

class _CollapsibleBottomSheetState extends State<_CollapsibleBottomSheet> {
  bool _contentVisible = true;
  String currentAction = _CollapsibleBottomSheet.arrivedPickup;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      children: [
        Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 40,
                margin: const EdgeInsets.only(right: 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: InkWell(
                  onTap: () =>
                      setState(() => _contentVisible = !_contentVisible),
                  child: Column(
                    children: [
                      RotatedBox(
                        quarterTurns: 1,
                        child: Icon(
                          _contentVisible
                              ? Icons.navigate_next
                              : Icons.navigate_before,
                          size: 35,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            Wrap(
              children: [
                const SizedBox(height: 25, width: double.infinity),
                Container(
                  color: lightGray,
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 16,
                    top: 10,
                    bottom: 10,
                  ),
                  child: _BottomSheetHeader(
                    widget._riderData,
                    trailingWidget: Row(
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(10),
                            backgroundColor: Colors.black,
                            minimumSize: const Size(24, 24),
                            shape: const CircleBorder(),
                          ),
                          child: SvgPicture.asset(
                            "assets/images/calling_icon.svg",
                            package: "shared",
                          ),
                          onPressed: () {},
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(10),
                            backgroundColor: Colors.black,
                            shape: const CircleBorder(),
                          ),
                          child: SvgPicture.asset(
                            "assets/images/chat_icon.svg",
                            package: "shared",
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: _contentVisible ? null : 0,
                  child: Container(
                    color: theme.scaffoldBackgroundColor,
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 24),
                            child: TextButton(
                              onPressed: () => widget.onBottomButtonPressed
                                  ?.call(currentAction),
                              child: Text(
                                currentAction,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    widget.onBottomButtonPressed != null
                                        ? theme.accentColor
                                        : theme.disabledColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
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
          ],
        ),
      ],
    );
  }
}

class _BottomSheetHeader extends StatelessWidget {
  final _RiderData data;
  final Widget trailingWidget;

  const _BottomSheetHeader(
    this.data, {
    Key? key,
    this.trailingWidget = const SizedBox(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleBoxesDecoration = BoxDecoration(
      color: theme.disabledColor.withAlpha(100),
      borderRadius: const BorderRadius.all(
        Radius.circular(4),
      ),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(data.imageURL),
              radius: 26,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(
                        right: 9,
                        left: 3,
                        top: 1,
                        bottom: 1,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: yellow, size: 15),
                          const SizedBox(width: 2),
                          Text(
                            data.rating.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      decoration: subtitleBoxesDecoration,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 1,
                      ),
                      child: Text(
                        data.paymentMethod,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      decoration: subtitleBoxesDecoration,
                    ),
                  ],
                )
              ],
            )
          ],
        ),
        trailingWidget,
      ],
    );
  }
}

class NavigationDrawer extends StatelessWidget {
  final Driver _driver;
  const NavigationDrawer(this._driver, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(21),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Column(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                  idToProfilePicture(_driver.account.id),
                ),
                radius: 38,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "Nicole Mason", // _driver.account.nickname,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ),
              Text(
                "I am a passionate driver, I have 4+ years of winning experience in driving", //_driver.bio,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
          const Divider(thickness: 2, height: 32),
          ListTile(
            horizontalTitleGap: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            visualDensity: VisualDensity(vertical: -2),
            tileColor: lightGray,
            leading: Icon(Icons.home),
            title: Text(
              "Home",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            horizontalTitleGap: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            visualDensity: VisualDensity(vertical: -2),
            tileColor: lightGray,
            leading: Icon(Icons.home),
            title: Text(
              "Earnings",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            horizontalTitleGap: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            visualDensity: VisualDensity(vertical: -2),
            tileColor: lightGray,
            leading: Icon(Icons.home),
            title: Text(
              "Settings",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            horizontalTitleGap: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            visualDensity: VisualDensity(vertical: -2),
            tileColor: lightGray,
            leading: Icon(Icons.home),
            title: Text(
              "Bookings",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            horizontalTitleGap: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            visualDensity: VisualDensity(vertical: -2),
            tileColor: lightGray,
            leading: Icon(Icons.home),
            title: Text(
              "Help and Support",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 80),
          ListTile(
            onTap: () {
              // TODO logout
            },
            horizontalTitleGap: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            visualDensity: VisualDensity(vertical: -2),
            leading: Icon(Icons.home),
            title: Text(
              "Logout",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingRequestData {
  final String id;
  final _RiderData riderData;
  final String pickUpAddress;
  final String dropOfAddress;
  final String distance;
  final String duration;
  final List<String> stops;

  _BookingRequestData({
    required this.id,
    required this.riderData,
    required this.pickUpAddress,
    required this.dropOfAddress,
    required this.distance,
    required this.duration,
    required this.stops,
  });
}

class _RiderData {
  final String imageURL;
  final String rating;
  final String paymentMethod;
  final String name;

  _RiderData({
    required this.imageURL,
    required this.rating,
    required this.paymentMethod,
    required this.name,
  });
}

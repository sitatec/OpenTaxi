import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import 'widgets/custom_switch.dart';

// TODO refactor
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isDriverOnline = false;
  _StatusNotification? _statusNotification = _StatusNotification.offline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CircleAvatar(
                backgroundImage: NetworkImage(
                  "https://static9.depositphotos.com/1060743/1203/i/600/depositphotos_12033497-stock-photo-portrait-of-young-black-man.jpg",
                ),
                radius: 24,
              ),
              FlutterSwitch(
                value: _isDriverOnline,
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
                inactiveColor: theme.disabledColor,
                activeColor: theme.accentColor,
                showOnOff: true,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: lightGray, width: 2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.search, color: theme.disabledColor),
                  onPressed: () =>
                      _showBottomSheetActions("Arrived Pickup location", () {}),
                ),
              ),
            ],
          ),
        ),
        Stack(
          children: [
            Container(
              color: theme.disabledColor,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 195,
            ),
            if (_statusNotification != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                color: theme.errorColor.withAlpha(200),
                child: Row(
                  children: [
                    SvgPicture.asset(_statusNotification!.imageURL),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _statusNotification!.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _statusNotification!.subtitle,
                          style: TextStyle(
                            color: Colors.white.withAlpha(200),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
          ],
        )
      ],
    );
  }

  void _toggleDriverOnlineStatus(bool isOnline) =>
      setState(() => _isDriverOnline = isOnline);

  void _showBookingRequest(/*TODO pass booking data*/) {
    final theme = Theme.of(context);
    final iconsBackgroundColor = theme.disabledColor.withAlpha(100);
    const price = 20.0;
    const distance = 2.1;
    showBottomSheet(
        elevation: 4,
        context: context,
        builder: (context) {
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
                    _RiderData(
                      imageURL:
                          "https://news.cornell.edu/sites/default/files/styles/breakout/public/2020-05/0521_abebegates.jpg?itok=OdW8otpB",
                      rating: 4.8,
                      paymentMethod: "By cash",
                      name: "Rediet Abebe",
                    ),
                    trailingWidget: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "\$${price.toCurrencyString()}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 19,
                          ),
                        ),
                        const Text(
                          "$distance km",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: gray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: CircleAvatar(
                    child: SvgPicture.asset("assets/images/pickup_icon.svg"),
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
                  subtitle:
                      const Text("20 Kado street, Ikeja Lagos Luchkovski"),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: CircleAvatar(
                    child: SvgPicture.asset("assets/images/dropoff_icon.svg"),
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
                  subtitle:
                      const Text("20 Kado street, Ikeja Lagos Luchkovski"),
                ),
                const Divider(height: 1),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Ignore",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                theme.errorColor.withAlpha(200)),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 30),
                      Expanded(
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Accept",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(theme.accentColor),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  void _showBottomSheetActions(String bottomButtonText,
      [VoidCallback? onBottomButtonPressed]) {
    final theme = Theme.of(context);
    showBottomSheet(
        elevation: 4,
        context: context,
        builder: (context) {
          return Wrap(
            children: [
              Container(
                color: lightGray,
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 16,
                  top: 10,
                  bottom: 10,
                ),
                child: _BottomSheetHeader(
                    _RiderData(
                      imageURL:
                          "https://news.cornell.edu/sites/default/files/styles/breakout/public/2020-05/0521_abebegates.jpg?itok=OdW8otpB",
                      rating: 4.8,
                      paymentMethod: "By cash",
                      name: "Rediet Abebe",
                    ),
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
                              "assets/images/calling_icon.svg"),
                          onPressed: () {},
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(10),
                            backgroundColor: Colors.black,
                            shape: const CircleBorder(),
                          ),
                          child:
                              SvgPicture.asset("assets/images/chat_icon.svg"),
                          onPressed: () {},
                        ),
                      ],
                    )),
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 24),
                      child: TextButton(
                        onPressed: onBottomButtonPressed,
                        child: Text(
                          bottomButtonText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: onBottomButtonPressed != null
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
            ],
          );
        });
  }
}

class _StatusNotification {
  final String title;
  final String subtitle;
  final String imageURL;

  const _StatusNotification(this.title, this.subtitle, this.imageURL);

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
                        vertical: 2,
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

class _RiderData {
  final String imageURL;
  final double rating;
  final String paymentMethod;
  final String name;

  _RiderData({
    required this.imageURL,
    required this.rating,
    required this.paymentMethod,
    required this.name,
  });
}

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
                  onPressed: _showBookingRequest,
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
    showBottomSheet(
        elevation: 4,
        context: context,
        builder: (context) {
          return Wrap(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: _BottomSheetHeader(
                  _RiderData(
                    imageURL:
                        "https://news.cornell.edu/sites/default/files/styles/breakout/public/2020-05/0521_abebegates.jpg?itok=OdW8otpB",
                    rating: 4.8,
                    paymentMethod: "By cash",
                    name: "Rediet Abebe",
                  ),
                ),
              )
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
                        right: 8,
                        left: 2,
                        top: 2,
                        bottom: 2,
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
                        horizontal: 8,
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

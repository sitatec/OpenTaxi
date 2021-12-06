import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:shared/shared.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
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
                backgroundImage:  NetworkImage(
                    "https://static9.depositphotos.com/1060743/1203/i/600/depositphotos_12033497-stock-photo-portrait-of-young-black-man.jpg",
                  ),
                radius: 24,
              ),
              FlutterSwitch(
                value: _isDriverOnline,
                onToggle: _toggleDriverOnlineStatus,
                activeText: "Online",
                inactiveText: "Offline",
                inactiveIcon:
                    SvgPicture.asset("assets/images/offline_icon.svg"),
                activeIcon: SvgPicture.asset("assets/images/online_icon.svg"),
                activeTextFontWeight: FontWeight.w500,
                inactiveTextFontWeight: FontWeight.w500,
                valueFontSize: 18,
                inactiveColor: theme.disabledColor,
                activeColor: theme.accentColor,
                width: 95,
                height: 34,
                showOnOff: true,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: lightGray, width: 2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.search, color: theme.disabledColor),
                  onPressed: () {
                    showBottomSheet(
                        context: context,
                        builder: (context) => Center(
                              child: Text("HERE"),
                            ));
                  },
                ),
              ),
            ],
          ),
        ),
        if(_statusNotification != null)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
    );
  }

  void _toggleDriverOnlineStatus(bool isOnline) =>
      setState(() => _isDriverOnline = isOnline);
}

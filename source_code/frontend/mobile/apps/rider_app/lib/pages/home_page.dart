import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rider_app/pages/place_selection_page.dart';
import 'package:shared/shared.dart';

class HomePage extends StatefulWidget {
  final Account _riderAccount;
  const HomePage(this._riderAccount, {Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> _mapController = Completer();
  bool _hasUnRedNotification = true;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      drawer: NavigationDrawer(widget._riderAccount),
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: Colors.black54,
        title: const Text(
          "Home",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Image.asset(
              "assets/images/${_hasUnRedNotification ? 'notification_received' : 'notification'}.png",
              package: "shared",
              width: 19,
            ),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MapWidget(
              padding: const EdgeInsets.only(bottom: 45),
              controller: _mapController,
            ),
            // Align(
            //   alignment: Alignment.bottomLeft,
            //   child: Padding(
            //     padding: const EdgeInsets.all(8),
            //     child: Row(
            //       children: [
            //         FavoritePlaceWidget(
            //           child: const Icon(
            //             Icons.add,
            //             color: Colors.black87,
            //           ),
            //           padding: const EdgeInsets.all(7.6),
            //           onClicked: showFavoritePlaceDialog,
            //         ),
            //         const SizedBox(width: 12),
            //         const FavoritePlaceWidget(child: Text("Home")),
            //         const SizedBox(width: 12),
            //         const FavoritePlaceWidget(child: Text("Work"))
            //       ],
            //     ),
            //   ),
            // ),
          ),
          Container(
            padding: const EdgeInsets.only(
              right: 16,
              left: 16,
              top: 18,
              bottom: 40,
            ),
            color: Colors.white,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return PlaceSelectionPage(widget._riderAccount);
                    },
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: lightGray,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: theme.disabledColor, size: 26),
                    const SizedBox(width: 8),
                    const Text("Where to go?")
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Future<void> showFavoritePlaceDialog([String? _placeName, String? _address]) {
  //   String? placeName = _placeName;
  //   String? address = _address;
  //   return showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text(
  //         "New Favorite Place",
  //         textAlign: TextAlign.center,
  //       ),
  //       contentPadding: const EdgeInsets.all(16),
  //       content: Wrap(
  //         alignment: WrapAlignment.center,
  //         children: [
  //           TextField(
  //             controller: TextEditingController(text: placeName),
  //             onChanged: (newValue) => placeName = newValue,
  //             decoration: const InputDecoration(
  //               labelText: "Label (e.g. Home, Work)",
  //             ),
  //           ),
  //           TextField(
  //             controller: TextEditingController(text: address),
  //             onChanged: (newValue) => address = newValue,
  //             decoration: const InputDecoration(
  //               labelText: "Address",
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.only(top: 16),
  //             child: SmallRoundedCornerButton(
  //               "Add",
  //               padding: const EdgeInsets.symmetric(
  //                 horizontal: 24,
  //                 vertical: 8,
  //               ),
  //               onPressed: () =>
  //                   Navigator.of(context).pop(MapEntry(placeName, address)),
  //               backgroundColor: Theme.of(context).primaryColor,
  //             ),
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

class NavigationDrawer extends StatelessWidget {
  final Account _riderAccount;
  const NavigationDrawer(this._riderAccount, {Key? key}) : super(key: key);

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
                  idToProfilePicture(_riderAccount.id),
                ),
                radius: 38,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "Nicole Mason", // _driver.account.nickname,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ),
            ],
          ),
          const Divider(thickness: 2, height: 32),
          ListTile(
            horizontalTitleGap: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            visualDensity: const VisualDensity(vertical: -1.8),
            tileColor: lightGray,
            leading: const Icon(Icons.home, color: Color(0xFFB7B7B7)),
            title: const Text(
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
            visualDensity: const VisualDensity(vertical: -1.8),
            tileColor: lightGray,
            leading: const Icon(Icons.favorite, color: Color(0xFFB7B7B7)),
            title: const Text(
              "Favorites",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            horizontalTitleGap: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            visualDensity: const VisualDensity(vertical: -1.8),
            tileColor: lightGray,
            leading: const Icon(Icons.account_balance_wallet,
                color: Color(0xFFB7B7B7)),
            title: const Text(
              "Wallet",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            horizontalTitleGap: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            visualDensity: const VisualDensity(vertical: -1.8),
            tileColor: lightGray,
            leading: const Icon(Icons.directions_car, color: Color(0xFFB7B7B7)),
            title: const Text(
              "My Rides",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            horizontalTitleGap: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            visualDensity: const VisualDensity(vertical: -1.8),
            tileColor: lightGray,
            leading: const Icon(Icons.settings, color: Color(0xFFB7B7B7)),
            title: const Text(
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
            visualDensity: const VisualDensity(vertical: -1.8),
            tileColor: lightGray,
            leading: const Icon(Icons.help, color: Color(0xFFB7B7B7)),
            title: const Text(
              "Help and Support",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 80),
          Container(
            decoration: BoxDecoration(
                border: Border.symmetric(
                    horizontal: BorderSide(color: Colors.blueGrey[100]!))),
            child: ListTile(
              onTap: () {
                // TODO logout
              },
              horizontalTitleGap: 0,
              visualDensity: const VisualDensity(vertical: -1.8),
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Logout",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class FavoritePlaceWidget extends StatelessWidget {
//   final Color backgroundColor;
//   final Widget child;
//   final VoidCallback? onClicked;
//   final EdgeInsets padding;

//   const FavoritePlaceWidget({
//     Key? key,
//     required this.child,
//     this.onClicked,
//     this.padding = const EdgeInsets.all(8),
//     this.backgroundColor = Colors.white,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onClicked,
//       child: Container(
//         padding: padding,
//         decoration: BoxDecoration(
//           color: backgroundColor,
//           borderRadius: BorderRadius.circular(5),
//         ),
//         child: child,
//       ),
//     );
//   }
// }

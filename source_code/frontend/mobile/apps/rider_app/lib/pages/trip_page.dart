import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class TripPage extends StatefulWidget {
  const TripPage({Key? key}) : super(key: key);

  @override
  _TripPageState createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  bool tripDetailsShown = false;
  bool driverArrived = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconsBackgroundColor = theme.disabledColor.withAlpha(100);
    return Scaffold(
      body: Stack(
        children: [
          const MapWidget(padding: EdgeInsets.only(bottom: 45)),
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
              color: Colors.white,
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Container(
                    color: lightGray,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: _BottomSheetHeader(
                      _DriverData(
                        imageURL: idToProfilePicture(""),
                        rating: "4.5",
                        name: "Miram Diallo",
                      ),
                    ),
                  ),
                  Text(
                    "Arrivin in 4 min",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("Gray Vesta | ", style: TextStyle(fontSize: 17)),
                      Text(
                        "01E2S5KS",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => setState(
                      () => tripDetailsShown = !tripDetailsShown,
                    ),
                    child: Text(tripDetailsShown
                        ? "Hide information"
                        : "More information"),
                  ),
                  if (driverArrived)
                    TextButton(
                      onPressed: () {},
                      child: const Text("Scan qrcode"),
                    ),
                  if (tripDetailsShown) ...[
                    ListTile(
                      leading: CircleAvatar(
                        child: SvgPicture.asset("assets/images/pickup_icon.svg",
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
                      contentPadding: EdgeInsets.only(bottom: 24, left: 16),
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
                  ]
                ],
              ),
            ),
          ),
          SafeArea(
            child: Align(
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
          ),
        ],
      ),
    );
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
              "You will charged an additional 200 cancellation",
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                backgroundColor: theme.errorColor.withAlpha(190),
                onPressed: () {
                  // TODO cancel
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
        });
  }
}

class _DriverData {
  final String imageURL;
  final String rating;
  final String name;

  _DriverData({
    required this.imageURL,
    required this.rating,
    required this.name,
  });
}

class _BottomSheetHeader extends StatelessWidget {
  final _DriverData data;

  const _BottomSheetHeader(
    this.data, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                      decoration: BoxDecoration(
                        color: theme.disabledColor.withAlpha(100),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(4),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
        Row(
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
      ],
    );
  }
}

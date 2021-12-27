import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconsBackgroundColor = theme.disabledColor.withAlpha(100);
    return Stack(
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
            child: Column(
              children: [
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
                  subtitle: Text("bookingRequestData.pickUpAddress"),
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
                  subtitle: Text("bookingRequestData.dropOfAddress"),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

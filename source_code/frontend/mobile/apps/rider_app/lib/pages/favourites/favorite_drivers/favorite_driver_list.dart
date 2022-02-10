import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class FavoriteDriver extends StatefulWidget {
  const FavoriteDriver({Key? key}) : super(key: key);

  @override
  _FavoriteDriverState createState() => _FavoriteDriverState();
}

class _FavoriteDriverState extends State<FavoriteDriver> {
  final _favoriteDrivers = <JsonObject>[];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _favoriteDrivers.length,
      itemBuilder: (context, index) {
        final driver = _favoriteDrivers[index];
        return ListTile(
          isThreeLine: true,
          title: Row(
            children: [
              Text(
                driver["display_name"] ??
                    '$driver["first_name"] ${driver["last_name"]}',
              ),
              // TODO check if the driver have a rating and show it (update the backend to include the rating)
            ],
          ),
          subtitle: Column(
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF594F4F),
                  ),
                  text: "Car",
                  children: [
                    TextSpan(
                      style: const TextStyle(fontWeight: FontWeight.w400),
                      text:
                          "${driver["vehicle_make"]} - ${driver["vehicle_model"]}",
                    )
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF594F4F),
                  ),
                  text: "Rate",
                  children: [
                    TextSpan(
                      style: const TextStyle(fontWeight: FontWeight.w400),
                      text: "R.s ${driver["price_by_km"]} per km}",
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

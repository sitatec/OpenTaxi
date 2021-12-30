import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class LocationPermissionPage extends StatelessWidget {
  final VoidCallback onEnableButtonClicked;
  final Widget? description;

  const LocationPermissionPage({
    Key? key,
    required this.onEnableButtonClicked,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final contentWidth = MediaQuery.of(context).size.width * 0.7;
    return Wrap(
      direction: Axis.vertical,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          child: const Icon(
            Icons.location_on_rounded,
            color: Colors.white,
            size: 50,
          ),
          backgroundColor: gray.withAlpha(60),
        ),
        const SizedBox(height: 25),
        const Text(
          "Enable Location",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 16, bottom: 50),
          width: contentWidth,
          child: description ??
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                    text:
                        'Your location will be used to send you requests from the closest riders. In the next step select "',
                    style: TextStyle(color: gray, fontSize: 15),
                    children: [
                      TextSpan(
                        text: 'Allways',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: "\" or \""),
                      TextSpan(
                        text: 'All the time',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        children: [],
                      ),
                      TextSpan(
                        text:
                            "\" otherwise we won't have the required permission.",
                      )
                    ]),
              ),
        ),
        SizedBox(
          width: contentWidth,
          child: RoundedCornerButton(
            child: const Text(
              "Enable",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            onPressed: onEnableButtonClicked,
          ),
        )
      ],
    );
  }
}

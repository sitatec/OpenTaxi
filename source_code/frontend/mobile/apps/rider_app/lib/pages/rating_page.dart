import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class RatingPage extends StatelessWidget {
  const RatingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double rating = 0;
    String comment = "";
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 50),
            child: Column(
              children: [
                const Text(
                  "The ride is over",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text("Rate your trip, it is important for us"),
                Padding(
                  padding: const EdgeInsets.only(top: 28, bottom: 16),
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
                        color: theme.disabledColor.withAlpha(170),
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
                TextField(
                  onChanged: (value) => comment = value,
                  autofocus: true,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: "Write your comment",
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 8),
                RoundedCornerButton(
                  child: const Text(
                    "Submit",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () {},
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

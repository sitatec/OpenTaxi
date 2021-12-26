import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                const MapWidget(padding: EdgeInsets.only(bottom: 45)),
                SafeArea(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
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
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: const [
                        FavoritePlaceWidget(
                          child: Icon(
                            Icons.add,
                            color: Colors.black87,
                          ),
                          padding: EdgeInsets.all(7.6),
                        ),
                        SizedBox(width: 12),
                        FavoritePlaceWidget(child: Text("Home")),
                        SizedBox(width: 12),
                        FavoritePlaceWidget(child: Text("Work"))
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
              onTap: () {},
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
}

class FavoritePlaceWidget extends StatelessWidget {
  final Color backgroundColor;
  final Widget child;
  final VoidCallback? onClicked;
  final EdgeInsets padding;

  const FavoritePlaceWidget({
    Key? key,
    required this.child,
    this.onClicked,
    this.padding = const EdgeInsets.all(8),
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClicked,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: child,
      ),
    );
  }
}

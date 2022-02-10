import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class FavoritesPage extends StatelessWidget {
  final Account riderAccount;
  const FavoritesPage(this.riderAccount, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(backgroundColor: theme.primaryColor),
          body: TabBarView(
            children: [],
          )),
    );
  }
}

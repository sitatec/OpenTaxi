import 'package:driver_app/home.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const _tabs = [
    HomePage(),
    Center(child: Text("Statistics")),
    Center(child: Text("Settings"))
  ];
  static const _tabIconSize = 24.0;
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: _tabs[_selectedTabIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/images/navigation.svg",
              color: _selectedTabIndex == 0 ? theme.primaryColor : theme.disabledColor,
              width: _tabIconSize,
              height: _tabIconSize,
            ),
            label: "Navigation",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/images/stats.svg",
              color: _selectedTabIndex == 1 ? theme.primaryColor : theme.disabledColor,
              width: _tabIconSize,
              height: _tabIconSize,
            ),
            label: "Statistics",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/images/settings.svg",
              color: _selectedTabIndex == 2 ? theme.primaryColor : theme.disabledColor,
              width: _tabIconSize,
              height: _tabIconSize,
            ),
            label: "Settings",
          ),
        ],
        currentIndex: _selectedTabIndex,
        onTap: (index) => setState(() => _selectedTabIndex = index),
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}

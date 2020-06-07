import 'package:flutter/material.dart';
import 'package:freibad_app/screens/home_screen/components/custom_bottom_navigation_bar.dart';
import 'package:freibad_app/screens/home_screen/subscreens/codes_subscreen.dart';
import 'package:freibad_app/screens/home_screen/subscreens/reserve_subscreen.dart';
import 'package:freibad_app/screens/home_screen/subscreens/settings_subscreen.dart';

class HomeScreen extends StatefulWidget {
  final List<Widget> subscreens = [CodesSubscreen(), ReserveSubscreen(), SettingsSubscreen()];

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var bottomNavBarIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: widget.subscreens[bottomNavBarIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: bottomNavBarIndex,
        onTap: (index) => setState(
          () {
            bottomNavBarIndex = index;
          },
        ),
      ),
    );
  }
}

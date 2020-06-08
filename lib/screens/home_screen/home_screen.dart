import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:freibad_app/provider/local_data.dart';
import 'package:freibad_app/screens/home_screen/components/custom_bottom_navigation_bar.dart';
import 'package:freibad_app/screens/home_screen/subscreens/codes_subscreen.dart';
import 'package:freibad_app/screens/home_screen/subscreens/pick_subscreen.dart';
import 'package:freibad_app/screens/home_screen/subscreens/settings_subscreen.dart';

class HomeScreen extends StatefulWidget {
  final List<Widget> subscreens = [
    CodesSubscreen(),
    PickSubscreen(),
    SettingsSubscreen()
  ];

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> getLocalData;
  bool isInitState = true;
  int bottomNavBarIndex = 0;

  @override
  void didChangeDependencies() {
    if (isInitState) {
      getLocalData = Provider.of<LocalData>(context).fetchAndSetData();
      isInitState = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: FutureBuilder(
        future: getLocalData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done)
            return widget.subscreens[bottomNavBarIndex];
          else
            return Center(
              child: CircularProgressIndicator(),
            );
        },
      ),
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

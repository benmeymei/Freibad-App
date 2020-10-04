import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:freibad_app/provider/session_data.dart';
import 'package:freibad_app/provider/settings.dart';
import 'package:freibad_app/provider/weather_data.dart';

import 'package:provider/provider.dart';

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
  Future<void> getWeather;
  int bottomNavBarIndex = 0;
  bool isInitState = true;

  @override
  void didChangeDependencies() {
    if (isInitState) {
      getLocalData =
          Provider.of<SessionData>(context, listen: false).fetchAndSetData();
      getWeather =
          Provider.of<WeatherData>(context, listen: false).fetchAndSetData();

      developer.log('fetching and setting data request send');
      isInitState = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Consumer<Settings>(
        builder: (_, settings, __) {
          if (!settings.isUpdated) {
            //check if data requires an update because the settings changed
            getLocalData = Provider.of<SessionData>(context, listen: false)
                .fetchAndSetData();
            getWeather = Provider.of<WeatherData>(context, listen: false)
                .fetchAndSetData();
            developer.log('fetching and setting data request send');
            Provider.of<Settings>(context, listen: false).isUpdated = true;
          }
          return FutureBuilder(
            future: Future.wait([getLocalData, getWeather]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return widget.subscreens[bottomNavBarIndex];
              } else if (snapshot.hasError) {
                developer.log(
                    'Loading data from external source (SQLite/API) failed: ',
                    error: snapshot.error);
                return widget.subscreens[bottomNavBarIndex];
              } else
                return Center(
                  child: CircularProgressIndicator(),
                );
            },
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

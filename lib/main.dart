import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freibad_app/provider/auth_data.dart';
import 'package:freibad_app/provider/session_data.dart';
import 'package:freibad_app/provider/settings.dart';
import 'package:freibad_app/provider/weather_data.dart';
import 'package:freibad_app/screens/auth_screen/auth_screen.dart';
import 'package:provider/provider.dart';
import 'package:freibad_app/screens/home_screen/home_screen.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Color.fromRGBO(20, 20, 25, 1),
    systemNavigationBarColor: Color.fromRGBO(20, 20, 25, 1),
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final bool useServerAPIService = true;
  final bool useWeatherAPIService = true;
  final bool useStorageService =
      !kIsWeb; //storage service functions only on mobile

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Settings(
              useServerAPIService, useWeatherAPIService, useStorageService),
        ),
        ChangeNotifierProxyProvider<Settings, AuthData>(
          update: (_, settings, __) => AuthData(
              useAPIService: settings.useServer,
              useStorageService: settings.useStorageService),
          create: (_) => AuthData(
              useAPIService: useServerAPIService,
              useStorageService: useServerAPIService),
        ),
        ChangeNotifierProxyProvider2<Settings, AuthData, SessionData>(
          update: (_, settings, authData, __) => SessionData(
            useAPIService: settings.useServer,
            useStorageService: settings.useStorageService,
            token: authData.token,
          ),
          create: (_) => SessionData(
            useAPIService: useServerAPIService,
            useStorageService: useStorageService,
            token: '',
          ),
        ),
        ChangeNotifierProxyProvider<Settings, WeatherData>(
          update: (_, settings, __) =>
              WeatherData(useAPIService: settings.useWeatherAPI),
          create: (_) => WeatherData(useAPIService: useWeatherAPIService),
        ),
      ],
      child: Consumer<AuthData>(
        builder: (ctx, authData, _) => MaterialApp(
          title: 'Freibad',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.yellow,
            accentColor: Color.fromRGBO(128, 128, 128, 1),
            cardColor: Color.fromRGBO(50, 50, 50, 1),
            backgroundColor: Color.fromRGBO(20, 20, 25, 1),
            dialogBackgroundColor: Color.fromRGBO(50, 50, 50, 1),
            inputDecorationTheme: InputDecorationTheme(
              labelStyle: TextStyle(
                color: Color.fromRGBO(128, 128, 128, 1),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color.fromRGBO(128, 128, 128, 1),
                ),
              ),
            ),
            textTheme: Theme.of(context).textTheme.apply(
                  bodyColor: Colors.white,
                  displayColor: Colors.white,
                ),
          ),
          home: authData.isAuth
              ? HomeScreen()
              : FutureBuilder(
                  future: authData.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? Scaffold(
                              backgroundColor: Color.fromRGBO(20, 20, 25, 1),
                              body: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : AuthScreen()),
        ),
      ),
    );
  }
}

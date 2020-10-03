import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freibad_app/provider/session_data.dart';
import 'package:freibad_app/provider/weather_data.dart';
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
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SessionData(useFakeAPIService: true),
        ),
        ChangeNotifierProvider(
          create: (_) => WeatherData(useFakeAPIService: false),
        ),
      ],
      child: MaterialApp(
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
        home: HomeScreen(),
      ),
    );
  }
}

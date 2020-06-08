import 'package:flutter/material.dart';
import 'package:freibad_app/provider/local_data.dart';
import 'package:provider/provider.dart';
import 'package:freibad_app/screens/home_screen/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocalData()),
      ],
      child: MaterialApp(
        title: 'Freibad',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Color.fromRGBO(246, 231, 29, 1),
          accentColor: Color.fromRGBO(128, 128, 128, 1),
          backgroundColor: Color.fromRGBO(20, 20, 25, 1),
        ),
        home: HomeScreen(),
      ),
    );
  }
}

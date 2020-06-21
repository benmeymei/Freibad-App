import 'package:flutter/material.dart';

class Weather {
  final IconData skyIcon;
  final double temp;
  final String tempUnit;

  Weather({
    @required this.skyIcon,
    @required this.temp,
    @required this.tempUnit,
  });
}

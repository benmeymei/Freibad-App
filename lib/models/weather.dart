import 'package:flutter/material.dart';

class Weather {
  final IconData skyIcon;
  final double maxTemp;
  final DateTime maxTempTime;
  final String tempUnit;

  Weather({
    @required this.skyIcon,
    @required this.maxTemp,
    @required this.maxTempTime,
    @required this.tempUnit,
  });
}

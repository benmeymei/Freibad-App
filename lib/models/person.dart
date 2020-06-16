import 'package:flutter/foundation.dart';

class Person {
  final String id;
  final String forename;
  final String name;
  final String streetName;
  final String streetNumber; //can be 3a
  final int postCode;
  final String city;
  final String phoneNumber;
  final String email;

  Person({
    @required this.id,
    @required this.forename,
    @required this.name,
    @required this.streetName,
    @required this.streetNumber,
    @required this.postCode,
    @required this.city,
    @required this.phoneNumber,
    @required this.email,
  });
}

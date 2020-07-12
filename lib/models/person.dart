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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'forename': forename,
      'name': name,
      'streetName': streetName,
      'streetNumber': streetNumber,
      'postCode': postCode,
      'city': city,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }

  @override
  String toString() {
    return "$forename $name";
  }
}

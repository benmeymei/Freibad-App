import 'package:flutter/foundation.dart';

class Request {
  final String id;
  final List<String> persons;
  final DateTime startTime;

  Request({
    @required this.id,
    @required this.persons,
    @required this.startTime,
  });
}

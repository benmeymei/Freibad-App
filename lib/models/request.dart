import 'package:flutter/foundation.dart';

class Request implements Comparable<Request> {
  final String id;
  final List<String> persons;
  final DateTime startTime;

  Request({
    @required this.id,
    @required this.persons,
    @required this.startTime,
  });

  @override
  int compareTo(Request other) {
    return startTime.compareTo(other.startTime);
  }
}

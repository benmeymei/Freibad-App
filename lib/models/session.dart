import 'package:flutter/foundation.dart';

class Session implements Comparable<Session> {
  final String id;
  final List<Map<String, String>> persons;
  final DateTime start;
  final DateTime end;

  Session({
    @required this.id,
    @required this.persons,
    @required this.start,
    @required this.end,
  });

  @override
  int compareTo(Session other) {
    return start.compareTo(other.start);
  }
}

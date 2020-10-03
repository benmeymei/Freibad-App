import 'package:flutter/foundation.dart';

abstract class Session implements Comparable<Session> {
  final String id;
  final List<Map<String, String>> accessList;
  final DateTime startTime;
  final DateTime endTime;

  Session({
    @required this.id,
    @required this.accessList,
    @required this.startTime,
    @required this.endTime,
  });

  @override
  int compareTo(Session other) {
    return startTime.compareTo(other.startTime);
  }
}

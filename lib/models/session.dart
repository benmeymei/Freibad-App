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

  //bad practice, rather than saved in a single string, accessList should have its own db table
  String accessListToString(List<Map<String, String>> accessList) {
    String encodedAccessList = '';

    for (Map<String, String> accessMap in accessList) {
      encodedAccessList += '${accessMap['person']},';
    }

    return encodedAccessList;
  }

  //bad practice, rather than saved in a single string, accessList should have its own db table
  static List<Map<String, String>> stringToAccessList(
      String encodedAccessList) {
    List<Map<String, String>> accessList = [];
    List<String> persons = encodedAccessList.split(',');

    for (String person in persons) {
      if (person.isEmpty) break;
      accessList.add({'person': person});
    }
    return accessList;
  }

  @override
  int compareTo(Session other) {
    return startTime.compareTo(other.startTime);
  }
}

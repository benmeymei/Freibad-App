import 'package:freibad_app/models/person.dart';

class Session implements Comparable<Session> {
  final Map<Person, String> participant;
  final DateTime start;
  final DateTime end;

  Session({this.participant, this.start, this.end});

  @override
  int compareTo(Session other) {
    return start.compareTo(other.start);
  }
}

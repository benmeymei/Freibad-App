import 'package:freibad_app/models/person.dart';

class Request {
  final List<Person> participant;
  final DateTime startTime;

  Request({this.participant, this.startTime});
}

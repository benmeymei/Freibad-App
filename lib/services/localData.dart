import 'package:freibad_app/models/person.dart';
import 'package:freibad_app/models/request.dart';
import 'package:freibad_app/models/session.dart';

class LocalData {

  List<Person> people;
  List<Session> sessions;

  Future<List<Person>> getPeople() {
    return null;
  }

  Future<List<Session>> getSessions() {
    return null;
  }

  Future<List<Request>> getRequests() {
    return null;
  }

}
import 'package:flutter/foundation.dart';
import 'package:freibad_app/models/person.dart';
import 'package:freibad_app/models/request.dart';
import 'package:freibad_app/models/session.dart';
import 'package:freibad_app/services/storage_service.dart';

class LocalData with ChangeNotifier {
  List<Person> _persons;
  List<Session> _sessions;
  List<Request> _requests;

  List<Person> get persons => [..._persons];
  List<Session> get sessions => [..._sessions];
  List<Request> get requests => [..._requests];

  FakeLocalStorage db =
      FakeLocalStorage(); //use LocalStorage for production, use FakeLocalStorage for testing

  Future<void> fetchAndSetData() async {
    _persons = await db.getPersons();
    _sessions = await db.getSessions();
    _requests = await db.getRequests();
    notifyListeners();
    print('fetching and setting data, finished');
  }

  Person findPersonById(String id) {
    return _persons.firstWhere((element) => element.id == id);
  }

  void addPerson(Person person) async {
    try {
      db.addPerson(person);
      _persons.add(person);
    } catch (exception) {
      print(exception);
      throw exception;
    }
  }

  void addSession(Session session) async {
    try {
      db.addSession(session);
      _sessions.add(session);
    } catch (exception) {
      print(exception);
      throw exception;
    }
  }

  void addRequest(Request request) async {
    try {
      db.addRequest(request);
      _requests.add(request);
    } catch (exception) {
      print(exception);
      throw exception;
    }
  }

  void deletePerson(String personId) {
    try {
      db.deletePerson(personId);
      _requests
          .removeAt(_requests.indexWhere((element) => element.id == personId));
    } catch (exception) {
      print(exception);
      throw exception;
    }
  }

  void deleteSession(String sessionId) {
    try {
      db.deleteSession(sessionId);
      _sessions
          .removeAt(_requests.indexWhere((element) => element.id == sessionId));
    } catch (exception) {
      print(exception);
      throw exception;
    }
  }

  void deleteRequest(String requestId) {
    try {
      db.deleteRequest(requestId);
      _requests
          .removeAt(_requests.indexWhere((element) => element.id == requestId));
    } catch (exception) {
      print(exception);
      throw exception;
    }
  }
}

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

  LocalStorage db =
      LocalStorage(); //use LocalStorage for production, use FakeLocalStorage for testing

  Future<void> fetchAndSetData() async {
    _persons = await db.getPersons();
    _sessions = await db.getSessions();
    _requests = await db.getRequests();
    notifyListeners();
  }
}

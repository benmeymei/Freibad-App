import 'package:freibad_app/models/person.dart';
import 'package:freibad_app/models/request.dart';
import 'package:freibad_app/models/session.dart';

abstract class StorageService {
  Future<List<Person>> getPersons();
  Future<List<Session>> getSessions();
  Future<List<Request>> getRequests();

  Future<void> addPerson(Person person);
  Future<void> addSession(Session session);
  Future<void> addRequest(Request request);

  Future<void> deletePerson(String personID);
  Future<void> deleteSession(String sessionID);
  Future<void> deleteRequest(String requestID);
}

class LocalStorage extends StorageService {
  Future<List<Person>> getPersons() {
    return null;
  }

  Future<List<Session>> getSessions() {
    return null;
  }

  Future<List<Request>> getRequests() {
    return null;
  }

  Future<void> addPerson(Person person) {
    return null;
  }

  Future<void> addSession(Session session) {
    return null;
  }

  Future<void> addRequest(Request request) {
    return null;
  }

  Future<void> deletePerson(String personID) {
    return null;
  }

  Future<void> deleteSession(String sessionID) {
    return null;
  }

  Future<void> deleteRequest(String requestID) {
    return null;
  }
}

class FakeLocalStorage extends StorageService {
  Future<List<Person>> getPersons() {
    return Future.value(TestData.persons);
  }

  Future<List<Session>> getSessions() {
    return Future.value(TestData.sessions);
  }

  Future<List<Request>> getRequests() {
    return Future.value(TestData.request);
  }

  Future<void> addPerson(Person person) {
    return Future.delayed(Duration(milliseconds: 100));
  }

  Future<void> addSession(Session session) {
    return Future.delayed(Duration(milliseconds: 100));
  }

  Future<void> addRequest(Request request) {
    return Future.delayed(Duration(milliseconds: 100));
  }

  Future<void> deletePerson(String personID) {
    return Future.delayed(Duration(milliseconds: 100));
  }

  Future<void> deleteSession(String sessionID) {
    return Future.delayed(Duration(milliseconds: 100));
  }

  Future<void> deleteRequest(String requestID) {
    return Future.delayed(Duration(milliseconds: 100));
  }
}

class TestData {
  static const AMOUNT_PERSONS = 2;
  static const AMOUNT_SESSIONS = 4;
  static const AMOUNT_REQUESTS = 4;

  static final List<Person> persons = [
    for (int i = 0; i < AMOUNT_PERSONS; i++)
      ...{
        Person(
          id: 'person$i',
          city: 'Musterstadt',
          email: 'muster@email.com',
          forename: 'Max$i',
          name: 'Mustermann$i',
          phoneNumber: '+0123456789',
          postCode: 12345,
          streeNumber: '',
          streetName: 'Musterstraße',
        )
      }.toList(),
  ];

  static final sessions = [
    for (int i = 0; i < AMOUNT_SESSIONS; i++)
      ...{
        Session(
          id: 'session$i',
          personsAndCodes: [
            {
              'person': 'person0',
              'code': 'QWERT$i',
            },
            if (i % 2 == 0)
              {
                'person': 'person1',
                'code': 'QWERTZ$i',
              },
          ],
          start: DateTime.now(),
          end: DateTime.now(),
        )
      }.toList(),
  ];

  static final request = [
    for (int i = 0; i < AMOUNT_REQUESTS; i++)
      ...{
        Request(
          id: 'request$i',
          persons: [
            'person0',
            if (i % 2 == 1) 'person1',
          ],
          startTime: DateTime.now(),
        )
      }.toList(),
  ];
}

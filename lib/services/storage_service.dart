import 'package:freibad_app/models/appointment.dart';
import 'package:freibad_app/models/person.dart';
import 'package:freibad_app/models/request.dart';

abstract class StorageService {
  Future<List<Person>> getPersons();
  Future<List<Appointment>> getAppointment();
  Future<List<Request>> getRequests();

  Future<void> addPerson(Person person);
  Future<void> updatePerson(Person person);
  Future<void> addAppointment(Appointment session);
  Future<void> addRequest(Request request);

  Future<void> deletePerson(String personID);
  Future<void> deleteAppointment(String appointmentID);
  Future<void> deleteRequest(String requestID);
}

class LocalStorage extends StorageService {
  Future<List<Person>> getPersons() {
    return null;
  }

  Future<List<Appointment>> getAppointment() {
    return null;
  }

  Future<List<Request>> getRequests() {
    return null;
  }

  Future<void> addPerson(Person person) {
    return null;
  }

  Future<void> updatePerson(Person person) {
    return null;
  }

  Future<void> addAppointment(Appointment session) {
    return null;
  }

  Future<void> addRequest(Request request) {
    return null;
  }

  Future<void> deletePerson(String personID) {
    return null;
  }

  Future<void> deleteAppointment(String appointmentID) {
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

  Future<List<Appointment>> getAppointment() {
    return Future.value(TestData.appointment);
  }

  Future<List<Request>> getRequests() {
    return Future.value(TestData.request);
  } 

  Future<void> addPerson(Person person) {
    return Future.delayed(Duration(milliseconds: 100));
  }

  Future<void> updatePerson(Person person) {
    return Future.delayed(Duration(milliseconds: 100));
  }

  Future<void> addAppointment(Appointment appointment) {
    return Future.delayed(Duration(milliseconds: 100));
  }

  Future<void> addRequest(Request request) {
    return Future.delayed(Duration(milliseconds: 100));
  }

  Future<void> deletePerson(String personID) {
    return Future.delayed(Duration(milliseconds: 100));
  }

  Future<void> deleteAppointment(String appointmentID) {
    return Future.delayed(Duration(milliseconds: 100));
  }

  Future<void> deleteRequest(String requestID) {
    return Future.delayed(Duration(milliseconds: 100));
  }
}

class TestData {
  static const AMOUNT_PERSONS = 5;
  static const AMOUNT_APPOINTMENTS = 6;
  static const AMOUNT_REQUESTS = 6;

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
          streetNumber: '$i',
          streetName: 'Musterstraße',
        )
      }.toList(),
  ];

  static final appointment = [
    for (int i = 0; i < AMOUNT_APPOINTMENTS; i++)
      ...{
        Appointment(
          id: 'session$i',
          accessList: [
            {
              'person': 'person0',
              'code': 'code$i',
            },
            if (i % 2 == 0)
              {
                'person': 'person1',
                'code': 'code$i',
              },
          ],
          startTime: DateTime.now(),
          endTime: DateTime.now(),
        )
      }.toList(),
  ];

  static final request = [
    for (int i = 0; i < AMOUNT_REQUESTS; i++)
      ...{
        Request(
          id: 'request$i',
          hasFailed: (i % 2 == 1),
          accessList: [
            {
              'person': 'person0',
            },
            if (i % 2 == 1)
              {
                'person': 'person1',
              },
          ],
          startTime: DateTime.now(),
          endTime: DateTime.now(),
        )
      }.toList(),
  ];
}

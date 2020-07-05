import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:freibad_app/models/appointment.dart';
import 'package:freibad_app/models/person.dart';
import 'package:freibad_app/models/request.dart';
import 'package:freibad_app/models/session.dart';
import 'package:freibad_app/services/storage_service.dart';
import 'package:uuid/uuid.dart';

class LocalData with ChangeNotifier {
  List<Person> _persons;
  List<Session> _appointments;
  List<Request> _requests;

  List<Person> get persons => [..._persons];
  List<Session> get appointments => [..._appointments];
  List<Request> get requests => [..._requests];

  FakeLocalStorage db =
      FakeLocalStorage(); //use LocalStorage for production, use FakeLocalStorage for testing

  Uuid uuid = Uuid(); // for creating unique ids

  Future<void> fetchAndSetData() async {
    _persons = await db.getPersons();
    _appointments = await db.getAppointment();
    _requests = await db.getRequests();
    notifyListeners();
  }

  Person findPersonById(String id) {
    return _persons.firstWhere((element) => element.id == id);
  }

  void addPerson({
    @required String forename,
    @required String name,
    @required String streetName,
    @required String streetNumber,
    @required int postCode,
    @required String city,
    @required String phoneNumber,
    @required String email,
  }) async {
    Person person = Person(
        id: uuid.v1(),
        forename: forename,
        name: name,
        streetName: streetName,
        streetNumber: streetNumber,
        postCode: postCode,
        city: city,
        phoneNumber: phoneNumber,
        email: email);

    try {
      db.addPerson(person);
      _persons.add(person);
      developer.log('added person');
    } catch (exception) {
      print(exception);
      throw exception;
    }
    notifyListeners();
  }

  void updatePerson({
    @required String id,
    String forename,
    String name,
    String streetName,
    String streetNumber,
    int postCode,
    String city,
    String phoneNumber,
    String email,
  }) async {
    Person currentPerson = findPersonById(id);
    Person updatedPerson = Person(
      id: id,
      forename: forename ?? currentPerson.forename,
      name: name ?? currentPerson.name,
      streetName: streetName ?? currentPerson.streetName,
      streetNumber: streetNumber ?? currentPerson.streetNumber,
      postCode: postCode ?? currentPerson.postCode,
      city: city ?? currentPerson.city,
      phoneNumber: phoneNumber ?? currentPerson.phoneNumber,
      email: email ?? currentPerson.email,
    );
    try {
      db.updatePerson(updatedPerson);
      int pos = _persons.indexWhere((element) => element.id == id);
      _persons.replaceRange(pos, pos + 1, [updatedPerson]);
      developer.log('updated person');
    } catch (exception) {
      developer.log(exception);
      throw exception;
    }
    notifyListeners();
  }

  void addAppointment({
    @required List<Map<String, String>> accessList,
    @required DateTime startTime,
    @required DateTime endTime,
  }) async {
    Appointment appointment = Appointment(
      id: uuid.v1(),
      accessList: accessList,
      startTime: startTime,
      endTime: endTime,
    );
    try {
      db.addAppointment(appointment);
      _appointments.add(appointment);
      developer.log('added appointment');
    } catch (exception) {
      developer.log(exception);
      throw exception;
    }
    notifyListeners();
  }

  void addRequest({
    @required List<Map<String, String>> accessList,
    @required DateTime startTime,
    @required DateTime endTime,
  }) async {
    Request request = Request(
        id: uuid.v1(),
        accessList: accessList,
        startTime: startTime,
        endTime: endTime,
        hasFailed: false);
    try {
      db.addRequest(request);
      _requests.add(request);
      developer.log('added request');
    } catch (exception) {
      developer.log(exception);
      throw exception;
    }
    notifyListeners();
  }

  void deletePerson(String personId) {
    try {
      db.deletePerson(personId);
      _persons
          .removeAt(_persons.indexWhere((element) => element.id == personId));
      developer.log('deleted person');
    } catch (exception) {
      developer.log(exception);
      throw exception;
    }
    notifyListeners();
  }

  void deleteSession(Session session) {
    try {
      if (session is Appointment) {
        deleteAppointment(session.id);
      } else if (session is Request) {
        deleteRequest(session.id);
      } else {
        throw 'Add support to the Database for the children of Sessions';
      }
    } catch (exception) {
      developer.log(exception);
      throw exception;
    }
    notifyListeners();
  }

  void deleteAppointment(String appointmentId) {
    //TODO unsubscribe from Website
    try {
      db.deleteAppointment(appointmentId);
      _appointments.removeAt(
          _appointments.indexWhere((element) => element.id == appointmentId));
      developer.log('deleted appointment');
    } catch (exception) {
      developer.log(exception);
      throw exception;
    }
    notifyListeners();
  }

  void deleteRequest(String requestId) {
    try {
      db.deleteRequest(requestId);
      _requests
          .removeAt(_requests.indexWhere((element) => element.id == requestId));
      developer.log('deleted request');
    } catch (exception) {
      developer.log(exception);
      throw exception;
    }
    notifyListeners();
  }
}

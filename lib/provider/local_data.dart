import 'package:flutter/foundation.dart';
import 'package:freibad_app/models/appointment.dart';
import 'package:freibad_app/models/person.dart';
import 'package:freibad_app/models/request.dart';
import 'package:freibad_app/models/session.dart';
import 'package:freibad_app/services/storage_service.dart';

class LocalData with ChangeNotifier {
  List<Person> _persons;
  List<Session> _appointments;
  List<Request> _requests;

  List<Person> get persons => [..._persons];
  List<Session> get appointments => [..._appointments];
  List<Request> get requests => [..._requests];

  FakeLocalStorage db =
      FakeLocalStorage(); //use LocalStorage for production, use FakeLocalStorage for testing

  Future<void> fetchAndSetData() async {
    _persons = await db.getPersons();
    _appointments = await db.getAppointment();
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
      print('added person');
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
    Person currPers = findPersonById(id);
    Person newPers = Person(
      id: id,
      forename: forename ?? currPers.forename,
      name: name ?? currPers.name,
      streetName: streetName ?? currPers.streetName,
      streetNumber: streetNumber ?? currPers.streetNumber,
      postCode: postCode ?? currPers.postCode,
      city: city ?? currPers.city,
      phoneNumber: phoneNumber ?? currPers.phoneNumber,
      email: email ?? currPers.email,
    );
    try {
      db.updatePerson(newPers);
      int pos = _persons.indexWhere((element) => element.id == id);
      _persons.replaceRange(pos, pos + 1, [newPers]);
      print('updated person');
    } catch (exception) {
      print(exception);
      throw exception;
    }
    notifyListeners();
  }

  void addAppointment(Appointment appointment) async {
    try {
      db.addAppointment(appointment);
      _appointments.add(appointment);
      print('added appointment');
    } catch (exception) {
      print(exception);
      throw exception;
    }
    notifyListeners();
  }

  void addRequest(Request request) async {
    try {
      db.addRequest(request);
      _requests.add(request);
      print('added request');
    } catch (exception) {
      print(exception);
      throw exception;
    }
    notifyListeners();
  }

  void deletePerson(String personId) {
    try {
      db.deletePerson(personId);
      _persons
          .removeAt(_persons.indexWhere((element) => element.id == personId));
      print('deleted person');
    } catch (exception) {
      print(exception);
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
      print(exception);
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
      print('deleted appointment');
    } catch (exception) {
      print(exception);
      throw exception;
    }
    notifyListeners();
  }

  void deleteRequest(String requestId) {
    try {
      db.deleteRequest(requestId);
      _requests
          .removeAt(_requests.indexWhere((element) => element.id == requestId));
      print('deleted request');
    } catch (exception) {
      print(exception);
      throw exception;
    }
    notifyListeners();
  }
}

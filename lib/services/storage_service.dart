import 'package:freibad_app/models/session.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

import 'package:freibad_app/models/appointment.dart';
import 'package:freibad_app/models/person.dart';
import 'package:freibad_app/models/request.dart';

abstract class StorageService {
  Future<void> setUpDB();

  Future<List<Person>> getPersons();
  Future<List<Appointment>> getAppointment();
  Future<List<Request>> getRequests();

  Future<void> addPerson(Person person);
  Future<void> updatePerson(Person person);
  Future<void> addSession(Session session);
  Future<void> updateRequest(Request request);

  Future<void> deletePerson(String personID);
  Future<void> deleteAppointment(String appointmentID);
  Future<void> deleteRequest(String requestID);
}

class LocalStorage extends StorageService {
  Future<Database> database;

  Future<void> setUpDB() async {
    database = openDatabase(path.join(await getDatabasesPath(), 'access.db'),
        onCreate: (db, version) {
      Future<void> createPersonsTable = db.execute(
        "CREATE TABLE persons(id TEXT PRIMARY KEY, forename TEXT, name TEXT, streetName TEXT, streetNumber TEXT, postCode INTEGER, city TEXT, phoneNumber TEXT, email TEXT)",
      );
      Future<void> createAppointmentsTable = db.execute(
        "CREATE TABLE appointments(id TEXT PRIMARY KEY, startTime TEXT, endTime TEXT, location TEXT)",
      );
      Future<void> createRequestsTable = db.execute(
        "CREATE TABLE requests(id TEXT PRIMARY KEY, startTime TEXT, endTime TEXT, accessList TEXT, hasFailed INTEGER, location TEXT)",
      );
      Future<void> createAccessTable = db.execute(
        "CREATE TABLE access(sessionId TEXT, person TEXT, accessCode TEXT, PRIMARY KEY(sessionId, person))",
      );
      return Future.wait([
        createPersonsTable,
        createAppointmentsTable,
        createRequestsTable,
        createAccessTable
      ]);
    }, version: 1);
  }

  Future<List<Person>> getPersons() async {
    final Database db = await database;
    final List<Map<String, dynamic>> content = await db.query('persons');
    return List.generate(content.length, (i) {
      return Person(
          id: content[i]['id'],
          forename: content[i]['forename'],
          name: content[i]['name'],
          streetName: content[i]['streetName'],
          streetNumber: content[i]['streetNumber'],
          postcode: content[i]['postCode'],
          city: content[i]['city'],
          phoneNumber: content[i]['phoneNumber'],
          email: content[i]['email']);
    });
  }

  Future<List<Map<String, String>>> _getAccessList(String sessionId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> content = await db.query(
      'access',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
    );
    return List.generate(
        content.length,
        (i) => {
              'person': content[i]["person"],
              'code': content[i]["code"],
            });
  }

  Future<List<Appointment>> getAppointment() async {
    final Database db = await database;
    final List<Map<String, dynamic>> content = await db.query('appointments');

    return [
      for (int i = 0; i < content.length; i++)
        ...{
          Appointment(
            id: content[i]['id'],
            accessList: await _getAccessList(content[i]['id']),
            startTime: DateTime.parse(content[i]['startTime']),
            endTime: DateTime.parse(content[i]['endTime']),
            location: content[i]['location'],
          )
        }.toList()
    ];
  }

  Future<List<Request>> getRequests() async {
    final Database db = await database;
    final List<Map<String, dynamic>> content = await db.query('requests');

    return [
      for (int i = 0; i < content.length; i++)
        ...{
          Request(
            id: content[i]['id'],
            accessList: await _getAccessList(content[i]['id']),
            startTime: DateTime.parse(content[i]['startTime']),
            endTime: DateTime.parse(content[i]['endTime']),
            hasFailed: content[i]['hasFailed'] == 0,
            location: content[i]['location'],
          ) //0 == TRUE
        }.toList()
    ];
  }

  Future<void> addPerson(Person person) async {
    final Database db = await database;
    db.insert('persons', person.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updatePerson(Person person) async {
    final db = await database;
    await db.update(
      'persons',
      person.toMap(),
      where: "id = ?",
      whereArgs: [person.id],
    );
  }

  Future<void> _addAccess(
      List<Map<String, String>> accessList, String sessionId) async {
    final Database db = await database;
    for (int i = 0; i < accessList.length; i++) {
      Map<String, String> accessItem = accessList[i];
      accessItem.putIfAbsent("sessionId", () => sessionId);
      db.insert('access', accessItem,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> addSession(Session session) async {
    //add accessList to DB
    _addAccess(session.accessList, session.id);

    if (session is Request) {
      return _addRequest(session);
    } else if (session is Appointment) {
      return _addAppointment(session);
    } else {
      throw 'unknown children of session with the runtime type: ${session.runtimeType}';
    }
  }

  Future<void> _addAppointment(Appointment appointment) async {
    final Database db = await database;
    db.insert('appointments', appointment.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> _addRequest(Request request) async {
    final Database db = await database;
    await db.insert('requests', request.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateRequest(Request request) async {
    final db = await database;
    await db.update(
      'requests',
      request.toMap(),
      where: "id = ?",
      whereArgs: [request.id],
    );

    //updating of access not optimized
    await _deleteAccess(request.id);
    await _addAccess(request.accessList, request.id);
  }

  Future<void> deletePerson(String personID) async {
    final db = await database;

    await db.delete(
      'persons',
      where: "id = ?",
      whereArgs: [personID],
    );
  }

  Future<void> _deleteAccess(sessionId) async {
    final db = await database;
    await db.delete(
      'access',
      where: "sessionId = ?",
      whereArgs: [sessionId],
    );
  }

  Future<void> deleteAppointment(String appointmentID) async {
    final db = await database;
    await _deleteAccess(appointmentID);
    await db.delete(
      'appointments',
      where: "id = ?",
      whereArgs: [appointmentID],
    );
  }

  Future<void> deleteRequest(String requestID) async {
    final db = await database;
    await _deleteAccess(requestID);
    await db.delete(
      'requests',
      where: "id = ?",
      whereArgs: [requestID],
    );
  }
}

class FakeLocalStorage extends StorageService {
  Future<void> setUpDB() {
    return Future.delayed(Duration(milliseconds: 1));
  }

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
    return Future.delayed(Duration(milliseconds: 1));
  }

  Future<void> updatePerson(Person person) {
    return Future.delayed(Duration(milliseconds: 1));
  }

  Future<void> addSession(Session session) {
    return Future.delayed(Duration(milliseconds: 1));
  }

  Future<void> updateRequest(Request request) {
    return Future.delayed(Duration(milliseconds: 1));
  }

  Future<void> deletePerson(String personID) {
    return Future.delayed(Duration(milliseconds: 1));
  }

  Future<void> deleteAppointment(String appointmentID) {
    return Future.delayed(Duration(milliseconds: 1));
  }

  Future<void> deleteRequest(String requestID) {
    return Future.delayed(Duration(milliseconds: 1));
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
          postcode: 12345,
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
            location: "TEST_LOCATION")
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
            location: "TEST_LOCATION")
      }.toList(),
  ];
}

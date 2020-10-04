import 'dart:convert';
import 'package:freibad_app/models/appointment.dart';
import 'package:freibad_app/models/person.dart';
import 'package:freibad_app/models/request.dart';
import 'package:freibad_app/models/session.dart';
import 'package:freibad_app/services/api_keys.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

abstract class ReserveAPI {
  static Future<List<List<DateTime>>> availableTimeBlocks(
      DateTime date, String location) {
    //could be advanced with more conditions (like local holidays), for that reason placed in API_SERVICE

    String formattedDate = DateFormat('EEEEE').format(date);

    if (formattedDate == 'Saturday' || formattedDate == 'Sunday') {
      return Future.value([
        [addHour(date, 8), addHour(date, 13, minutes: 30)],
        [addHour(date, 14, minutes: 30), addHour(date, 20)],
      ]);
    } else {
      return Future.value([
        [addHour(date, 6), addHour(date, 9)],
        [addHour(date, 10), addHour(date, 16)],
        [addHour(date, 17), addHour(date, 20)],
      ]);
    }
  }

  static Future<List<String>> availableLocations() {
    return Future.value([
      'Strandbad Lörick',
      'Freibad Rheinbad',
      'Freibad Allwetterbad Flingern',
      'Freizeitbad Düsselstrand',
      '33-Meter Schwimmhalle Rheinbad',
      'Familienbad Niederheid',
    ]);
  }

  //Helper function
  static DateTime addHour(DateTime date, int hours, {int minutes = 0}) {
    DateTime tempDate =
        DateTime(date.year, date.month, date.day, hours, minutes);
    tempDate.add(Duration(hours: hours, minutes: minutes));
    return tempDate;
  }
}

class ReserveAPIService extends ReserveAPI {
  static String baseUrl = APIKeys.BaseURL;
  //static const baseUrl = "http://192.168.2.125:5000";

  static Future<bool> addUser(Person user) async {
    String url =
        '$baseUrl/user/${user.id}?forename=${user.forename}&name=${user.name}&adress=${user.streetName} ${user.streetNumber}&postcode=${user.postcode}&city=${user.city}&phone=${user.phoneNumber}&email=${user.email}';
    try {
      final addUserResponse = await http.post(
        url,
        headers: {
          //'apikey': APIKeys.ReserveAPI,
        },
      );
      developer.log(
          'user post request to the Reserve API finished, Statuscode: ${addUserResponse.statusCode}');
      if (addUserResponse.statusCode == 201) {
        developer.log('added user on the server');
        return true;
      } else {
        throw Exception(
            'Something went wrong calling the Reserve API, Error reason phrase: ${addUserResponse.reasonPhrase}');
      }
    } catch (exception) {
      developer.log("Error on calling the Reserve API", error: exception);

      return false;
    }
  }

  static Future<bool> updateUser(Person user) async {
    String url =
        '$baseUrl/user/${user.id}?forename=${user.forename}&name=${user.name}&adress=${user.streetName}${user.streetNumber}&postcode=${user.postcode}&city=${user.city}&phone=${user.phoneNumber}&email=${user.email}';

    try {
      final updateUserResponse = await http.put(
        url,
        headers: {
          //'apikey': APIKeys.ReserveAPI,
        },
      );
      developer.log(
          'user edit request to the Reserve API finished, Statuscode: ${updateUserResponse.statusCode}');
      if (updateUserResponse.statusCode == 204) {
        developer.log('edited user');
        return true;
      } else {
        throw Exception(
            'Something went wrong calling the Reserve API, Error: ${updateUserResponse.reasonPhrase}');
      }
    } catch (exception) {
      developer.log('Error on calling the Reserve API', error: exception);
      return false;
    }
  }

  static Future<Session> makeReservation(Request request) async {
    String members = '';

    for (Map<String, String> member in request.accessList)
      members += '&members=${member['person']}';

    String url =
        '$baseUrl/session/${request.id}?startTime=${request.startTime.toIso8601String()}&endTime=${request.endTime.toIso8601String()}&pool=Strandbad Lörick$members';

    try {
      final addSessionResponse = await http.post(
        url,
        headers: {
          //'apikey': APIKeys.ReserveAPI,
        },
      );
      developer.log(
          'request post request to the Reserve API finished, Statuscode: ${addSessionResponse.statusCode}');
      if (addSessionResponse.statusCode == 201) {
        Session resultSession = jsonToSession(addSessionResponse.body);
        return resultSession;
      } else {
        throw Exception(
            'Something went wrong calling the Reserve API, Error: ${addSessionResponse.reasonPhrase}');
      }
    } catch (exception) {
      developer.log('Error on calling the Reserve API', error: exception);
      throw exception;
    }
  }

  static Future<Session> getReservation(String sessionId) async {
    String url = '$baseUrl/session/$sessionId';

    try {
      final addSessionResponse = await http.get(
        url,
        headers: {
          //'apikey': APIKeys.ReserveAPI,
        },
      );
      developer.log(
          'session get request to the Reserve API finished, Statuscode: ${addSessionResponse.statusCode}');
      if (addSessionResponse.statusCode == 200) {
        Session resultSession = jsonToSession(addSessionResponse.body);
        return resultSession;
      } else {
        throw Exception(
            'Something went wrong calling the Reserve API, Error: ${addSessionResponse.reasonPhrase}');
      }
    } catch (exception) {
      developer.log('Error on calling the Reserve API', error: exception);
      throw exception;
    }
  }

  static Future<bool> deleteReservation(String appointmentId) async {
    String url = '$baseUrl/session/$appointmentId';

    try {
      final addSessionResponse = await http.delete(
        url,
        headers: {
          //'apikey': APIKeys.ReserveAPI,
        },
      );
      developer.log(
          'session delete request to the Reserve API finished, Statuscode: ${addSessionResponse.statusCode}');
      if (addSessionResponse.statusCode == 204) {
        return true;
      } else if (addSessionResponse.statusCode == 404) {
        developer.log(
            "session could not be found on the server. Proceeding with deletion.");
        return true;
      } else {
        throw Exception(
            'Something went wrong calling the Reserve API, Error: ${addSessionResponse.reasonPhrase}');
      }
    } catch (exception) {
      developer.log('Error on calling the Reserve API', error: exception);
      return false;
    }
  }

  static Session jsonToSession(String jsonResponse) {
    Map<String, dynamic> decodedResponse = jsonDecode(jsonResponse);

    String sessionId = decodedResponse['sessionId'];
    DateTime startTime = DateTime.parse(decodedResponse['startTime']);
    DateTime endTime = DateTime.parse(decodedResponse['endTime']);
    String location = decodedResponse['pool'];
    int status = decodedResponse['status'];
    List<dynamic> members = decodedResponse['members'];

    if (status > 0) {
      //Request successful
      List<Map<String, String>> accessList = [];
      for (Map<dynamic, dynamic> member in members) {
        developer.log('$member');
        accessList
            .add({'person': member['userId'], 'code': member['entryCode']});
      }
      return Appointment(
        id: sessionId,
        accessList: accessList,
        startTime: startTime,
        endTime: endTime,
        location: location,
      );
    } else {
      //0 request is pending, negative request unsuccessful
      List<Map<String, String>> accessList = [];
      for (Map<dynamic, dynamic> member in members) {
        accessList.add({'person': member['userId']});
      }
      bool hasFailed = status < 0;
      return Request(
          id: sessionId,
          accessList: accessList,
          startTime: startTime,
          endTime: endTime,
          hasFailed: hasFailed,
          location: location);
    }
  }

  static Future<List<String>> availableLocations() {
    return ReserveAPI.availableLocations();
  }

  static Future<List<List<DateTime>>> availableTimeBlocks(
      DateTime date, String location) {
    return ReserveAPI.availableTimeBlocks(date, location);
  }
}

class FakeReserveAPIService extends ReserveAPI {
  static Future<bool> addUser(Person user) {
    return Future.delayed(Duration(milliseconds: 1), () => true);
  }

  static Future<bool> editUser(Person user) {
    return Future.delayed(Duration(milliseconds: 1), () => true);
  }

  static Future<Session> makeReservation(Session session) {
    return Future.delayed(Duration(milliseconds: 1), () => session);
  }

  static Future<Session> getReservation(String sessionId) {
    return Future.delayed(
      Duration(seconds: 5),
      () => Appointment(
          id: sessionId,
          accessList: [
            {'person0': 'TEST'}
          ],
          startTime: DateTime.now(),
          endTime: DateTime.now().add(
            Duration(hours: 1),
          ),
          location: 'TEST_LOCATION'),
    );
  }

  static Future<bool> deleteReservation(String sessionId) {
    return Future.delayed(Duration(milliseconds: 1), () => true);
  }

  static Future<List<String>> availableLocations() {
    return ReserveAPI.availableLocations();
  }

  static Future<List<List<DateTime>>> availableTimeBlocks(
      DateTime date, String location) {
    return ReserveAPI.availableTimeBlocks(date, location);
  }
}

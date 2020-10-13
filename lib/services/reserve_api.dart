import 'dart:convert';
import 'package:freibad_app/models/appointment.dart';
import 'package:freibad_app/models/httpException.dart';
import 'package:freibad_app/models/person.dart';
import 'package:freibad_app/models/request.dart';
import 'package:freibad_app/models/session.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

abstract class ReserveAPI {
  static Future<List<Map<String, dynamic>>> availableTimeBlocks() async {
    //could be advanced with more conditions (like local holidays), for that reason placed in API_SERVICE
    List<Map<String, dynamic>> result = [];
    List<Map<String, String>> locations = await availableLocations();

    for (int i = 0; i < locations.length; i++) {
      for (int j = 1; j <= 7; j++) {
        result.add({
          "locationId": i.toString(),
          "isoWeekday": j,
          "startMinute": 450,
          "endMinute": 540
        });
        result.add({
          "locationId": i.toString(),
          "isoWeekday": j,
          "startMinute": 600,
          "endMinute": 960
        });
        result.add({
          "locationId": i.toString(),
          "isoWeekday": j,
          "startMinute": 1020,
          "endMinute": 1200
        });
      }
    }
    return Future.value(result);
  }

  static Future<List<Map<String, String>>> availableLocations() {
    return Future.value([
      {'name': 'Strandbad Lörick', 'locationId': '1'},
      {'name': 'Freibad Rheinbad', 'locationId': '2'},
      {'name': 'Freibad Allwetterbad Flingern', 'locationId': '3'},
      {'name': 'Freizeitbad Düsselstrand', 'locationId': '4'},
      {'name': '33-Meter Schwimmhalle Rheinbad', 'locationId': '5'},
      {'name': 'Familienbad Niederheid', 'locationId': '6'},
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
  //static String baseUrl = APIKeys.BaseURL;
  static const baseUrl = 'http://10.0.2.2:5000';
  //static const baseUrl = "http://192.168.2.125:5000";

  static Future<bool> registerUser(String name, String password) async {
    String url = '$baseUrl/register?name=$name&password=$password';
    try {
      final registerUserResponse = await http.post(url);
      developer.log(
          'user post request to the Reserve API finished, Statuscode: ${registerUserResponse.statusCode}');
      if (registerUserResponse.statusCode == 201) {
        developer.log('added user to the server');
        return true;
      } else if (registerUserResponse.statusCode == 409) {
        developer.log('user name already exists');
        throw HttpException('user name already exists');
      } else {
        throw HttpException(
            'Something went wrong calling the Reserve API, Error reason phrase: ${registerUserResponse.reasonPhrase}');
      }
    } catch (exception) {
      developer.log('Error on calling the Reserve API', error: exception);
      throw exception;
    }
  }

  static Future<String> loginUser(String name, String password) async {
    String url = '$baseUrl/login';
    String basicAuth = 'Basic ' + base64Encode(utf8.encode('$name:$password'));
    try {
      final loginUserResponse =
          await http.get(url, headers: {'authorization': basicAuth});
      developer.log(
          'user login request to the Reserve API finished, Statuscode: ${loginUserResponse.statusCode}');
      if (loginUserResponse.statusCode == 200) {
        developer.log('got token from the server');
        Map<String, dynamic> decodedResponse =
            jsonDecode(loginUserResponse.body);

        String token = decodedResponse['token'];
        developer.log("login successful, token is: $token");
        return token;
      } else if (loginUserResponse.statusCode == 401) {
        developer.log('password is wrong');
        throw HttpException('Password is wrong');
      } else if (loginUserResponse.statusCode == 404) {
        developer.log('user does not exist');
        throw HttpException('user does not exist');
      } else {
        throw HttpException(
            'Something went wrong calling the Reserve API, Error reason phrase: ${loginUserResponse.reasonPhrase}');
      }
    } catch (exception) {
      developer.log('Error on calling the Reserve API', error: exception);
      throw exception;
    }
  }

  static Future<bool> addPerson(Person person, String token) async {
    String url =
        '$baseUrl/person/${person.id}?forename=${person.forename}&name=${person.name}&adress=${person.streetName} ${person.streetNumber}&postcode=${person.postcode}&city=${person.city}&phone=${person.phoneNumber}&email=${person.email}';
    try {
      final addPersonResponse = await http.post(
        url,
        headers: {'access-token': token},
      );
      developer.log(
          'person post request to the Reserve API finished, Statuscode: ${addPersonResponse.statusCode}');
      if (addPersonResponse.statusCode == 201) {
        developer.log('added person on the server');
        return true;
      } else {
        throw Exception(
            'Something went wrong calling the Reserve API, Error reason phrase: ${addPersonResponse.reasonPhrase}');
      }
    } catch (exception) {
      developer.log('Error on calling the Reserve API', error: exception);

      return false;
    }
  }

  static Future<bool> updatePerson(Person person, String token) async {
    String url =
        '$baseUrl/person/${person.id}?forename=${person.forename}&name=${person.name}&adress=${person.streetName}${person.streetNumber}&postcode=${person.postcode}&city=${person.city}&phone=${person.phoneNumber}&email=${person.email}';

    try {
      final updatePersonResponse = await http.put(
        url,
        headers: {'access-token': token},
      );
      developer.log(
          'person edit request to the Reserve API finished, Statuscode: ${updatePersonResponse.statusCode}');
      if (updatePersonResponse.statusCode == 204) {
        developer.log('edited person');
        return true;
      } else {
        throw Exception(
            'Something went wrong calling the Reserve API, Error: ${updatePersonResponse.reasonPhrase}');
      }
    } catch (exception) {
      developer.log('Error on calling the Reserve API', error: exception);
      return false;
    }
  }

  static Future<Session> makeReservation(
      Request request, String locationId, String token) async {
    String members = '';

    for (Map<String, String> member in request.accessList)
      members += '&members=${member['person']}';

    String url =
        '$baseUrl/session/${request.id}?startTime=${request.startTime.toIso8601String()}&endTime=${request.endTime.toIso8601String()}&locationId=$locationId$members';

    try {
      final addSessionResponse = await http.post(
        url,
        headers: {'access-token': token},
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

  static Future<Session> getReservation(String sessionId, String token) async {
    String url = '$baseUrl/session/$sessionId';

    try {
      final addSessionResponse = await http.get(
        url,
        headers: {'access-token': token},
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

  static Future<bool> deleteReservation(
      String appointmentId, String token) async {
    String url = '$baseUrl/session/$appointmentId';

    try {
      final addSessionResponse = await http.delete(
        url,
        headers: {'access-token': token},
      );
      developer.log(
          'session delete request to the Reserve API finished, Statuscode: ${addSessionResponse.statusCode}');
      if (addSessionResponse.statusCode == 204) {
        return true;
      } else if (addSessionResponse.statusCode == 404) {
        developer.log(
            'session could not be found on the server. Proceeding with deletion.');
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
    int status = decodedResponse['status'];
    List<dynamic> members = decodedResponse['members'];

    Map<String, dynamic> locationData = decodedResponse['location'];
    String location = locationData['name'];

    if (status > 0) {
      //Request successful
      List<Map<String, String>> accessList = [];
      for (Map<dynamic, dynamic> member in members) {
        developer.log('$member');
        accessList
            .add({'person': member['personId'], 'code': member['entryCode']});
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
        accessList.add({'person': member['personId']});
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

  static Future<List<Map<String, String>>> availableLocations(
      String token) async {
    String url = '$baseUrl/locations';

    List<Map<String, String>> response = [];

    try {
      final getLocations = await http.get(
        url,
        headers: {'access-token': token},
      );
      developer.log(
          'locations get request to the Reserve API finished, Statuscode: ${getLocations.statusCode}');
      if (getLocations.statusCode == 200) {
        List<dynamic> locations = json.decode(getLocations.body);

        for (Map<String, dynamic> location in locations) {
          response.add({
            'name': location['name'].toString(),
            'locationId': location['locationId'].toString(),
          });
        }

        return response;
      } else {
        throw Exception(
            'Something went wrong calling the Reserve API, Error: ${getLocations.reasonPhrase}');
      }
    } catch (exception) {
      developer.log('Error on calling the Reserve API', error: exception);
      throw exception;
    }
  }

  static Future<List<Map<String, dynamic>>> availableTimeBlocks(
      String token) async {
    String url = '$baseUrl/openingHours';

    List<Map<String, dynamic>> response = [];

    try {
      final getOpeningHours = await http.get(
        url,
        headers: {'access-token': token},
      );
      developer.log(
          'opening hours get request to the Reserve API finished, Statuscode: ${getOpeningHours.statusCode}');
      if (getOpeningHours.statusCode == 200) {
        List<dynamic> openingHours = json.decode(getOpeningHours.body);

        for (Map<String, dynamic> openingHour in openingHours) {
          response.add(openingHour);
        }

        return response;
      } else {
        throw Exception(
            'Something went wrong calling the Reserve API, Error: ${getOpeningHours.reasonPhrase}');
      }
    } catch (exception) {
      developer.log('Error on calling the Reserve API', error: exception);
      throw exception;
    }
  }
}

class FakeReserveAPIService extends ReserveAPI {
  static Future<bool> registerUser(String name, String password) {
    return Future.delayed(Duration(milliseconds: 1), () => true);
  }

  static Future<String> loginUser(String name, String password) {
    return Future.delayed(Duration(milliseconds: 1), () => "Test_Token");
  }

  static Future<bool> addPerson(Person person, String token) {
    return Future.delayed(Duration(milliseconds: 1), () => true);
  }

  static Future<bool> editPerson(Person user, String token) {
    return Future.delayed(Duration(milliseconds: 1), () => true);
  }

  static Future<Session> makeReservation(
      Session session, String locationId, String token) {
    return Future.delayed(Duration(milliseconds: 1), () => session);
  }

  static Future<Session> getReservation(String sessionId, String token) {
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

  static Future<bool> deleteReservation(String sessionId, String token) {
    return Future.delayed(Duration(milliseconds: 1), () => true);
  }

  static Future<List<Map<String, String>>> availableLocations(String token) {
    return ReserveAPI.availableLocations();
  }

  static Future<List<Map<String, dynamic>>> availableTimeBlocks(String token) {
    return ReserveAPI.availableTimeBlocks();
  }
}

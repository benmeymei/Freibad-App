import 'package:freibad_app/models/person.dart';
import 'package:freibad_app/models/request.dart';
import 'package:freibad_app/models/session.dart';
import 'package:freibad_app/services/reserve_api.dart';
import 'package:freibad_app/services/weather_api.dart';

abstract class API {}

class APIService extends API {
  static Future<List<Map<String, dynamic>>> fetchWeather(
    double requestLocationLat,
    double requestLocationLon,
  ) async {
    return WeatherAPIService.fetchWeather(
        requestLocationLat, requestLocationLon);
  }

  static Future<bool> addPerson(Person person) {
    try {
      return ReserveAPIService.addUser(person);
    } catch (exception) {
      throw exception;
    }
  }

  static Future<bool> editPerson(Person person) {
    try {
      return ReserveAPIService.updateUser(person);
    } catch (exception) {
      throw exception;
    }
  }

  static Future<Session> makeReservation(Request session) {
    return ReserveAPIService.makeReservation(session);
  }

  static Future<Session> getReservation(String sessionId) {
    return ReserveAPIService.getReservation(sessionId);
  }

  static Future<bool> deleteReservation(String sessionId) {
    return ReserveAPIService.deleteReservation(sessionId);
  }

  static List<List<DateTime>> availableTimeBlocks(DateTime date) {
    return ReserveAPIService.availableTimeBlocks(date);
  }
}

class FakeAPIService extends API {
  static Future<List<Map<String, dynamic>>> fetchWeather(
    double requestLocationLat,
    double requestLocationLon,
  ) async {
    print(await FakeWeatherAPIService.fetchWeather(
        requestLocationLat, requestLocationLon));
    return FakeWeatherAPIService.fetchWeather(
        requestLocationLat, requestLocationLon);
  }

  static Future<bool> addPerson(Person person) {
    return FakeReserveAPIService.addUser(person);
  }

  static Future<bool> editPerson(Person person) {
    return FakeReserveAPIService.editUser(person);
  }

  static Future<Session> makeReservation(Session session) {
    return FakeReserveAPIService.makeReservation(session);
  }

  static Future<Session> getReservation(String sessionId) {
    return FakeReserveAPIService.getReservation(sessionId);
  }

  static Future<bool> deleteReservation(String sessionId) {
    return FakeReserveAPIService.deleteReservation(sessionId);
  }

  static List<List<DateTime>> availableTimeBlocks(DateTime date) {
    return FakeReserveAPIService.availableTimeBlocks(date);
  }
}

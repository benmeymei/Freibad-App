import 'dart:convert';
import 'package:freibad_app/services/api_keys.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

abstract class API {
  static List<List<DateTime>> availableTimeBlocks(DateTime date) {
    //could be advanced with more conditions (like local holidays), for that reason placed in API_SERVICE

    String formattedDate = DateFormat('EEEEE').format(date);

    if (formattedDate == 'Saturday' || formattedDate == 'Sunday') {
      return [
        [addHour(date, 8), addHour(date, 13, minutes: 30)],
        [addHour(date, 14, minutes: 30), addHour(date, 20)],
      ];
    } else {
      return [
        [addHour(date, 6), addHour(date, 9)],
        [addHour(date, 10), addHour(date, 16)],
        [addHour(date, 17), addHour(date, 20)],
      ];
    }
  }

  //Helper function
  static DateTime addHour(DateTime date, int hours, {int minutes = 0}) {
    DateTime tempDate =
        DateTime(date.year, date.month, date.day, hours, minutes);
    //tempDate.add(Duration(hours: hours, minutes: minutes));
    return tempDate;
  }
}

class APIService extends API {
  static Future<List<Map<String, dynamic>>> fetchWeather(
    double requestLocationLat,
    double requestLocationLon,
  ) async {
    final List<Map<String, dynamic>> formattedWeatherResponse = [];
    final String url =
        'https://api.climacell.co/v3/weather/forecast/daily?lat=$requestLocationLat&lon=$requestLocationLon&' +
            'start_time=${DateTime.now().toIso8601String()}&' +
            'end_time=${DateTime.now().add(Duration(days: 14)).toIso8601String()}&' +
            'fields=weather_code&fields=temp';
    try {
      final weatherResponse = await http.get(
        url,
        headers: {
          'content-type': 'application/json',
          'apikey': APIKeys.ClimaCellAPIKey,
        },
      );
      developer.log('request to the ClimaCell API finished');
      if (weatherResponse.statusCode == 200) {
        List<dynamic> decodedResponse = jsonDecode(weatherResponse.body);

        for (Map<String, dynamic> dailyForecast in decodedResponse) {
          //get the max temp
          List<dynamic> listOfTemp = dailyForecast['temp'];
          Map<String, dynamic> dailyTempMaxInfo =
              listOfTemp[1]; //max temp is always second
          DateTime dailyTempMaxDateTime =
              DateTime.parse(dailyTempMaxInfo['observation_time']);
          double dailyTempMax = dailyTempMaxInfo['max']['value'];

          //get weather code
          String dailyWeatherCode = dailyForecast['weather_code']['value'];

          formattedWeatherResponse.add(
            {
              'max_temp': dailyTempMax,
              'max_temp_time': dailyTempMaxDateTime.toIso8601String(),
              'weather_code': dailyWeatherCode
            },
          );
        }
      } else {
        throw Exception(
            'Something went wrong calling the ClimaCell API, Error: ${weatherResponse.statusCode}');
      }
      developer.log('updated weather');
    } catch (exception) {
      developer.log("Error on calling the ClimaCell API", error: exception);
      throw exception;
    }
    return formattedWeatherResponse;
  }

  static List<List<DateTime>> availableTimeBlocks(DateTime date) {
    return API.availableTimeBlocks(date);
  }
}

class FakeAPIService extends API {
  static Future<List<Map<String, dynamic>>> fetchWeather(
    double requestLocationLat,
    double requestLocationLon,
  ) async {
    final List<Map<String, dynamic>> formattedWeatherResponse = [];
    for (int i = 0; i < 15; i++) {
      DateTime now = DateTime.now();
      formattedWeatherResponse.add(
        {
          'max_temp': 21.0,
          'max_temp_time': DateTime(now.year, now.month, now.day)
              .add(Duration(days: i))
              .toIso8601String(),
          'weather_code': 'partly_cloudy',
        },
      );
    }
    developer.log('updated fake weather');
    return Future.delayed(Duration(seconds: 5), () => formattedWeatherResponse);
  }

  static List<List<DateTime>> availableTimeBlocks(DateTime date) {
    return API.availableTimeBlocks(date);
  }
}

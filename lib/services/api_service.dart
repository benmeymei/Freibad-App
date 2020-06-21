import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:freibad_app/models/weather.dart';
import 'package:freibad_app/services/api_keys.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mdi/mdi.dart';

class APIService {
  static DateTime lastWeatherRefresh;
  static List<Map<String, dynamic>> weatherStorage;
  static List<Weather> weather;

  static Future<List<Weather>> getWeather() async {
    //create a weather forecast for 15 days from now
    double requestLocationLat = 51.248688;
    double requestLocationLon = 6.740645;

    if (lastWeatherRefresh != null &&
        lastWeatherRefresh.day != DateTime.now().day &&
        lastWeatherRefresh.add(Duration(hours: 12)).isBefore(DateTime.now())) {
      return Future.value(weather);
    } else {
      try {
        await _updateWeather(requestLocationLat, requestLocationLon);
        weather = [];
        for (int i = 0; i < weatherStorage.length; i++) {
          Map<String, dynamic> dailyWeather = weatherStorage[i];

          double temp = dailyWeather['max_temp'];
          IconData weatherIcon;

          switch (dailyWeather['weather_code']) {
            //see docs https://developer.climacell.co/v3/reference#data-layers-weather
            case 'clear': //FALL-THROUGH
            case 'mostly_clear':
              weatherIcon = Mdi.weatherSunny;
              break;
            case 'partly_cloudy':
              weatherIcon = Mdi.weatherPartlyCloudy;
              break;
            case 'mostly_cloudy': //FALL-THROUGH
            case 'cloudy':
              weatherIcon = Mdi.weatherCloudy;
              break;
            default:
              weatherIcon = Mdi.weatherPouring;
              break;
          }

          weather.add(
            Weather(
              skyIcon: weatherIcon,
              temp: temp,
              tempUnit: '°C',
            ),
          );
        }
        print('finished creating weatherPresenter');
        return weather;
      } catch (exception) {
        throw exception;
      }
    }
  }

  //Helper function

  static Future<void> _updateWeather(
    double requestLocationLat,
    double requestLocationLon,
  ) async {
    final String url =
        'https://api.climacell.co/v3/weather/forecast/daily?lat=$requestLocationLat&lon=$requestLocationLon&' +
            'start_time=${DateTime.now().toIso8601String()}&' +
            'end_time=${DateTime.now().add(Duration(days: 14)).toIso8601String()}&' +
            'fields=weather_code&fields=temp';
    final weatherResponse = await http.get(
      url,
      headers: {
        'content-type': 'application/json',
        'apikey': APIKeys.ClimaCellAPIKey,
      },
    );
    if (weatherResponse.statusCode == 200) {
      weatherStorage = [];
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

        weatherStorage.add(
          {
            'max_temp': dailyTempMax,
            'max_temp_time': dailyTempMaxDateTime.toIso8601String(),
            'weather_code': dailyWeatherCode
          },
        );
      }
      lastWeatherRefresh = DateTime.now();
    } else {
      throw Exception(
          'ClimaCell API not responding, Error: ${weatherResponse.statusCode}');
    }
    print('updated weather');
  }

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
    DateTime tempDate = date;
    return tempDate.add(
      Duration(hours: hours, minutes: minutes),
    );
  }
}

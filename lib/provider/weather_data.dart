import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:freibad_app/models/weather.dart';
import 'package:freibad_app/services/api_service.dart';
import 'package:mdi/mdi.dart';

class WeatherData with ChangeNotifier {
  DateTime lastWeatherRefresh;
  List<Map<String, dynamic>> rawWeather;
  Map<DateTime, Weather>
      weather; //key is the day of the weather forecast at zero o'clock

  bool useFakeAPIService;

  WeatherData({this.useFakeAPIService = false});

  Future<Map<DateTime, Weather>> getWeatherForecast() async {
    if (lastWeatherRefresh == null ||
        lastWeatherRefresh.day != DateTime.now().day ||
        lastWeatherRefresh.add(Duration(hours: 12)).isBefore(DateTime.now())) {
      developer.log('refreshing the weather');
      await fetchAndSetData();
    }
    return weather;
  }

  Weather getDailyWeatherForecast(DateTime date) {
    //returns null if date is not in weather
    if (weather == null) return null;
    return weather[DateTime(
      date.year,
      date.month,
      date.day,
    )];
  }

  Future<void> fetchAndSetData() async {
    //create a weather forecast for 15 days from now
    double requestLocationLat;
    double requestLocationLon;
    Location location = Location();
    await location.requestPermission();

    if (await location.serviceEnabled()) {
      LocationData userLocation = await location.getLocation();
      requestLocationLat = userLocation.latitude;
      requestLocationLon = userLocation.longitude;
    } else {
      requestLocationLat = 51.2385413;
      requestLocationLon = 6.744311;
    }

    try {
      useFakeAPIService
          ? rawWeather = await FakeAPIService.fetchWeather(
              requestLocationLat, requestLocationLon)
          : rawWeather = await APIService.fetchWeather(
              requestLocationLat, requestLocationLon);

      developer.log("API responded");
      weather = {};
      for (int i = 0; i < rawWeather.length; i++) {
        Map<String, dynamic> dailyWeather = rawWeather[i];

        double maxTemp = (dailyWeather['max_temp'] +
            0.0); //+.0 to prevent code to not accept plain numbers
        DateTime maxTempTime = DateTime.parse(dailyWeather['max_temp_time']);
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

        weather.putIfAbsent(
          DateTime(maxTempTime.year, maxTempTime.month,
              maxTempTime.day), //use maxTempTime to define the Timestamp
          () => Weather(
              skyIcon: weatherIcon,
              maxTemp: maxTemp,
              tempUnit: '°C',
              maxTempTime: maxTempTime),
        );
      }
      developer.log('finished creating the weather map');
      lastWeatherRefresh = DateTime.now();
    } catch (exception) {
      //throw exception;
    }
  }
}

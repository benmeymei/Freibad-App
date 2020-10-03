import 'package:flutter/foundation.dart';

class Settings with ChangeNotifier {
  bool _useServerValue = true;
  bool _useWeatherAPIValue = true;
  bool isUpdated = true;

  set useServer(bool value) {
    isUpdated = false;
    _useServerValue = value;
    notifyListeners();
  }

  set useWeatherAPI(bool value) {
    isUpdated = false;
    _useWeatherAPIValue = value;
    notifyListeners();
  }

  bool get useServer {
    return _useServerValue;
  }

  bool get useWeatherAPI {
    return _useWeatherAPIValue;
  }
}

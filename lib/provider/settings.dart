import 'package:flutter/foundation.dart';

class Settings with ChangeNotifier {
  Settings(
    this._useServerValue,
    this._useWeatherAPIValue,
    this._useStorageService,
  );

  bool _useServerValue;
  bool _useWeatherAPIValue;
  bool _useStorageService;
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

  set useStorageService(bool value) {
    if (!kIsWeb) {
      //storage service functions only on mobile
      isUpdated = false;
      _useStorageService = value;
      notifyListeners();
    }
  }

  bool get useServer {
    return _useServerValue;
  }

  bool get useWeatherAPI {
    return _useWeatherAPIValue;
  }

  bool get useStorageService {
    return _useStorageService;
  }
}

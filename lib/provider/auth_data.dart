import 'dart:async';

import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:freibad_app/models/httpException.dart';
import 'package:freibad_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

//using SharedPreferences for securing login data might not be the best solution security wise, but it works on all platforms
class AuthData with ChangeNotifier {
  AuthData({@required this.useAPIService});
  final bool useAPIService;

  String _token;
  DateTime _expiryDate;
  Timer _authTimer;

  bool get isAuth {
    return (_token != null && _token.isNotEmpty);
  }

  String get token {
    //developer.log('Token: $_token');

    if (_expiryDate != null &&
        _token != null &&
        _expiryDate.isAfter(DateTime.now())) {
      return _token;
    }
    developer.log('something went wrong getting the token, trying to login');
    return '';
  }

  Future<bool> register(String name, String password) async {
    bool response;
    try {
      response = useAPIService
          ? await APIService.registerUser(name, password)
          : await FakeAPIService.registerUser(name, password);
    } on HttpException catch (exception) {
      throw exception;
    } catch (exception) {
      throw exception;
    }

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('name', name);
    prefs.setString('password', password);

    return response;
  }

  Future<String> login({String name, String password}) async {
    final prefs = await SharedPreferences.getInstance();
    if (name == null || password == null) {
      name = prefs.getString('name');
      password = prefs.getString('password');
    } else {
      prefs.setString('name', name);
      prefs.setString('password', password);
    }
    try {
      String response = useAPIService
          ? await APIService.loginUser(name, password)
          : await FakeAPIService.loginUser(
              name, password); // [String reason/token, bool success]

      _token = response;
      _authTimer = Timer(Duration(minutes: 55), () {
        developer.log('renewing token');
        login();
      }); //token expires after one hour, renew token by login again
      _expiryDate = DateTime.now().add(Duration(minutes: 55));
      notifyListeners();
      return token;
    } on HttpException catch (exception) {
      throw exception;
    } catch (exception) {
      developer.log('unexpected exception: ', error: exception);
      throw exception;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('name') && prefs.containsKey('password')) {
      developer.log('try to auto login user');
      try {
        await login();
        return true;
      } catch (exception) {
        developer.log('could not login user');
      }
    } else
      developer.log('no data, to auto login user');

    return false;
  }

  Future<void> logout() async {
    _token = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}

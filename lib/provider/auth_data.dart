import 'dart:async';

import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
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
    return _token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _token != null &&
        _expiryDate.isAfter(DateTime.now())) {
      return _token;
    }
    developer.log('something went wrong getting the token, trying to login');
    return '';
  }

  Future<Map<String, dynamic>> register(String name, String password) async {
    String response = useAPIService
        ? await APIService.registerUser(name, password)
        : await FakeAPIService.registerUser(name, password);

    if (response != 'successful') {
      return {'reason': response, 'success': false};
    }

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('name', name);
    prefs.setString('password', password);

    return {'reason': '', 'success': true};
  }

  Future<Map<String, dynamic>> login({String name, String password}) async {
    final prefs = await SharedPreferences.getInstance();
    if (name == null || password == null) {
      name = prefs.getString('name');
      password = prefs.getString('password');
    } else {
      prefs.setString('name', name);
      prefs.setString('password', password);
    }

    List<dynamic> response = useAPIService
        ? await APIService.loginUser(name, password)
        : await FakeAPIService.loginUser(
            name, password); // [String reason/token, bool success]

    if (response[1]) {
      _token = response[0];
      _authTimer = Timer(Duration(minutes: 55), () {
        developer.log('renewing token');
        login();
      }); //token expires after one hour, renew token by login again
      _expiryDate = DateTime.now().add(Duration(minutes: 55));
      notifyListeners();
      return {'reason': '', 'success': true};
    } else {
      return {'reason': response[0], 'success': false};
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('name') && prefs.containsKey('password')) {
      developer.log('try to auto login user');
      return (await login())[1];
    }

    developer.log('no data to auto login user');

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

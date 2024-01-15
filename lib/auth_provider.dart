import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AuthProvider with ChangeNotifier {

  String? _token;
  String? _userId;
  DateTime? _expireDate;
  Timer? _timer;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if(_expireDate != null && _expireDate!.isAfter(DateTime.now()) && _token != null) {
      return _token;
    } else {
      print ('token =**> NULL');
      return null;
    }
  }

  /// authenticate main FUNC

  Future<void> _authenticate(String email, String password, String urlSegment) async {
    final url = 'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyBUeqMKjCwrlHvD0D5KqfiSN1UPNYLIFgg';
    try {
      http.Response response = await http.post(Uri.parse(url),
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));

      var resData = json.decode(response.body);
      print(resData);
      ///
      print('validator : ${json.decode(response.body)['error']['message']}');

      if(resData['error'] != null){
        throw resData['error']['message'];
      }


      _token = resData['idToken'];
      _userId = resData['localId'];
      _expireDate = DateTime.now().add(Duration(seconds: int.parse(resData['expiresIn'])));
      autoLogout();
      notifyListeners();

      /// save data in SharedPreferences local store
      // Automatically login
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userData = json.encode({
        'token' : _token,
        'userId' : _userId,
        'expireDate' : _expireDate!.toIso8601String(),
      });
      prefs.setString('userData', userData);

    } catch (e) {
      rethrow;  //  e = resData['error']['message'] /// passing to submit method
    }
  } // _authenticate


  /// start signUp method
  Future<void> signUp(String email, String password) {
    return _authenticate(email, password, "signUp");
  } // signUp

  /// start logIn method
  Future<void> logIn(String email, String password) {
    return _authenticate(email, password, "signInWithPassword");
  } // logIn

  /// Log Out Method
void logout() async {
  _token = null;
  _userId = null;
  _expireDate = null;
  if(_timer != null) {
    _timer!.cancel();
    _timer = null;
  }
  notifyListeners();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear(); // prefs.remove('userData');
}

/// Automatically Log Out Method
 void autoLogout () {
    if(_timer != null) {
      _timer!.cancel();
    }
    int timeToExpiry = _expireDate!.difference(DateTime.now()).inSeconds;
  _timer = Timer(Duration(seconds: timeToExpiry), logout);
  notifyListeners();
}

/// Automatically login

Future<bool> tryAutoLogin() async{

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if(!prefs.containsKey('userData')){
    return false;
  }

  final extractedUserData = json.decode(prefs.getString('userData')!) as Map<String,Object>;

  final DateTime expireDate = DateTime.parse(extractedUserData['expireDate'].toString());

  if(expireDate.isBefore(DateTime.now())){
    return false;
  }

  _token = extractedUserData['token'].toString();
  _userId = extractedUserData['userId'].toString();
  _expireDate = expireDate;

  notifyListeners();
  autoLogout();
  return true;
}


} // Auth Provider

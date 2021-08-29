import 'package:firebase_auth/firebase_auth.dart';

class UserInfoStore {
  static User? _user;

  static get user => _user;

  static set setUser(response) => _user = response;
}

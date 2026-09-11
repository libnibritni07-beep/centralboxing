import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _kPin = 'pin_hash';
  Future<bool> hasPin() async =>
      (await SharedPreferences.getInstance()).containsKey(_kPin);
  String _hash(String pin) => sha256.convert(utf8.encode(pin)).toString();
  Future<void> setPin(String pin) async =>
      (await SharedPreferences.getInstance()).setString(_kPin, _hash(pin));
  Future<bool> checkPin(String pin) async =>
      (await SharedPreferences.getInstance()).getString(_kPin) == _hash(pin);
}

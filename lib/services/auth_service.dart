import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _kPin = 'pin_hash';
  static const _kBio = 'biometric_enabled';
  final LocalAuthentication _bio = LocalAuthentication();

  Future<bool> hasPin() async =>
      (await SharedPreferences.getInstance()).containsKey(_kPin);
  String _hash(String pin) => sha256.convert(utf8.encode(pin)).toString();
  Future<void> setPin(String pin) async =>
      (await SharedPreferences.getInstance()).setString(_kPin, _hash(pin));
  Future<bool> checkPin(String pin) async =>
      (await SharedPreferences.getInstance()).getString(_kPin) == _hash(pin);

  Future<bool> isBiometricEnabled() async =>
      (await SharedPreferences.getInstance()).getBool(_kBio) ?? false;
  Future<void> setBiometricEnabled(bool v) async =>
      (await SharedPreferences.getInstance()).setBool(_kBio, v);

  Future<bool> canUseBiometrics() async {
    try {
      final canCheck = await _bio.canCheckBiometrics;
      final isAvailable = await _bio.isDeviceSupported();
      if (!canCheck || !isAvailable) return false;
      final available = await _bio.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      return await _bio.authenticate(
        localizedReason: 'Desbloquear Central Boxing',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthApi {
  static final _auth = LocalAuthentication();

  static Future<bool> hasBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print('Error checking biometrics: $e');
      return false;
    }
  }

  static Future<List<BiometricType>> getBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print('Error getting biometrics: $e');
      return <BiometricType>[];
    }
  }

  static Future<bool> authenticate() async {
    final isAvailable = await hasBiometrics();
    print('Biometrics available: $isAvailable');

    if (!isAvailable) {
      print('Biometric authentication is not available');
      return false;
    }

    try {
      final result = await _auth.authenticate(
        localizedReason: 'Authenticate to continue',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (result) {
        print('Authentication successful');
        return true;
      } else {
        print('Authentication failed or canceled');
        return false;
      }
    } on PlatformException catch (e) {
      if (e.code == 'user_canceled') {
        print('User canceled the authentication');
      } else if (e.code == 'system_canceled') {
        print('System canceled the authentication');
      } else {
        print('Unhandled error: $e');
      }
      return false;
    }
  }}

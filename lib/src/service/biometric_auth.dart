import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import 'storage_service.dart'; // adjust path as needed

class BiometricService {
  static final _auth = LocalAuthentication();

  static Future<bool> authenticate(BuildContext context) async {
    final canCheck = await _auth.canCheckBiometrics;
    final isAvailable = await _auth.isDeviceSupported();

    if (!canCheck || !isAvailable) {
      await _handleFailure(context, "Biometrics not supported or unavailable");
      return false;
    }

    try {
      final authenticated = await _auth.authenticate(
        localizedReason: 'Please authenticate to access the app',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!authenticated) {
        await _handleFailure(context, "Authentication failed");
      }

      return authenticated;
    } catch (e) {
      await _handleFailure(context, "Biometric error: $e");
      return false;
    }
  }

  static Future<void> _handleFailure(BuildContext context, String reason) async {
    await StorageService.clearUser();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(reason)),
    );

    // Navigate to login
    Navigator.pushReplacementNamed(context, '/login');
  }
}

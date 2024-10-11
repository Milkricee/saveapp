// lib/logik/biometrie.dart

import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometrieManager {
  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _biometricsEnabledKey = 'biometrics_enabled';

  // Überprüfen, ob Biometrie verfügbar ist
  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Biometrie-Überprüfung fehlgeschlagen: $e");
      }
      return false;
    }
  }

  // Liste der verfügbaren biometrischen Sensoren abrufen (z.B. Fingerabdruck, Gesichtserkennung)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Fehler beim Abrufen der Biometrie: $e");
      }
      return <BiometricType>[];
    }
  }

  // Biometrische Authentifizierung
  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Authentifizieren Sie sich, um auf den Foto-Safe zuzugreifen',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Fehler bei der biometrischen Authentifizierung: $e");
      }
      return false;
    }
  }

  // Überprüfen, ob Biometrie aktiviert ist
  Future<bool> isBiometricsEnabled() async {
    try {
      String? biometricsEnabled = await _secureStorage.read(key: _biometricsEnabledKey);
      return biometricsEnabled == 'true';
    } catch (e) {
      if (kDebugMode) {
        print("Fehler beim Überprüfen des Biometrie-Status: $e");
      }
      return false;
    }
  }

  // Biometrie aktivieren/deaktivieren (kann in den Einstellungen verwendet werden)
  Future<void> setBiometricsEnabled(bool isEnabled) async {
    try {
      await _secureStorage.write(key: _biometricsEnabledKey, value: isEnabled.toString());
    } catch (e) {
      if (kDebugMode) {
        print("Fehler beim Speichern des Biometrie-Status: $e");
      }
    }
  }
}

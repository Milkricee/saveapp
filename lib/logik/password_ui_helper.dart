import 'package:flutter/material.dart';
import 'password_manager.dart';

class PasswordUIHelper {
  // Überprüft, ob das Passwort bereits existiert und gibt den Status zurück
  static Future<bool> isPasswordSet() async {
    return await PasswordManager.doesPasswordExist();
  }

  // UI für die initiale Passwortvergabe mit zwei Eingabefeldern untereinander
  static Widget buildPasswordInput(
    BuildContext context,
    bool isFirstPasswordInput,
    Function(String) onPasswordEntered,
    Function(String) onConfirmPasswordEntered,
    Function() onNextStep,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Bitte neues Passwort festlegen:',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          TextField(
            keyboardType: TextInputType.number,
            obscureText: true,
            onChanged: (value) => onPasswordEntered(value),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Neues Passwort',
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            keyboardType: TextInputType.number,
            obscureText: true,
            onChanged: (value) => onConfirmPasswordEntered(value),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Passwort bestätigen',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => onNextStep(),
            child: const Text('Passwort festlegen'),
          ),
        ],
      ),
    );
  }

  // UI für die Passworteingabe bei vorhandenem Passwort
  static Widget buildPasswordCheckInput(
    BuildContext context,
    Function(String) onPasswordEntered,
    Function() onPasswordCheck,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Bitte Passwort eingeben:',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          TextField(
            keyboardType: TextInputType.number,
            obscureText: true,
            onChanged: (value) => onPasswordEntered(value),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Passwort',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => onPasswordCheck(),
            child: const Text('Passwort eingeben'),
          ),
        ],
      ),
    );
  }
}

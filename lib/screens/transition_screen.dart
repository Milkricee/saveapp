import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'home.dart';

class TransitionScreen extends StatefulWidget {
  const TransitionScreen({super.key});

  @override
  State<TransitionScreen> createState() => _TransitionScreenState();
}

class _TransitionScreenState extends State<TransitionScreen> {
  bool _isLoading = false; // Statusvariable für den Ladezustand

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

 Future<void> _requestPermissions() async {
  setState(() {
    _isLoading = true;
  });

  try {
    // Fordere Speicherberechtigung an
    var status = await Permission.storage.request();

    if (!mounted) return;

    if (status.isGranted) {
      debugPrint("Berechtigung erteilt");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (status.isPermanentlyDenied) {
      debugPrint("Berechtigung dauerhaft verweigert");
      setState(() {
        _isLoading = false;
      });
      _showPermissionDialog();
    } else {
      debugPrint("Berechtigung verweigert");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speicherzugriff verweigert! Bitte Berechtigung erlauben.')),
      );
    }
  } catch (e) {
    debugPrint("Fehler bei Berechtigungsanfrage: $e");
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ein Fehler ist aufgetreten.')),
    );
  }
}

void _showPermissionDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Berechtigung erforderlich'),
      content: const Text(
        'Die Speicherberechtigung wurde dauerhaft verweigert. Bitte erlauben Sie den Zugriff in den Einstellungen.',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Dialog schließen
          },
          child: const Text('Abbrechen'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context); // Dialog schließen
            bool opened = await openAppSettings(); // Zu den Einstellungen weiterleiten

            if (!opened) {
              debugPrint("Konnte die Einstellungen nicht öffnen");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Konnte Einstellungen nicht öffnen.')),
              );
            } else {
              debugPrint("Einstellungen geöffnet");
              await _checkPermissionsAfterSettings(); // Berechtigungen erneut prüfen
            }
          },
          child: const Text('Zu den Einstellungen'),
        ),
      ],
    ),
  );
}

  Future<void> _checkPermissionsAfterSettings() async {
    var status = await Permission.storage.status;

    if (!mounted) return;

    if (status.isGranted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berechtigung weiterhin verweigert!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Berechtigungen erforderlich'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Bitte gewähren Sie den Speicherzugriff, um fortzufahren.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                 ElevatedButton(
                  onPressed: () {
                 debugPrint("Berechtigung erteilen Button gedrückt");
                _requestPermissions();
                   },
                  child: const Text('Berechtigung erteilen'),
                ),  

                ],
              ),
      ),
    );
  }
}

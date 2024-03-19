import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // Importar el paquete path_provider

import 'appdata.dart';
import 'game.dart';
import 'my_home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ConfigurationScreen(),
    );
  }
}

class ConfigurationScreen extends StatefulWidget {
  @override
  _ConfigurationScreenState createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  final TextEditingController ipController = TextEditingController();
  final TextEditingController portController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedConfiguration();
  }

  _loadSavedConfiguration() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/config.txt');
      if (await file.exists()) {
        List<String> lines = await file.readAsLines();
        setState(() {
          ipController.text = lines[0];
          portController.text = lines[1];
        });
      }
    } catch (e) {
      print("Error loading configuration: $e");
    }
  }

  _saveConfiguration() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/config.txt');
      await file.writeAsString('${ipController.text}\n${portController.text}');
    } catch (e) {
      print("Error saving configuration: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuration'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: ipController,
              decoration: InputDecoration(
                labelText: 'IP Address',
              ),
            ),
            TextField(
              controller: portController,
              decoration: InputDecoration(
                labelText: 'Port',
              ),
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Your Name',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveConfiguration(); // Guardar configuración
                String ip = ipController.text;
                int port = int.tryParse(portController.text) ?? 0;
                String playerName = nameController.text;
                final appData =
                    AppData(ip: ip, port: port, playerName: playerName);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyHomePage(appData: appData)),
                );
              },
              child: Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }
}

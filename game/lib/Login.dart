import 'dart:convert';

import 'package:flappy_ember/appdata.dart';
import 'package:flappy_ember/players_screen.dart';
import 'package:flutter/material.dart';
import 'package:flappy_ember/game.dart';
import 'package:flame/game.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  late SharedPreferences _prefs;
  late String _savedIP;
  late int _savedPort;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    _prefs = await SharedPreferences.getInstance();
    _savedIP = _prefs.getString('ip') ?? '';
    _savedPort = _prefs.getInt('port') ?? 8888;
    _ipController.text = _savedIP;
    _portController.text = _savedPort.toString();
  }

  Future<void> _saveData() async {
    await _prefs.setString('ip', _ipController.text);
    await _prefs.setInt('port', int.parse(_portController.text));
  }

  Future<void> _startGame() async {
    final ip = _ipController.text;
    final port = int.tryParse(_portController.text) ?? 8888;
    final name = _nameController.text;
    final appData = Provider.of<AppData>(context, listen: false);
    appData.setNamePlayer(name);

    await _saveData(); // Guarda los datos de IP y puerto.

    FlappyEmberGame game = FlappyEmberGame();
    game.name = name;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PlayersScreen(game: game)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigoAccent, // Cambio de color de fondo.
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '¡Bienvenido!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Introduce los datos para unirte',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _ipController,
                  decoration: InputDecoration(
                    labelText: 'IP del Servidor',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _portController,
                  decoration: InputDecoration(
                    labelText: 'Puerto',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del Jugador',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _startGame,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    child: Text(
                      'Comenzar Juego',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.orangeAccent, // Cambio de color del botón.
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

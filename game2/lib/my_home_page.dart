import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'appdata.dart';
import 'game.dart';

class MyHomePage extends StatefulWidget {
  final AppData appData;

  MyHomePage({required this.appData});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<String> players;

  @override
  void initState() {
    super.initState();
    widget.appData.addObserver(_updatePlayers);
    _updatePlayers();
  }

  void _updatePlayers() {
    setState(() {
      players = widget.appData.players;
    });
  }

  @override
  void dispose() {
    widget.appData.removeObserver(_updatePlayers);
    super.dispose();
  }

  void startFlappyEmber(AppData appData) {
    final game = FlappyEmber(
      appData: appData,
    );
    WidgetsFlutterBinding.ensureInitialized();
    runApp(GameWidget(game: game));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: players.map((player) {
                return NumberBox(
                  player: player,
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (widget.appData.ready) {
                  startFlappyEmber(widget.appData);
                  print('Botón "Ready" presionado');
                } else {
                  widget.appData.sendready(widget.appData.playerId);
                  print('Botón "Ready" presionado');
                }
              },
              child: Text(widget.appData.ready
                  ? 'Ready'
                  : 'Not Ready'), // Actualiza el texto del botón según el estado de `ready`
            ),
          ],
        ),
      ),
    );
  }
}

class NumberBox extends StatelessWidget {
  final String player;

  NumberBox({required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          player,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

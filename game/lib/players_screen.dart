import 'package:flame/game.dart';
import 'package:flappy_ember/appdata.dart';
import 'package:flappy_ember/game.dart';
import 'package:flappy_ember/ranking.dart';
import 'package:flappy_ember/Login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayersScreen extends StatefulWidget {
  final FlappyEmberGame game;

  const PlayersScreen({Key? key, required this.game}) : super(key: key);

  @override
  _PlayersScreenState createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  @override
  void initState() {
    super.initState();
    widget.game.onPlayersUpdated = _updateConnectedPlayers;
    widget.game.onTiempo = _tiempo;
    widget.game.onGameStart = () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => GameWidget(
            game: widget.game,
            overlayBuilderMap: {
              'rankingOverlay': (context, _) =>
                  RankingScreen(game: widget.game),
            },
          ),
        ),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Players',
                style: TextStyle(color: Colors.white)), // Letras blancas.
            Consumer<AppData>(
              builder: (context, appData, child) {
                return Text(
                  'Tiempo para el inicio: ${appData.tiempo} s',
                  style: TextStyle(
                      fontSize: 16, color: Colors.white), // Letras blancas.
                );
              },
            ),
          ],
        ),
        backgroundColor: Colors.black, // Fondo negro.
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Consumer<AppData>(
              builder: (context, appData, child) {
                return ListView.builder(
                  itemCount: appData.connectedPlayers.length,
                  itemBuilder: (context, index) {
                    var playerName =
                        appData.connectedPlayers[index]['name'] as String;
                    var playerColor =
                        appData.connectedPlayers[index]['color'] as String;
                    Color? color = _colorFromName(
                        playerColor); // Convierte el String a Color.
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: EdgeInsets.all(
                                  8.0), // Añade un padding al contenedor del nombre.
                              color: _colorFromName(
                                  playerColor), // Fondo del contenedor del nombre.
                              child: Text(playerName,
                                  style: TextStyle(fontSize: 18)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              icon: Icon(Icons.exit_to_app),
              label: Text('Desconectar'),
              onPressed: () {
                widget.game.disconnect();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateConnectedPlayers(List<dynamic> connectedPlayers) {
    if (mounted) {
      Provider.of<AppData>(context, listen: false)
          .setUsuarios(connectedPlayers);
    }
  }

  void _tiempo(int tiempo) {
    if (mounted) {
      Provider.of<AppData>(context, listen: false).setTiempo(tiempo);
    }
  }

  Color? _colorFromName(String name) {
    switch (name) {
      case 'vermell':
        return Colors.red;
      case 'verd':
        return Colors.green;
      case 'taronja':
        return Colors.orange;
      case 'blau':
        return Colors.blue;
      default:
        return null;
    }
  }
}

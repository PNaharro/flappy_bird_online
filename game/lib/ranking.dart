import 'package:flappy_ember/appdata.dart';
import 'package:flappy_ember/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RankingScreen extends StatefulWidget {
  final FlappyEmberGame game;

  const RankingScreen({Key? key, required this.game}) : super(key: key);

  @override
  _RankingScreenState createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  @override
  void initState() {
    super.initState();
    widget.game.onPlayersUpdatedlost = _updateLostPlayers;
  }

  @override
  Widget build(BuildContext context) {
    List playersList = Provider.of<AppData>(context).lostPlayers;

    // Ordena los jugadores en orden ascendente según su posición en el ranking.
    playersList.sort((a, b) => a['position'].compareTo(b['position']));

    return Scaffold(
      appBar: AppBar(
        title: Text('Ranking'),
        backgroundColor:
            Colors.deepPurple, // Cambio de color de la barra de navegación.
      ),
      body: Container(
        padding: EdgeInsets.all(
            16.0), // Añadido espacio interno alrededor de la lista.
        color: Colors.grey[200], // Fondo gris claro.
        child: ListView.separated(
          itemCount: playersList.length,
          separatorBuilder: (context, index) =>
              SizedBox(height: 10), // Espacio entre elementos de la lista.
          itemBuilder: (BuildContext context, int index) {
            final player = playersList[index];
            return _buildPlayerTile(player as Map<String, dynamic>, index);
          },
        ),
      ),
    );
  }

  Widget _buildPlayerTile(Map<String, dynamic> player, int index) {
    Color? tileColor;

    // Configura el color y el icono basado en la posición.
    switch (player['position']) {
      case 1:
        tileColor = Colors.amberAccent; // Color ámbar para el primer puesto.
        break;
      case 2:
        tileColor = Colors.grey[300]; // Color gris para el segundo puesto.
        break;
      case 3:
        tileColor = Colors.brown; // Color marrón para el tercer puesto.
        break;
      default:
        tileColor = Colors.white;
    }

    return Card(
      color: tileColor, // Color de fondo del elemento de lista.
      elevation: 3, // Elevación para crear una sombra.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Bordes redondeados.
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
            horizontal: 16.0), // Ajuste del espacio interno.
        title: Center(
          // Centra el título.
          child: Text(
            '${player['name']}',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center, // Alinea el texto al centro.
          ),
        ),
        subtitle: Center(
          // Centra el subtítulo.
          child: Text(
            'Posición: ${player['position']}',
            textAlign: TextAlign.center, // Alinea el texto al centro.
          ),
        ),
      ),
    );
  }

  void _updateLostPlayers(List<dynamic> lostPlayers) {
    Provider.of<AppData>(context, listen: false).setUsuarioslost(lostPlayers);
  }
}

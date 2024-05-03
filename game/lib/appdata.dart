import 'dart:convert';
import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/foundation.dart';

import 'game.dart';
import 'player.dart';

class AppData {
  late IOWebSocketChannel _webSocketChannel;
  List<Player> playersIngame = [];

  List<String> players = [];
  List<VoidCallback> _observers = []; // Lista de observadores
  String playerId = "";
  String tappedPlayerId = "";
  late String ip;
  late int port;
  late String playerName;
  bool isGameOver = false;
  bool ready = false; // Nuevo campo para indicar si el juego ha terminado
  bool taped = true;
  AppData({required this.ip, required this.port, required this.playerName}) {
    // Establecer conexión WebSocket
    print('ws://$ip:$port');
    //_webSocketChannel = IOWebSocketChannel.connect('ws://localhost:8888');
    _webSocketChannel = IOWebSocketChannel.connect('ws://$ip:$port');

    _webSocketChannel.stream.listen((message) {
      if (message != null) {
        final jsonData = jsonDecode(message);
        if (jsonData != null && jsonData is Map<String, dynamic>) {
          if (jsonData['type'] == 'id') {
            players.add(jsonData['id']);
            playerId = jsonData['id'];
            _notifyObservers(); // Notificar a los observadores después de cambiar la lista de jugadores
          } else if (jsonData['type'] == 'newClient') {
            String newPlayerId = jsonData['id'];
            if (!players.contains(newPlayerId)) {
              // Verifica si la ID no está en la lista
              players.add(newPlayerId);
              _notifyObservers();
            }
          } else if (jsonData['type'] == 'welcome') {
            if (jsonData.containsKey('ids') && jsonData['ids'] is List) {
              List<String> idsList = List<String>.from(jsonData['ids']);
              for (String id in idsList) {
                if (!players.contains(id)) {
                  players.add(id);
                }
              }
              // Ahora la lista de jugadores (`players`) contiene todas las IDs recibidas
              _notifyObservers(); // Asegúrate de notificar a los observadores sobre el cambio en la lista de jugadores
            } else {
              print('Error: Campo "ids" no encontrado o no es una lista.');
            }
          } else if (jsonData['type'] == 'disconnected') {
            players.remove(jsonData['id']);
            _notifyObservers();
          } else if (jsonData['type'] == 'player_colision') {
            players.remove(jsonData['id']);
            _notifyObservers();
            print(jsonData["id"]);
          } else if (jsonData['type'] == 'player_tap') {
            tappedPlayerId = jsonData["id"];
            if (playerId == tappedPlayerId) {
              print("Tapped player ID: $tappedPlayerId");
            }
          } else if (jsonData['type'] == 'startGame') {
            setReady(true);
          }
        } else {
          print('Error: El mensaje recibido no es un mapa válido.');
        }
      } else {
        print('Error: Mensaje nulo recibido del servidor.');
      }
    }, onError: (error) {
      print('WebSocket error: $error');
    });
  }

  void setReady(bool value) {
    ready = value;
    _notifyObservers(); // Notificar a los observadores sobre el cambio en el estado de `ready`
  }

  // Método para agregar un observador
  void addObserver(VoidCallback observer) {
    _observers.add(observer);
  }

  // Método para eliminar un observador
  void removeObserver(VoidCallback observer) {
    _observers.remove(observer);
  }

  // Método para notificar a todos los observadores
  void _notifyObservers() {
    for (var observer in _observers) {
      observer();
    }
  }

  void sendPosition(int x, int y, String id) {
    final data = jsonEncode({
      'type': 'player_position',
      'x': x,
      'y': y,
      'id': id,
    });
    _webSocketChannel.sink.add(data);
  }

  void sendcolision(int x, int y, String id) {
    final data = jsonEncode({
      'type': 'player_colision',
      'x': x,
      'y': y,
      'id': id,
    });
    _webSocketChannel.sink.add(data);
  }

  void sendtap(String id) {
    final data = jsonEncode({
      'type': 'player_tap',
      'id': id,
    });
    _webSocketChannel.sink.add(data);
  }

  void sendready(String id) {
    final data = jsonEncode({
      'type': 'ready',
      'id': id,
    });
    _webSocketChannel.sink.add(data);
  }

  // Método para indicar que el juego ha terminado
  void gameOver() {
    isGameOver = true;
    // Aquí puedes guardar otros datos relevantes del juego, como la puntuación, etc.
  }
}

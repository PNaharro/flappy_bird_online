import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

import 'appdata.dart';
import 'box_stack.dart';
import 'player.dart';
import 'sky.dart';

class FlappyEmber extends FlameGame with TapDetector, HasCollisionDetection {
  late final Player player1, player2, player3, player4;
  double speed = 500;
  final random = Random();
  final AppData appData;
  late final TextComponent textComponent; // Nuevo
  bool isGameOver = false;

  FlappyEmber({required this.appData});

  @override
  Future<void>? onLoad() async {
    List<String> playersList = appData.players;
    print(playersList.length);

    switch (playersList.length) {
      case 0:
        print('No hay jugadores disponibles');
        break;
      case 1:
        add(Sky());
        add(ScreenHitbox());
        player1 = Player("1", playersList[0], appData, true);
        add(player1);
        break;
      case 2:
        add(Sky());
        add(ScreenHitbox());
        player1 = Player("1", playersList[0], appData, true);
        add(player1);
        player2 = Player("2", playersList[1], appData, false);
        add(player2);
        break;
      case 3:
        // Código para tres jugadores
        break;
      case 4:
        // Código para cuatro jugadores
        break;
    }

    // Agregar componente de texto
    textComponent = TextComponent(text: 'Game Over');
    textComponent.x = 100;
    textComponent.y = 100;

    // Ocultar el texto al principio

    // Verificar si el juego estaba en Game Over la última vez
    if (appData.isGameOver) {
      add(textComponent);
      gameover();
    }

    return null;
  }

  void gameover() {
    isGameOver = true;
    // Mostrar el texto
    pauseEngine();
  }

  double _timeSinceBox = 0;
  double _boxInterval = 1;
  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) {
      appData.players.remove(player1.playerId);
      remove(player1);
      if (appData.players == 0) {
        gameover();
      }
    } else {
      speed += 10 * dt;
      _timeSinceBox += dt;
      if (appData.players.length > 1) {
        if (appData.taped) {
          print("tap");
          print(player2 != null);
          print("-----");
          print(player2.playerId + "/" + appData.tappedPlayerId);
          if (player2 != null && player2.playerId == appData.tappedPlayerId) {
            appData.taped = false;
            appData.tappedPlayerId = "";
            player2.fly();
            print("tap2");
          }
        }
      }
      if (_timeSinceBox > _boxInterval) {
        add(BoxStack(isBottom: random.nextBool(), appData: appData));
        _timeSinceBox = 0;
      }
    }
  }

  @override
  void onTap() {
    super.onTap();
    player1.fly();
    appData.sendtap(player1.playerId);
  }
}

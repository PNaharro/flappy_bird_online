import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flappy_ember/player.dart';
import 'package:flutter/material.dart';
import 'WebSocketsHandler.dart';
import 'boxStack.dart';
import 'sky.dart';

enum GameState {
  WaitingForPlayers,
  ReadyToStart,
  Playing,
  GameOver,
}

class FlappyEmber extends FlameGame with TapDetector, HasCollisionDetection {
  late final Player player;
  double speed = 500;
  final random = Random();
  late final WebSocketsHandler webSocketHandler;
  double _timeSinceBox = 0;
  double _boxInterval = 1;
  List<String> players = [];
  GameState gameState = GameState.WaitingForPlayers;

  FlappyEmber() {
    initWebSocket();
  }

  @override
  Future<void>? onLoad() async {
    return null;
  }

  void initWebSocket() {
    webSocketHandler = WebSocketsHandler();
    webSocketHandler.connectToServer("localhost", "8888", handleMessage);
  }

  void handleMessage(String message) {
    Map<String, dynamic> messageMap = json.decode(message);

    switch (messageMap['type']) {
      case 'welcome':
        print("Mensaje de bienvenida recibido: ${messageMap['value']}");
        break;
      case 'newClient':
        if (gameState == GameState.WaitingForPlayers) {
          players.add(messageMap['id']);
          if (players.length >= 4) {
            gameState = GameState.ReadyToStart;
          }
        }
        break;
      case 'data':
        // Maneja el mensaje de datos
        break;
      case 'disconnected':
        // Maneja el mensaje de cliente desconectado
        break;
      default:
        // Maneja cualquier otro tipo de mensaje
        break;
    }
  }

  void startGame() {
    gameState = GameState.Playing;
    player = Player();
    add(Sky());
    add(ScreenHitbox());
    add(player);
  }

  void gameover() {
    pauseEngine();
    gameState = GameState.GameOver;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameState == GameState.Playing) {
      speed += 10 * dt;
      _timeSinceBox += dt;

      if (_timeSinceBox > _boxInterval) {
        add(BoxStack(isBottom: random.nextBool()));
        _timeSinceBox = 0;
      }

      // Envia un mensaje "move" al servidor cada vez que se actualice el juego
      sendMoveMessage();
    }
  }

  void sendMoveMessage() {
    Map<String, dynamic> moveData = {
      'x': player.x,
      'y': player.y,
    };

    sendMessageToServer('move', moveData);
  }

  void sendMessageToServer(String type, Map<String, dynamic> data) {
    Map<String, dynamic> message = {
      'type': type,
      ...data,
    };

    String jsonMessage = json.encode(message);

    webSocketHandler.sendMessage(jsonMessage);
  }

  @override
  void onTap() {
    super.onTap();
    player.fly();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (gameState == GameState.WaitingForPlayers ||
        gameState == GameState.ReadyToStart) {
      // Renderiza la lista de jugadores esperando
      renderWaitingPlayers(canvas);
    } else if (gameState == GameState.ReadyToStart) {
      // Renderiza el botón para comenzar el juego
      renderStartButton(canvas);
    }
  }

  void renderWaitingPlayers(Canvas canvas) {
    // Renderiza la lista de jugadores esperando
    // Puedes personalizar el aspecto de esta lista según tus necesidades
    final textStyle = TextStyle(color: BasicPalette.white.color);
    final textSpan = TextSpan(
      text: 'Jugadores Esperando:\n',
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: size.x);

    Offset offset = Offset(10, 10);
    textPainter.paint(canvas, offset);

    final playerList = players.join('\n');
    final playerListSpan = TextSpan(
      text: playerList,
      style: textStyle,
    );
    final playerListPainter = TextPainter(
      text: playerListSpan,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    playerListPainter.layout(minWidth: 0, maxWidth: size.x);
    offset = offset.translate(0, textPainter.size.height);
    playerListPainter.paint(canvas, offset);
  }

  void renderStartButton(Canvas canvas) {
    // Renderiza un botón para comenzar el juego
    // Puedes personalizar el aspecto de este botón según tus necesidades
    final paint = BasicPalette.white.paint();
    final buttonRect = Rect.fromLTWH(50, 50, 200, 50);
    canvas.drawRect(buttonRect, paint);

    final textStyle = TextStyle(color: BasicPalette.black.color);
    final textSpan = TextSpan(
      text: 'Comenzar Juego',
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: buttonRect.width);
    final textOffset = Offset(
        buttonRect.left + (buttonRect.width - textPainter.width) / 2,
        buttonRect.top + (buttonRect.height - textPainter.height) / 2);
    textPainter.paint(canvas, textOffset);
  }
}

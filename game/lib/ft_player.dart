import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import 'ft_game.dart';

class FtPlayer extends SpriteComponent
    with KeyboardHandler, CollisionCallbacks, HasGameReference<FtGame> {
  FtPlayer({required this.id, required super.position, required this.color})
      : super(size: Vector2.all(64), anchor: Anchor.center);

  String id = "";
  Color color = const Color.fromARGB(255, 175, 175, 175);

  Vector2 previousPosition = Vector2.zero();
  double yVelocity = 0; // Velocidad vertical
  final double gravity = 400; // Gravedad para la simulación de salto
  final double jumpVelocity = -300; // Velocidad inicial del salto

  @override
  Future<void> onLoad() async {
    priority = 1; // Dibuixar-lo per sobre de tot
    sprite = await Sprite.load('player.png');
    size = Vector2.all(64);
    add(CircleHitbox());
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Modificar la velocidad vertical al presionar la tecla espacio
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.space) {
      yVelocity = jumpVelocity; // Asignar velocidad de salto
    }

    return false;
  }

  @override
  void update(double dt) {
    // Aplicar la gravedad al movimiento vertical
    yVelocity += gravity * dt;

    // Actualizar la posición vertical
    position.y += yVelocity * dt;

    // Limitar la posición vertical para evitar que el jugador caiga fuera de la pantalla
    final groundY = game.size.y - size.y / 2; // Altura del suelo
    if (position.y > groundY) {
      position.y = groundY;
      yVelocity = 0;
    }
    final topY = size.y / 2; // Posición máxima en el eje y
    if (position.y < topY) {
      position.y = topY;
      yVelocity = 0;
    }

    // Enviar las coordenadas al servidor
    game.websocket.sendMessage(
      '{"type": "move", "x": ${position.x}, "y": ${position.y}}',
    );

    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is FtPlayer) {
      return;
    }

    super.onCollision(intersectionPoints, other);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Preparar el Paint con color y opacidad
    final paint = Paint()
      ..colorFilter =
          ColorFilter.mode(color.withOpacity(0.5), BlendMode.srcATop)
      ..filterQuality = FilterQuality.high;

    // Renderizar el sprite con el Paint personalizado
    sprite?.render(canvas, size: size, overridePaint: paint);
  }
}

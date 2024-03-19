import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';

import 'appdata.dart';
import 'game.dart';

class Player extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameRef<FlappyEmber> {
  final String numPnj;
  final String playerId;
  final AppData appData; // Instancia de AppData
  final bool playeable;
  bool colision = false;

  Player(this.numPnj, this.playerId, this.appData, this.playeable)
      : super(size: Vector2(100, 100), position: Vector2(100, 100));

  @override
  Future<void>? onLoad() async {
    try {
      final image = await Flame.images.load('ember$numPnj.png');
      animation = SpriteAnimation.fromFrameData(
        image,
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.10,
          textureSize: Vector2.all(16),
        ),
      );
    } catch (e) {
      // Si no se puede cargar la imagen 'ember$numPnj.png', se intentará cargar 'ember$numPnj.1.png'
      print('Error cargando la imagen de animación: $e');
      final altImage = await Flame.images.load('ember$numPnj.1.png');
      animation = SpriteAnimation.fromFrameData(
        altImage,
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.10,
          textureSize: Vector2.all(16),
        ),
      );
    }

    // Agregar la hitbox solo si playeable es true
    if (playeable) {
      add(CircleHitbox());
    }
  }

  @override
  void onCollisionStart(_, __) {
    super.onCollisionStart(_, __);
    appData.sendcolision(position.x.toInt(), position.y.toInt(), playerId);
    colision = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (colision) {
      print("aaaaaaaaaaaa");
    } else {
      position.y += 200 * dt;

      // Enviamos la posición al servidor utilizando la instancia de AppData
      appData.sendPosition(position.x.toInt(), position.y.toInt(), playerId);
    }
  }

  void fly() {
    final effect = MoveByEffect(
        Vector2(0, -100),
        EffectController(
          duration: 0.5,
          curve: Curves.decelerate,
        ));

    add(effect);
    appData.sendtap(playerId);
  }
}

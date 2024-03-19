import 'package:flame/components.dart';
import 'package:flame/flame.dart';

class Sky extends SpriteComponent {
  Sky() : super(priority: -1);

  @override
  Future<void> onLoad() async {
    try {
      final image = await Flame.images.load('parallax/bg_sky.png');
      sprite = Sprite(image);
    } catch (e) {
      // Si no se puede cargar la imagen 'parallax/bg_sky.png', se intentará cargar una imagen alternativa
      print('Error cargando la imagen de fondo: $e');
      final altImage = await Flame.images.load('parallax/bg_sky1.png');
      sprite = Sprite(altImage);
    }
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = gameSize;
  }
}

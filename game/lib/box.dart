import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';

class Box extends SpriteComponent {
  static Vector2 initialSize = Vector2.all(150);
  Box({super.position}) : super(size: initialSize);

  @override
  Future<void>? onLoad() async {
    try {
      final image = await Flame.images.load('boxes/1.png');
      sprite = Sprite(image);
    } catch (e) {
      // Si no se puede cargar la imagen '1.png', se intentará cargar '1.1.png'
      print('Error cargando la imagen: $e');
      final altImage = await Flame.images.load('boxes/1.1.png');
      sprite = Sprite(altImage);
    }

    add(RectangleHitbox());
  }
}


import 'package:flame/game.dart';
import 'package:flame/components.dart';

import 'player.dart';

class ShopGame extends FlameGame {
  late PlayerComponent player;

  static const double worldWidth = 2400;
  static const double worldHeight = 600;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.viewfinder.anchor = Anchor.center;

    camera.viewport = FixedResolutionViewport(
      resolution: Vector2(1280, 600),
    );

    final backgroundImage = await images.load(
      'street_area_1.png',
    );

    final background = SpriteComponent(
      sprite: Sprite(backgroundImage),
      position: Vector2.zero(),
      size: Vector2(worldWidth, worldHeight),
      anchor: Anchor.topLeft,
    );

    world.add(background);

    player = PlayerComponent(
      loadImage: images.load,
    );

    player.position = Vector2(400, 550);

    world.add(player);

    camera.viewfinder.position = Vector2(640, 300);
  }

  void moveLeft() {
    player.moveLeft();
  }

  void moveRight() {
    player.moveRight();
  }

  void stopPlayer() {
    player.stopMoving();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isLoaded) {
      final cameraX = player.position.x
          .clamp(640, worldWidth - 640)
          .toDouble();

      camera.viewfinder.position = Vector2(
        cameraX,
        300,
      );
    }
  }
}

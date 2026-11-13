
import 'dart:ui' as ui;
import 'package:flame/components.dart';

class PlayerComponent extends SpriteAnimationComponent {
  final Future<ui.Image> Function(String) loadImage;

  late SpriteAnimation idleAnimation;
  late SpriteAnimation rightAnimation;
  late SpriteAnimation leftAnimation;

  double direction = 0;
  double speed = 220;

  PlayerComponent({
    required this.loadImage,
  }) : super(
          size: Vector2(100, 160),
          anchor: Anchor.bottomCenter,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final idleImage = await loadImage('arian_idle.png');

    idleAnimation = SpriteAnimation([
      SpriteAnimationFrame(
        Sprite(idleImage),
        stepTime: 1,
      ),
    ]);

    rightAnimation = await _loadAnimation('arian_right_');
    leftAnimation = await _loadAnimation('arian_left_');

    animation = idleAnimation;
  }

  Future<SpriteAnimation> _loadAnimation(String prefix) async {
    final frames = <SpriteAnimationFrame>[];

    for (int i = 1; i <= 4; i++) {
      final image = await loadImage('${prefix}$i.png');

      frames.add(
        SpriteAnimationFrame(
          Sprite(image),
          stepTime: 0.12,
        ),
      );
    }

    return SpriteAnimation(frames);
  }

  void moveLeft() {
    direction = -1;
    animation = leftAnimation;
  }

  void moveRight() {
    direction = 1;
    animation = rightAnimation;
  }

  void stopMoving() {
    direction = 0;
    animation = idleAnimation;
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.x += direction * speed * dt;

    position.x = position.x.clamp(80, 2320).toDouble();
  }
}

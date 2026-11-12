import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class ShopGame extends FlameGame {
  final double worldWidth = 4000; 
  final double singleAreaWidth = 1000;
  
  late SpriteAnimationComponent player;
  late SpriteAnimation walkLeftAnimation;
  late SpriteAnimation walkRightAnimation;
  late SpriteAnimation idleAnimation;

  double playerX = 400;
  bool moveLeft = false;
  bool moveRight = false;
  bool isMoving = false;

  VoidCallback? onBillboardTap;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;

    // 1. لود کردن ۴ تا عکس منطقه
    final List<String> areaImages = [
      'street_area_1.png', 'street_area_2.png', 'street_area_3.png', 'street_area_4.png',
    ];

    for (int i = 0; i < areaImages.length; i++) {
      try {
        final image = await images.load(areaImages[i]);
        double aspectRatio = image.height / image.width;
        double finalHeight = singleAreaWidth * aspectRatio;
        world.add(SpriteComponent(
          sprite: Sprite(image),
          size: Vector2(singleAreaWidth, finalHeight), 
          position: Vector2(i * singleAreaWidth, 0), 
          priority: -10,
        ));
      } catch (e) {
        world.add(RectangleComponent(
          size: Vector2(singleAreaWidth, size.y),
          position: Vector2(i * singleAreaWidth, 0),
          paint: Paint()..color = Colors.grey.shade800,
          priority: -10,
        ));
      }
    }

    // 2. لود کردن آرین
    try {
      final idleSprite = Sprite(await images.load('arian_idle.png'));
      final leftSprites = [
        Sprite(await images.load('arian_left_1.png')),
        Sprite(await images.load('arian_left_2.png')),
        Sprite(await images.load('arian_left_3.png')),
        Sprite(await images.load('arian_left_4.png')),
      ];
      final rightSprites = [
        Sprite(await images.load('arian_right_1.png')),
        Sprite(await images.load('arian_right_2.png')),
        Sprite(await images.load('arian_right_3.png')),
        Sprite(await images.load('arian_right_4.png')),
      ];

      idleAnimation = SpriteAnimation.spriteList([idleSprite], stepTime: 1.0);
      walkLeftAnimation = SpriteAnimation.spriteList(leftSprites, stepTime: 0.1, loop: true);
      walkRightAnimation = SpriteAnimation.spriteList(rightSprites, stepTime: 0.1, loop: true);

      player = SpriteAnimationComponent(
        animation: idleAnimation, 
        size: Vector2(110, 170), 
        anchor: Anchor.bottomCenter,
      );
      
      player.position = Vector2(playerX, size.y - 80); 
      player.priority = 10;
      world.add(player);
    } catch (e) {
      debugPrint("عکس‌های آرین پیدا نشد: $e");
    }

    // 3. اضافه کردن بیلبوردها به دنیای بازی (روی پنجره‌های طبقه دوم)
    world.add(BillboardComponent(position: Vector2(250, 160)));
    world.add(BillboardComponent(position: Vector2(1250, 160)));
    world.add(BillboardComponent(position: Vector2(2250, 160)));
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (moveLeft) {
      isMoving = true;
      playerX -= 250 * dt;
      if (playerX < 70) playerX = 70;
      if (player.animation != walkLeftAnimation) player.animation = walkLeftAnimation;
    } else if (moveRight) {
      isMoving = true;
      playerX += 250 * dt;
      if (playerX > worldWidth - 70) playerX = worldWidth - 70;
      if (player.animation != walkRightAnimation) player.animation = walkRightAnimation;
    } else {
      if (isMoving) {
        isMoving = false;
        player.animation = idleAnimation;
      }
    }
    
    player.position = Vector2(playerX, size.y - 80);

    double targetCameraX = playerX - (size.x / 2);
    if (targetCameraX < 0) targetCameraX = 0;
    if (targetCameraX > worldWidth - size.x) targetCameraX = worldWidth - size.x;
    
    camera.viewfinder.position = Vector2(targetCameraX, 0);
  }
}

// 🌟 کامپوننت بیلبورد (داخل Flame)
class BillboardComponent extends PositionComponent with TapCallbacks, HasGameReference<ShopGame> {
  double _timer = 0;
  bool _isTextVisible = true;
  late TextComponent _textComponent;

  BillboardComponent({required Vector2 position})
      : super(position: position, size: Vector2(160, 90), anchor: Anchor.bottomLeft);

  @override
  Future<void> onLoad() async {
    // بدنه مشکی بیلبورد
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.black,
    ));

    // حاشیه سفید
    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = Colors.white,
    ));

    // متن بیلبورد
    _textComponent = TextComponent(
      text: "این فضا برای\nتبلیغات شماست!",
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2),
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
    add(_textComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    if (_timer > 0.5) {
      _timer = 0;
      _isTextVisible = !_isTextVisible;
      _textComponent.textRenderer = TextPaint(
        style: TextStyle(
          color: _isTextVisible ? Colors.amber : Colors.amber.withOpacity(0.2),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.onBillboardTap?.call();
  }
}
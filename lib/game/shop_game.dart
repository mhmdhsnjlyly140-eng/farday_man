import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class ShopGame extends FlameGame {
  final double worldWidth = 7000; 
  final double singleAreaWidth = 1000;
  
  late SpriteAnimationComponent player;
  late SpriteAnimation walkLeftAnimation;
  late SpriteAnimation walkRightAnimation;
  late SpriteAnimation idleAnimation;

  double playerX = 400;
  bool moveLeft = false;
  bool moveRight = false;
  bool isMoving = false;

  // 🌟 دکمه‌های تعامل
  VoidCallback? onShopEnter;
  VoidCallback? onHomeEnter;
  VoidCallback? onTaxiEnter;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;

    // 🌟 لود کردن ۷ منطقه (۴ منطقه قبلی + منطقه طلافروشی + منطقه بهار + منطقه مدرسه)
    final List<String> areaImages = [
      'street_area_1.png',
      'street_area_2.png',
      'street_area_3.png',
      'street_area_4.png',
      'street_area_7.png', // منطقه طلافروشی و کافه
      'street_area_5.jpg', // منطقه بهار (نانوایی و ساعت)
      'street_area_6.png', // منطقه مدرسه و کتابخانه
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

    // 🌟 3. دکمه‌های تعامل (روی در مغازه، خونه، ایستگاه تاکسی)
    world.add(EnterButtonComponent(
      position: Vector2(350, size.y - 160),
      onTap: () => onShopEnter?.call(),
    ));

    world.add(EnterButtonComponent(
      position: Vector2(2500, size.y - 160),
      onTap: () => onHomeEnter?.call(),
    ));
    
    // دکمه تاکسی (در منطقه ۱ یا ۲)
    world.add(EnterButtonComponent(
      position: Vector2(1800, size.y - 160), 
      onTap: () => onTaxiEnter?.call(),
    ));
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

// 🌟 کامپوننت دکمه‌ی ورود
class EnterButtonComponent extends PositionComponent with TapCallbacks {
  final VoidCallback onTap;

  EnterButtonComponent({required Vector2 position, required this.onTap})
      : super(position: position, size: Vector2(40, 40), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(CircleComponent(
      radius: 20,
      paint: Paint()..color = Colors.white.withOpacity(0.8),
    ));
    add(RectangleComponent(
      size: Vector2(10, 10),
      position: Vector2(15, 15),
      paint: Paint()..color = Colors.blueAccent,
    ));
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap();
  }
}
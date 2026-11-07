import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class ShopGame extends FlameGame {
  late SpriteComponent background;
  late SpriteAnimationComponent player;
  late SpriteAnimation walkLeftAnimation;
  late SpriteAnimation walkRightAnimation;

  double playerX = 200;
  bool moveLeft = false;
  bool moveRight = false;
  bool isMoving = false;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;

    // 1. لود عکس اول
    try {
      final bgImage = await images.load('street_area_1.png');
      background = SpriteComponent(
        sprite: Sprite(bgImage),
        size: size, 
        position: Vector2(0, 0),
        priority: -10,
      );
      world.add(background);
    } catch (e) {
      debugPrint("عکس پس‌زمینه پیدا نشد");
    }

    // 2. لود آرین و انیمیشن‌ها
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

      walkLeftAnimation = SpriteAnimation.spriteList(leftSprites, stepTime: 0.08, loop: true);
      walkRightAnimation = SpriteAnimation.spriteList(rightSprites, stepTime: 0.08, loop: true);

      player = SpriteAnimationComponent(
        animation: SpriteAnimation.spriteList([idleSprite], stepTime: 1.0), 
        size: Vector2(140, 220), // سایز متناسب آرین
        anchor: Anchor.bottomCenter,
      );
      
      // 🌟 آرین را دقیقاً روی پیاده‌رو می‌نشانیم (130 پیکسل از پایین)
      player.position = Vector2(playerX, size.y - 130); 
      player.priority = 10;
      world.add(player);

    } catch (e) {
      debugPrint("عکس‌های آرین پیدا نشد: $e");
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (moveLeft || moveRight) {
      isMoving = true;
      double speed = 250;
      
      if (moveLeft) {
        playerX -= speed * dt;
        if (playerX < 70) {
          playerX = 70;
          moveLeft = false; 
        }
        player.animation = walkLeftAnimation..stepTime = 0.08;
      } else if (moveRight) {
        playerX += speed * dt;
        if (playerX > size.x - 70) {
          playerX = size.x - 70;
          moveRight = false; 
        }
        player.animation = walkRightAnimation..stepTime = 0.08;
      }
      
      player.position = Vector2(playerX, size.y - 130);

    } else {
      if (isMoving) {
        isMoving = false;
        player.animation!.stepTime = 0; 
      }
    }
  }

  void changeAreaImage(String imagePath) async {
    try {
      final newImage = await images.load(imagePath);
      background.sprite = Sprite(newImage);
    } catch (e) {
      debugPrint("عکس $imagePath پیدا نشد");
    }
  }
}
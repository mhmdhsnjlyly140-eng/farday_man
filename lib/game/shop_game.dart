import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class ShopGame extends FlameGame {
  final double worldWidth = 4000; 
  final double singleAreaWidth = 1000;
  
  late SpriteAnimationComponent player;
  late SpriteAnimation walkLeftAnimation;
  late SpriteAnimation walkRightAnimation;

  double playerX = 400;
  bool moveLeft = false;
  bool moveRight = false;
  bool isMoving = false;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;

    // 1. ساخت پس‌زمینه
    final List<String> areaImages = [
      'street_area_1.png',
      'street_area_2.png',
      'street_area_3.png',
      'street_area_4.png',
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
        debugPrint("عکس پس‌زمینه پیدا نشد: $e");
      }
    }

    // 2. لود آرین
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

      walkLeftAnimation = SpriteAnimation.spriteList(leftSprites, stepTime: 0.1, loop: true);
      walkRightAnimation = SpriteAnimation.spriteList(rightSprites, stepTime: 0.1, loop: true);

      player = SpriteAnimationComponent(
        animation: SpriteAnimation.spriteList([idleSprite], stepTime: 1.0), 
        size: Vector2(160, 250), 
        anchor: Anchor.bottomCenter,
      );
      
      // 🌟 ارتفاع درست آرین روی پیاده‌رو
      player.position = Vector2(playerX, size.y - 100); 
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
        if (playerX < 80) playerX = 80;
        player.animation = walkLeftAnimation..stepTime = 0.1;
      } else if (moveRight) {
        playerX += speed * dt;
        if (playerX > worldWidth - 80) playerX = worldWidth - 80;
        player.animation = walkRightAnimation..stepTime = 0.1;
      }
      
      player.position = Vector2(playerX, size.y - 100);

      // 🌟 حرکت دوربین همراه با آرین
      double targetCameraX = playerX - (size.x / 2);
      if (targetCameraX < 0) targetCameraX = 0;
      if (targetCameraX > worldWidth - size.x) targetCameraX = worldWidth - size.x;
      
      camera.viewfinder.position = Vector2(targetCameraX, 0);

    } else {
      if (isMoving) {
        isMoving = false;
        player.animation!.stepTime = 0; 
      }
    }
  }

  void changeBackground(String imagePath) {}
}
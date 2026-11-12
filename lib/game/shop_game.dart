import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class ShopGame extends FlameGame {
  late SpriteComponent background;
  late SpriteAnimationComponent player;
  late SpriteAnimation walkLeftAnimation;
  late SpriteAnimation walkRightAnimation;
  late SpriteAnimation idleAnimation;

  double playerX = 400;
  bool moveLeft = false;
  bool moveRight = false;
  bool isMoving = false;

  int currentArea = 0;
  bool get isNearRightEdge => playerX >= size.x - 90;

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

      idleAnimation = SpriteAnimation.spriteList([idleSprite], stepTime: 1.0);
      walkLeftAnimation = SpriteAnimation.spriteList(leftSprites, stepTime: 0.1, loop: true);
      walkRightAnimation = SpriteAnimation.spriteList(rightSprites, stepTime: 0.1, loop: true);

      player = SpriteAnimationComponent(
        animation: idleAnimation, 
        size: Vector2(110, 170), 
        anchor: Anchor.bottomCenter,
      );
      
      player.position = Vector2(playerX, size.y - 70); 
      player.priority = 10;
      world.add(player);

    } catch (e) {
      debugPrint("عکس‌های آرین پیدا نشد: $e");
    }
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
      if (playerX > size.x - 70) playerX = size.x - 70;
      if (player.animation != walkRightAnimation) player.animation = walkRightAnimation;
    } else {
      if (isMoving) {
        isMoving = false;
        player.animation = idleAnimation;
      }
    }
    
    player.position = Vector2(playerX, size.y - 70);
  }

  // 🌟 تابع تغییر منطقه
  void changeArea(int newArea, String imagePath) async {
    currentArea = newArea;
    playerX = size.x / 2; // آرین بره وسط
    player.position = Vector2(playerX, size.y - 70);

    try {
      final newImage = await images.load(imagePath);
      background.sprite = Sprite(newImage);
    } catch (e) {
      debugPrint("عکس $imagePath پیدا نشد");
    }
  }
}
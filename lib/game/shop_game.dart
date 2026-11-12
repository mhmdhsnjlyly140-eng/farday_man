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

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;

    // 1. لود عکس پس‌زمینه
    try {
      final bgImage = await images.load('street_area_1.png');
      
      // 🌟 محاسبه ارتفاع بر اساس نسبت ابعاد عکس تا کشیده نشه
      double aspectRatio = bgImage.height / bgImage.width;
      double finalHeight = size.x * aspectRatio; // عرض رو برابر با عرض گوشی می‌ذاریم

      background = SpriteComponent(
        sprite: Sprite(bgImage),
        size: Vector2(size.x, finalHeight), // عرض و ارتفاع دقیق
        position: Vector2(0, 0),
        priority: -10,
      );
      world.add(background);
    } catch (e) {
      debugPrint("عکس پس‌زمینه پیدا نشد");
      world.add(RectangleComponent(
        size: size,
        paint: Paint()..color = Colors.grey.shade800,
        priority: -10,
      ));
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

      player.position = Vector2(playerX, size.y - 80);
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
      if (playerX > size.x - 70) playerX = size.x - 70; // محدودیت در صفحه
      if (player.animation != walkRightAnimation) player.animation = walkRightAnimation;
    } else {
      if (isMoving) {
        isMoving = false;
        player.animation = idleAnimation;
      }
    }

    player.position = Vector2(playerX, size.y - 80);

    // 🌟 حرکت دوربین (چون عکس به اندازه صفحه است، دوربین نیاز نیست، ولی برای آینده نگه می‌داریم)
    double targetCameraX = playerX - (size.x / 2);
    if (targetCameraX < 0) targetCameraX = 0;
    if (targetCameraX > size.x * 4 - size.x) targetCameraX = size.x * 4 - size.x;
    camera.viewfinder.position = Vector2(targetCameraX, 0);
  }

  void changeAreaImage(String imagePath) async {
    try {
      final newImage = await images.load(imagePath);
      background.sprite = Sprite(newImage);
      playerX = size.x / 2;
      player.position = Vector2(playerX, size.y - 80);
    } catch (e) {
      debugPrint("عکس $imagePath پیدا نشد");
    }
  }
}
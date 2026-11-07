import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class ShopGame extends FlameGame {
  // عرض کل دنیا (۴ منطقه × ۱۰۰۰ پیکسل)
  final double worldWidth = 4000; 
  final double singleAreaWidth = 1000;
  
  late SpriteAnimationComponent player;
  late SpriteAnimation walkLeftAnimation;
  late SpriteAnimation walkRightAnimation;

  // مختصات آرین در دنیا
  double playerX = 400;
  bool moveLeft = false;
  bool moveRight = false;
  bool isMoving = false;

  @override
  Future<void> onLoad() async {
    // دوربین آزاد باشه تا بتونه حرکت کنه
    camera.viewfinder.anchor = Anchor.topLeft;

    // 🌟 1. ساخت پس‌زمینه‌ی بلند (۴ تصویر رو به هم می‌چسبونیم)
    final List<String> areaImages = [
      'street_area_1.png',
      'street_area_2.png',
      'street_area_3.png',
      'street_area_4.png',
    ];

    for (int i = 0; i < areaImages.length; i++) {
      try {
        final image = await images.load(areaImages[i]);
        world.add(SpriteComponent(
          sprite: Sprite(image),
          size: Vector2(singleAreaWidth, size.y), 
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

    // 🌟 2. لود کردن آرین و ساختن انیمیشن‌ها
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

      // 🌟 سایز آرین رو کوچیک کردیم (160x250)
      player = SpriteAnimationComponent(
        animation: SpriteAnimation.spriteList([idleSprite], stepTime: 1.0), 
        size: Vector2(160, 250),
        anchor: Anchor.bottomCenter,
      );
      
      // تنظیم ارتفاع آرین روی پیاده‌رو
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

    if (moveLeft || moveRight) {
      isMoving = true;
      double speed = 250;
      
      if (moveLeft) {
        playerX -= speed * dt;
        if (playerX < 80) playerX = 80;
        player.animation = walkLeftAnimation..stepTime = 0.08;
      } else if (moveRight) {
        playerX += speed * dt;
        if (playerX > worldWidth - 80) playerX = worldWidth - 80;
        player.animation = walkRightAnimation..stepTime = 0.08;
      }
      
      player.position = Vector2(playerX, size.y - 80);

    } else {
      if (isMoving) {
        isMoving = false;
        player.animation!.stepTime = 0; // توقف انیمیشن
      }
    }

    // 🌟 3. حرکت دوربین همراه با آرین
    // دوربین همیشه آرین رو در مرکز صفحه نگه می‌داره
    double targetCameraX = playerX - (size.x / 2);
    
    // محدودیت دوربین در لبه‌های دنیا
    if (targetCameraX < 0) targetCameraX = 0;
    if (targetCameraX > worldWidth - size.x) targetCameraX = worldWidth - size.x;
    
    // حرکت نرم دوربین به سمت آرین
    camera.viewfinder.position = Vector2(
      camera.viewfinder.position.x + (targetCameraX - camera.viewfinder.position.x) * dt * 5,
      0,
    );
  }

  // این تابع رو برای سازگاری با کدهای قبلی نگه می‌داریم (خالی)
  void changeBackground(String imagePath) {}
}
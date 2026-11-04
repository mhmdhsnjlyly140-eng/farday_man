import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'shop_game.dart'; // برای دسترسی به عکس‌های بازی

class Player extends PositionComponent with HasGameReference<ShopGame> {
  double speed = 250.0; 
  bool moveLeft = false;
  bool moveRight = false;

  late SpriteAnimationComponent animationComponent;
  late SpriteAnimation walkAnimation;

  Player() : super(size: Vector2(140, 230), anchor: Anchor.bottomCenter);

  @override
  Future<void> onLoad() async {
    // 1. عکس‌ها رو اینجا لود می‌کنیم
    final walkImages = [
      await game.images.load('arian_walk_1.png'),
      await game.images.load('arian_walk_2.png'),
      await game.images.load('arian_walk_3.png'),
      await game.images.load('arian_walk_4.png'),
    ];

    // 2. انیمیشن رو می‌سازیم
    walkAnimation = SpriteAnimation.spriteList(
      walkImages.map((img) => Sprite(img)).toList(),
      stepTime: 0.15,
      loop: true,
    );

    // 3. کامپوننت تصویری رو می‌سازیم
    animationComponent = SpriteAnimationComponent(
      animation: walkAnimation,
      size: Vector2(140, 230),
      anchor: Anchor.bottomCenter,
    );
    
    // 4. انیمیشن رو در ابتدا متوقف نگه می‌داریم
    animationComponent.animation!.stepTime = 0; 
    
    // 5. اضافه کردن به بازیکن
    add(animationComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);

    double direction = 0;
    if (moveLeft) direction -= 1;
    if (moveRight) direction += 1;

    if (direction != 0) {
      position.x += direction * speed * dt;
      
      // محدودیت حرکت در صفحه
      if (position.x < 70) position.x = 70;
      if (position.x > game.size.x - 70) position.x = game.size.x - 70;

      animationComponent.animation!.stepTime = 0.15; // راه رفتن
      
      if (direction < 0) {
        animationComponent.scale.x = -1;
      } else {
        animationComponent.scale.x = 1;
      }
    } else {
      animationComponent.animation!.stepTime = 0; // توقف
    }
  }
}
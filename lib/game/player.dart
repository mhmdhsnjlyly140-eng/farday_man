import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class Player extends PositionComponent {
  double speed = 150.0;
  bool moveLeft = false;
  bool moveRight = false;
  bool isMoving = false;

  late SpriteAnimationComponent animationComponent;
  late SpriteAnimation walkAnimation;

  Player() : super(size: Vector2(140, 230), anchor: Anchor.bottomCenter);

  @override
  Future<void> onLoad() async {
    // در نسخه جدید Flame، برای لود عکس‌ها از داخل کامپوننت باید به این شکل عمل کنیم
    final walkImages = [
      await game.images.load('arian_walk_1.png'),
      await game.images.load('arian_walk_2.png'),
      await game.images.load('arian_walk_3.png'),
      await game.images.load('arian_walk_4.png'),
    ];

    walkAnimation = SpriteAnimation.spriteList(
      walkImages.map((img) => Sprite(img)).toList(),
      stepTime: 0.15,
      loop: true,
    );

    animationComponent = SpriteAnimationComponent(
      animation: walkAnimation,
      size: Vector2(140, 230),
      anchor: Anchor.bottomCenter,
    );
    
    // 👈 راه حل جدید: به جای pause() و resume()، از تنظیم سرعت استفاده می‌کنیم
    animationComponent.animation = walkAnimation;
    animationComponent.animationSpeed = 0; // سرعت صفر یعنی متوقف
    
    add(animationComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);

    double direction = 0;
    if (moveLeft) direction -= 1;
    if (moveRight) direction += 1;

    if (direction != 0) {
      isMoving = true;
      position.x += direction * speed * dt;
      
      if (position.x < 100) position.x = 100;
      if (position.x > 700) position.x = 700;

      // 👈 سرعت انیمیشن رو 1 می‌کنیم تا راه بره
      animationComponent.animationSpeed = 1; 

      if (direction < 0) {
        animationComponent.scale.x = -1;
      } else {
        animationComponent.scale.x = 1;
      }

    } else {
      isMoving = false;
      // 👈 سرعت انیمیشن رو صفر می‌کنیم تا وایسه
      animationComponent.animationSpeed = 0;
    }
  }
}
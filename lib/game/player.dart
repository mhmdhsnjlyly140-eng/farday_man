import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class Player extends PositionComponent {
  double speed = 250.0; // سرعت رو یکم بیشتر کردیم
  bool moveLeft = false;
  bool moveRight = false;
  bool isMoving = false;

  late SpriteAnimationComponent animationComponent;
  late SpriteAnimation walkAnimation;

  Player(List<Sprite> walkSprites) : super(size: Vector2(140, 230), anchor: Anchor.bottomCenter) {
    walkAnimation = SpriteAnimation.spriteList(
      walkSprites,
      stepTime: 0.15,
      loop: true,
    );
  }

  @override
  Future<void> onLoad() async {
    animationComponent = SpriteAnimationComponent(
      animation: walkAnimation,
      size: Vector2(140, 230),
      anchor: Anchor.bottomCenter,
    );
    // در ابتدا انیمیشن متوقف باشه
    animationComponent.animation!.stepTime = 0; 
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
      
      // محدودیت حرکت (با توجه به سایز متغیر صفحه، از لبه‌ها فاصله می‌گیریم)
      final screenWidth = (parent as FlameGame).size.x;
      if (position.x < 70) position.x = 70;
      if (position.x > screenWidth - 70) position.x = screenWidth - 70;

      animationComponent.animation!.stepTime = 0.15; // انیمیشن راه رفتن

      if (direction < 0) {
        animationComponent.scale.x = -1; // چپ
      } else {
        animationComponent.scale.x = 1;  // راست
      }

    } else {
      isMoving = false;
      animationComponent.animation!.stepTime = 0; // توقف انیمیشن
    }
  }
}
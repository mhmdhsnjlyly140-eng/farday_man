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

  // 👈 عکس‌ها رو از بیرون (توی ShopGame) بهش پاس می‌دیم
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

      // پخش انیمیشن
      animationComponent.animation = walkAnimation;

      if (direction < 0) {
        animationComponent.scale.x = -1;
      } else {
        animationComponent.scale.x = 1;
      }

    } else {
      isMoving = false;
      // برای متوقف کردن انیمیشن، فریم رو صفر می‌کنیم
      animationComponent.animation = walkAnimation;
      animationComponent.animation!.stepTime = 0; // ترفند متوقف کردن
    }
  }
}
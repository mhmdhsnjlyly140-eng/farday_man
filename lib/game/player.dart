import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class Player extends PositionComponent with HasGameReference<ShopGame> {
  double speed = 150.0;
  bool moveLeft = false;
  bool moveRight = false;
  bool isMoving = false;

  late SpriteAnimationComponent animationComponent;
  late SpriteAnimation walkAnimation;

  Player() : super(size: Vector2(140, 230), anchor: Anchor.bottomCenter);

  @override
  Future<void> onLoad() async {
    // 👈 اصلاح شد: به جای game.images از game.images استفاده می‌کنیم (با HasGameReference)
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
    
    // 👈 اصلاح شد: به جای playing از pause() استفاده می‌کنیم
    animationComponent.animation = walkAnimation;
    animationComponent.animation!.pause(); 
    
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

      // 👈 اصلاح شد: از resume() برای پخش استفاده می‌کنیم
      animationComponent.animation!.resume();

      if (direction < 0) {
        animationComponent.scale.x = -1;
      } else {
        animationComponent.scale.x = 1;
      }

    } else {
      isMoving = false;
      // 👈 اصلاح شد: از pause() برای توقف استفاده می‌کنیم
      animationComponent.animation!.pause();
      animationComponent.animation!.reset(); // برگشت به فریم اول
    }
  }
}
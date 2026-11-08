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
  
  late SpriteComponent uncle;

  double playerX = 400;
  bool moveLeft = false;
  bool moveRight = false;
  bool isMoving = false;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;

    // 1. لود کردن عکس پس‌زمینه اول
    try {
      final bgImage = await images.load('street_area_1.png');
      background = SpriteComponent(
        sprite: Sprite(bgImage),
        size: _calculateCoverSize(bgImage),
        position: Vector2(0, 0),
        priority: -10,
      );
      world.add(background);
    } catch (e) {
      debugPrint("عکس پس‌زمینه پیدا نشد");
    }

    // 2. لود کردن آرین
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
        size: Vector2(130, 200), 
        anchor: Anchor.bottomCenter,
      );
      
      player.position = Vector2(playerX, size.y - 80); 
      player.priority = 10;
      world.add(player);

    } catch (e) {
      debugPrint("عکس‌های آرین پیدا نشد: $e");
    }

    // 3. لود کردن عمو رضا
    try {
      final uncleImage = await images.load('uncle_idle.png');
      uncle = SpriteComponent(
        sprite: Sprite(uncleImage),
        size: Vector2(130, 200),
        position: Vector2(size.x * 0.7, size.y - 80), 
        priority: 10,
      );
      uncle.opacity = 0.0; 
      world.add(uncle);
    } catch (e) {
      debugPrint("عکس عمو پیدا نشد: $e");
    }
  }

  // 🌟 تابع محاسبه سایز عکس برای پر کردن صفحه (بدون کشیدگی)
  Vector2 _calculateCoverSize(Image image) {
    double imageRatio = image.width / image.height;
    double screenRatio = size.x / size.y;

    double width, height;

    if (imageRatio > screenRatio) {
      // عکس پهن‌تر از صفحه‌ست (باید ارتفاع رو پر کنه و عرضش بره بیرون)
      height = size.y;
      width = height * imageRatio;
    } else {
      // عکس کشیده‌تر از صفحه‌ست (باید عرض رو پر کنه و ارتفاعش بره بیرون)
      width = size.x;
      height = width / imageRatio;
    }

    return Vector2(width, height);
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
    
    player.position = Vector2(playerX, size.y - 80);
  }

  void changeAreaImage(String imagePath) async {
    try {
      final newImage = await images.load(imagePath);
      background.sprite = Sprite(newImage);
      
      // 🌟 تنظیم سایز عکس جدید طبق همون قانون
      background.size = _calculateCoverSize(newImage);

      if (imagePath == 'home_living_room.png') {
        uncle.opacity = 1.0; 
        uncle.position = Vector2(size.x * 0.7, size.y - 80); 
      } else {
        uncle.opacity = 0.0; 
      }
    } catch (e) {
      debugPrint("عکس $imagePath پیدا نشد");
    }
  }
}
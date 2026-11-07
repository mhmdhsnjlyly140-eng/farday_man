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
  
  // 🌟 عمو رضا
  late SpriteComponent uncle;

  double playerX = 400;
  bool moveLeft = false;
  bool moveRight = false;
  bool isMoving = false;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;

    // 1. عکس پس‌زمینه اولیه
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

    // 3. لود کردن عمو رضا (در ابتدا مخفی است)
    try {
      final uncleImage = await images.load('uncle_idle.png');
      uncle = SpriteComponent(
        sprite: Sprite(uncleImage),
        size: Vector2(130, 200),
        position: Vector2(size.x / 2, size.y - 80), // قرارگیری وسط هال خونه
        priority: 10,
      );
      uncle.visible = false; // 🌟 در ابتدا دیده نمی‌شه
      world.add(uncle);
    } catch (e) {
      debugPrint("عکس عمو پیدا نشد: $e");
    }

    // 4. لود کردن چراغ‌ها (فقط برای خیابون)
    try {
      final lampImage = await images.load('street_lamp.png');
      for (double x = 200; x < size.x * 4; x += 300) {
        world.add(SpriteComponent(
          sprite: Sprite(lampImage),
          size: Vector2(80, 200),
          position: Vector2(x, size.y - 280),
          priority: 20, // روی آرین
        ));
      }
    } catch (e) {
      debugPrint("عکس چراغ پیدا نشد: $e");
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
    
    player.position = Vector2(playerX, size.y - 80);
  }

  // 🌟 تابع تغییر پس‌زمینه (با منطق مخفی/نمایان کردن عمو)
  void changeAreaImage(String imagePath) async {
    try {
      final newImage = await images.load(imagePath);
      background.sprite = Sprite(newImage);

      // اگر وارد هال خونه شدیم، عمو رو نشون بده
      if (imagePath == 'home_living_room.png') {
        uncle.visible = true;
        uncle.position = Vector2(size.x * 0.7, size.y - 80); // سمت راست هال
      } else {
        uncle.visible = false;
      }
    } catch (e) {
      debugPrint("عکس $imagePath پیدا نشد");
    }
  }
}
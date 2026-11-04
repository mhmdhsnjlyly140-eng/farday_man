import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'player.dart';

class ShopGame extends FlameGame {
  late Player player;

  @override
  Future<void> onLoad() async {
    // 👈 این خط جادوییه! سایز بازی رو دقیقاً برابر با سایز صفحه گوشی می‌کنه
    camera.viewfinder.anchor = Anchor.topLeft; 

    // 1. لود کردن عکس مغازه
    try {
      final bgImage = await images.load('shop_bg.png');
      // عکس رو به اندازه کل صفحه کش می‌دیم
      world.add(SpriteComponent(
        sprite: Sprite(bgImage),
        size: size, // size یعنی کل صفحه گوشی
        position: Vector2(0, 0),
        priority: -10,
      ));
    } catch (e) {
      world.add(RectangleComponent(
        size: size,
        paint: Paint()..color = const Color(0xFF2C3E50),
        priority: -10,
      ));
    }

    // 2. لود کردن آرین
    try {
      final walkSprites = [
        Sprite(await images.load('arian_walk_1.png')),
        Sprite(await images.load('arian_walk_2.png')),
        Sprite(await images.load('arian_walk_3.png')),
        Sprite(await images.load('arian_walk_4.png')),
      ];

      player = Player(walkSprites);
      // قرار دادن آرین دقیقاً در وسط پایین صفحه (هر سایزی که باشه)
      player.position = Vector2(size.x / 2, size.y - 20); 
      player.priority = 5;
      world.add(player);
    } catch (e) {
      debugPrint("آرین لود نشد: $e");
    }
  }
}
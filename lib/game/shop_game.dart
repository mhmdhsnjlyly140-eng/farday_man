import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'player.dart';

class ShopGame extends FlameGame {
  late Player player;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft; 

    // 1. عکس مغازه
    try {
      final bgImage = await images.load('shop_bg.png');
      world.add(SpriteComponent(
        sprite: Sprite(bgImage),
        size: size, 
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

    // 2. ساخت آرین و اضافه کردنش به بازی
    try {
      player = Player();
      // آرین رو دقیقاً وسط پایین می‌ذاریم
      player.position = Vector2(size.x / 2, size.y - 80); 
      player.priority = 5;
      world.add(player);
    } catch (e) {
      debugPrint("خطا در ساخت آرین: $e");
    }
  }
}
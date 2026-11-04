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
      debugPrint("عکس مغازه لود نشد");
      world.add(RectangleComponent(
        size: size,
        paint: Paint()..color = const Color(0xFF2C3E50),
        priority: -10,
      ));
    }

    // 2. لود کردن عکس‌های آرین (همه اینجا انجام میشه)
    try {
      final walkSprites = [
        Sprite(await images.load('arian_walk_1.png')),
        Sprite(await images.load('arian_walk_2.png')),
        Sprite(await images.load('arian_walk_3.png')),
        Sprite(await images.load('arian_walk_4.png')),
      ];

      // 3. ساخت آرین و دادن عکس‌ها بهش
      player = Player(walkSprites);
      
      // آرین رو دقیقاً وسط پایین می‌ذاریم
      player.position = Vector2(size.x / 2, size.y - 80); 
      player.priority = 5;
      world.add(player);
    } catch (e) {
      debugPrint("عکس‌های آرین لود نشدند: $e");
    }
  }
}
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'player.dart';

class ShopGame extends FlameGame {
  late Player player;
  bool hasError = false;
  String errorMessage = "";

  @override
  Future<void> onLoad() async {
    camera.viewfinder.visibleGameSize = Vector2(800, 400);

    // 1. تلاش برای لود کردن عکس مغازه
    try {
      final bgImage = await images.load('shop_bg.png');
      final background = SpriteComponent(
        sprite: Sprite(bgImage),
        size: Vector2(800, 400),
        position: Vector2(0, 0),
        priority: -10,
      );
      world.add(background);
    } catch (e) {
      hasError = true;
      errorMessage = "عکس shop_bg.png پیدا نشد!";
      debugPrint("ERROR: $e");
      
      world.add(RectangleComponent(
        size: Vector2(800, 400),
        paint: Paint()..color = const Color(0xFF2C3E50),
        priority: -10,
      ));
    }

    // 2. تلاش برای لود کردن آرین
    try {
      final walkSprites = [
        Sprite(await images.load('arian_walk_1.png')),
        Sprite(await images.load('arian_walk_2.png')),
        Sprite(await images.load('arian_walk_3.png')),
        Sprite(await images.load('arian_walk_4.png')),
      ];

      player = Player(walkSprites);
      player.position = Vector2(400, 380); 
      player.priority = 5;
      world.add(player);
    } catch (e) {
      hasError = true;
      errorMessage = "عکس‌های آرین پیدا نشدند!";
      debugPrint("ERROR: $e");
    }
  }
}
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'player.dart';

class ShopGame extends FlameGame {
  late Player player;

  @override
  Future<void> onLoad() async {
    // ابعاد افقی
    camera.viewfinder.visibleGameSize = Vector2(800, 400);

    // لود کردن عکس مغازه
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
      world.add(RectangleComponent(
        size: Vector2(800, 400),
        paint: Paint()..color = const Color(0xFF2C3E50),
        priority: -10,
      ));
    }

    // اضافه کردن آرین
    player = Player();
    player.position = Vector2(400, 380); 
    player.priority = 5;
    world.add(player);
  }
}
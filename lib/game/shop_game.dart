import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ShopGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft; 

    // فقط عکس مغازه رو لود می‌کنیم
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
  }
}
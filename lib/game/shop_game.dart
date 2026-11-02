import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'player.dart';

class ShopGame extends FlameGame {
  late Player player;
  late TextComponent titleText;

  @override
  Future<void> onLoad() async {
    // دیگه نیازی به تنظیم رنگ دوربین یا world نیست. رنگ رو از Flutter میدیم.

    titleText = TextComponent(
      text: 'مغازه عمو رضا',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 50),
    );
    world.add(titleText);

    player = Player();
    player.position = Vector2(size.x / 2, size.y - 100); 
    world.add(player);
  }
}
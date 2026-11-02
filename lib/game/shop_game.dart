import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'player.dart'; // ایمپورت پلیر

class ShopGame extends FlameGame {
  late Player player;
  late TextComponent titleText;

  @override
  Future<void> onLoad() async {
    // رنگ پس زمینه
    camera.backgroundColor = const Color(0xFF2C3E50);

    // متن راهنما
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
    add(titleText);

    // اضافه کردن آرین به بازی
    player = Player();
    player.position = Vector2(size.x / 2, size.y - 50); 
    add(player);
  }
}
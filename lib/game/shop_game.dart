import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'player.dart';

class ShopGame extends FlameGame {
  late Player player;
  late TextComponent titleText;

  @override
  Future<void> onLoad() async {
    // 👇 این خط تغییر کرد
    world.backgroundColor = const Color(0xFF2C3E50);

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
      // در نسخه جدید Flame بهتره موقعیت رو به دوربین بدیم یا از size خود بازی استفاده کنیم
      position: Vector2(size.x / 2, 50),
    );
    // 👇 متن رو به world اضافه می‌کنیم (چون دوربین جدید Flame اینطوری کار می‌کنه)
    world.add(titleText);

    player = Player();
    // 👇 پلیر رو هم به world اضافه می‌کنیم
    player.position = Vector2(size.x / 2, size.y - 100); 
    world.add(player);
  }
}
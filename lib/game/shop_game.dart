import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ShopGame extends FlameGame {
  late SpriteComponent background;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft; 
    
    // لود کردن عکس اولیه (خیابون ۱)
    try {
      final firstImage = await images.load('street_area_1.png');
      background = SpriteComponent(
        sprite: Sprite(firstImage),
        size: size,
        position: Vector2(0, 0),
        priority: -10,
      );
    } catch (e) {
      // اگر عکس نبود
      background = SpriteComponent(
        size: size,
        position: Vector2(0, 0),
        priority: -10,
      );
    }
    world.add(background);
  }

  // 🌟 این همون تابعیه که خطا می‌داد و الان اضافه شد
  void changeBackground(String imagePath) async {
    try {
      final newImage = await images.load(imagePath);
      background.sprite = Sprite(newImage);
    } catch (e) {
      debugPrint("عکس پس‌زمینه $imagePath پیدا نشد");
    }
  }
}
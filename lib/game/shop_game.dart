import 'dart:ui' as ui;
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class ShopGame extends FlameGame {
  final double worldWidth = 4000; 
  final double singleAreaWidth = 1000;
  
  late SpriteAnimationComponent player;
  late SpriteAnimation walkLeftAnimation;
  late SpriteAnimation walkRightAnimation;
  late SpriteAnimation idleAnimation;
  late SpriteComponent background; // 👈 برای تعویض پس‌زمینه

  double playerX = 400;
  bool moveLeft = false;
  bool moveRight = false;
  bool isMoving = false;

  // 🌟 وضعیت فعلی: 0 = خیابون اصلی، 1 = بهار، 2 = پونه‌زار، 3 = شاهد
  int currentRegion = 0;

  VoidCallback? onTaxiStandTap;
  VoidCallback? onBillboardTap;
  VoidCallback? onReturnToMainStreet;

  final List<String> mainStreets = [
    'street_area_1.png', 'street_area_2.png', 'street_area_3.png', 'street_area_4.png',
  ];

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    await _loadRegion(0);
  }

  Future<void> _loadRegion(int regionId) async {
    world.removeAll(world.children);
    currentRegion = regionId;
    playerX = 400;

    if (regionId == 0) {
      // 🌟 لود ۴ خیابون اصلی
      for (int i = 0; i < mainStreets.length; i++) {
        try {
          final image = await images.load(mainStreets[i]);
          double aspectRatio = image.height / image.width;
          double finalHeight = singleAreaWidth * aspectRatio;
          world.add(SpriteComponent(
            sprite: Sprite(image),
            size: Vector2(singleAreaWidth, finalHeight), 
            position: Vector2(i * singleAreaWidth, 0), 
            priority: -10,
          ));
        } catch (e) {
          world.add(RectangleComponent(size: Vector2(singleAreaWidth, size.y), position: Vector2(i * singleAreaWidth, 0), paint: Paint()..color = Colors.grey.shade800, priority: -10));
        }
      }
      // بیلبورد
      try {
        final billboardImage = await images.load('billboard_asset.png');
        world.add(BillboardComponent(
          position: Vector2(600, size.y - 250),
          size: Vector2(350, 200),
          image: billboardImage,
          onTap: () => onBillboardTap?.call(),
        ));
      } catch (e) {}
      // ایستگاه تاکسی
      try {
        final taxiImage = await images.load('taxi_stand.png');
        world.add(SpriteComponent(
          sprite: Sprite(taxiImage),
          size: Vector2(200, 250),
          position: Vector2(1400, size.y - 20),
          anchor: Anchor.bottomCenter,
          priority: 15,
        ));
        world.add(TaxiButtonComponent(
          position: Vector2(1400, size.y - 145),
          size: Vector2(200, 250),
          onTap: () => onTaxiStandTap?.call(),
        ));
      } catch (e) {}
    } 
    else if (regionId == 1) {
      // 🌟 خیابون بهار
      final image = await images.load('street_area_5.jpg');
      double aspectRatio = image.height / image.width;
      double finalHeight = singleAreaWidth * aspectRatio;
      world.add(SpriteComponent(sprite: Sprite(image), size: Vector2(singleAreaWidth, finalHeight), position: Vector2(0, 0), priority: -10));
      // دکمه برگشت
      world.add(EnterButtonComponent(position: Vector2(50, size.y - 160), onTap: () => onReturnToMainStreet?.call()));
    }
    else if (regionId == 2) {
      // 🌟 خیابون پونه‌زار
      final image = await images.load('street_area_6.png');
      double aspectRatio = image.height / image.width;
      double finalHeight = singleAreaWidth * aspectRatio;
      world.add(SpriteComponent(sprite: Sprite(image), size: Vector2(singleAreaWidth, finalHeight), position: Vector2(0, 0), priority: -10));
      world.add(EnterButtonComponent(position: Vector2(50, size.y - 160), onTap: () => onReturnToMainStreet?.call()));
    }
    else if (regionId == 3) {
      // 🌟 خیابون شاهد
      final image = await images.load('street_area_7.png');
      double aspectRatio = image.height / image.width;
      double finalHeight = singleAreaWidth * aspectRatio;
      world.add(SpriteComponent(sprite: Sprite(image), size: Vector2(singleAreaWidth, finalHeight), position: Vector2(0, 0), priority: -10));
      world.add(EnterButtonComponent(position: Vector2(50, size.y - 160), onTap: () => onReturnToMainStreet?.call()));
    }

    // 🌟 لود آرین (روی پیاده‌رو)
    try {
      final idleSprite = Sprite(await images.load('arian_idle.png'));
      final leftSprites = [Sprite(await images.load('arian_left_1.png')), Sprite(await images.load('arian_left_2.png')), Sprite(await images.load('arian_left_3.png')), Sprite(await images.load('arian_left_4.png'))];
      final rightSprites = [Sprite(await images.load('arian_right_1.png')), Sprite(await images.load('arian_right_2.png')), Sprite(await images.load('arian_right_3.png')), Sprite(await images.load('arian_right_4.png'))];

      idleAnimation = SpriteAnimation.spriteList([idleSprite], stepTime: 1.0);
      walkLeftAnimation = SpriteAnimation.spriteList(leftSprites, stepTime: 0.1, loop: true);
      walkRightAnimation = SpriteAnimation.spriteList(rightSprites, stepTime: 0.1, loop: true);

      player = SpriteAnimationComponent(
        animation: idleAnimation, 
        size: Vector2(110, 170), 
        anchor: Anchor.bottomCenter,
      );
      player.position = Vector2(playerX, size.y - 80); 
      player.priority = 10;
      world.add(player);
    } catch (e) {}
  }

  void goToRegion(int regionId) {
    _loadRegion(regionId);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (player.animation == null) return;

    double maxX = (currentRegion == 0) ? 4000 : 1000;

    if (moveLeft) {
      isMoving = true;
      playerX -= 250 * dt;
      if (playerX < 70) playerX = 70;
      if (player.animation != walkLeftAnimation) player.animation = walkLeftAnimation;
    } else if (moveRight) {
      isMoving = true;
      playerX += 250 * dt;
      if (playerX > maxX - 70) playerX = maxX - 70;
      if (player.animation != walkRightAnimation) player.animation = walkRightAnimation;
    } else {
      if (isMoving) {
        isMoving = false;
        player.animation = idleAnimation;
      }
    }
    player.position = Vector2(playerX, size.y - 80);

    double targetCameraX = playerX - (size.x / 2);
    if (targetCameraX < 0) targetCameraX = 0;
    if (targetCameraX > maxX - size.x) targetCameraX = maxX - size.x;
    camera.viewfinder.position = Vector2(targetCameraX, 0);
  }
}

// 🌟 بیلبورد
class BillboardComponent extends PositionComponent with TapCallbacks {
  final VoidCallback onTap;
  final ui.Image image;
  double _timer = 0;
  bool _isTextVisible = true;
  late TextComponent _textComponent;

  BillboardComponent({required Vector2 position, required Vector2 size, required this.image, required this.onTap}) 
    : super(position: position, size: size, anchor: Anchor.topLeft, priority: 20);

  @override
  Future<void> onLoad() async {
    add(SpriteComponent(sprite: Sprite(image), size: size, anchor: Anchor.topLeft));
    add(RectangleComponent(size: Vector2(size.x - 60, size.y - 70), position: Vector2(30, 35), paint: Paint()..color = Colors.black, priority: 1));
    _textComponent = TextComponent(
      text: "این فضا برای\nتبلیغات شماست!",
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2),
      textRenderer: TextPaint(style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
      priority: 2,
    );
    add(_textComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    if (_timer > 0.5) {
      _timer = 0;
      _isTextVisible = !_isTextVisible;
      _textComponent.textRenderer = TextPaint(
        style: TextStyle(
          color: _isTextVisible ? Colors.amber : Colors.amber.withOpacity(0.2),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }

  @override
  void onTapDown(TapDownEvent event) => onTap();
}

// 🌟 دکمه‌ی ایستگاه تاکسی
class TaxiButtonComponent extends PositionComponent with TapCallbacks {
  final VoidCallback onTap;
  TaxiButtonComponent({required Vector2 position, required Vector2 size, required this.onTap}) 
    : super(position: position, size: size, anchor: Anchor.center, priority: 16);

  @override
  void onTapDown(TapDownEvent event) => onTap();
}

// 🌟 دکمه‌ی ورود/بازگشت
class EnterButtonComponent extends PositionComponent with TapCallbacks {
  final VoidCallback onTap;
  EnterButtonComponent({required Vector2 position, required this.onTap}) : super(position: position, size: Vector2(40, 40), anchor: Anchor.center);
  @override
  Future<void> onLoad() async {
    add(CircleComponent(radius: 20, paint: Paint()..color = Colors.white.withOpacity(0.8)));
    add(RectangleComponent(size: Vector2(10, 10), position: Vector2(15, 15), paint: Paint()..color = Colors.blueAccent));
  }
  @override
  void onTapDown(TapDownEvent event) => onTap();
}
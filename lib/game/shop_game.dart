import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class ShopGame extends FlameGame {
  // 🌟 عرض دنیا برای ۷ منطقه (۴ خیابون اصلی + ۳ خیابون تاکسی)
  final double worldWidth = 7000; 
  final double singleAreaWidth = 1000;
  
  late SpriteAnimationComponent player;
  late SpriteAnimation walkLeftAnimation;
  late SpriteAnimation walkRightAnimation;
  late SpriteAnimation idleAnimation;

  double playerX = 400;
  bool moveLeft = false;
  bool moveRight = false;
  bool isMoving = false;

  // 🌟 وضعیت فعلی: 0 = خیابون‌های اصلی، 1 = بهار، 2 = پونه‌زار، 3 = شاهد
  int currentRegion = 0;

  VoidCallback? onShopEnter;
  VoidCallback? onHomeEnter;
  VoidCallback? onTaxiStandTap;
  VoidCallback? onBillboardTap;

  // لیست عکس‌های خیابون‌های اصلی (منطقه ۱ تا ۴)
  final List<String> mainStreets = [
    'street_area_1.png', // محله (مغازه لوازم‌التحریر)
    'street_area_2.png', // بازار
    'street_area_3.png', // خانه
    'street_area_4.png', // سالن مسابقات
  ];

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    await _loadRegion(0); // شروع با خیابون‌های اصلی
  }

  Future<void> _loadRegion(int regionId) async {
    world.removeAll(world.children); // پاک کردن دنیای قبلی
    currentRegion = regionId;
    playerX = 400;

    if (regionId == 0) {
      // 🌟 بارگذاری ۴ خیابون اصلی
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
      // 🌟 دکمه‌های ورود به مغازه و خونه
      world.add(EnterButtonComponent(position: Vector2(350, size.y - 160), onTap: () => onShopEnter?.call()));
      world.add(EnterButtonComponent(position: Vector2(2500, size.y - 160), onTap: () => onHomeEnter?.call()));
    } 
    else if (regionId == 1) {
      // 🌟 خیابون بهار
      final image = await images.load('street_area_5.jpg');
      double aspectRatio = image.height / image.width;
      double finalHeight = singleAreaWidth * aspectRatio;
      world.add(SpriteComponent(sprite: Sprite(image), size: Vector2(singleAreaWidth, finalHeight), position: Vector2(0, 0), priority: -10));
    }
    else if (regionId == 2) {
      // 🌟 خیابون پونه‌زار
      final image = await images.load('street_area_6.png');
      double aspectRatio = image.height / image.width;
      double finalHeight = singleAreaWidth * aspectRatio;
      world.add(SpriteComponent(sprite: Sprite(image), size: Vector2(singleAreaWidth, finalHeight), position: Vector2(0, 0), priority: -10));
    }
    else if (regionId == 3) {
      // 🌟 خیابون شاهد
      final image = await images.load('street_area_7.png');
      double aspectRatio = image.height / image.width;
      double finalHeight = singleAreaWidth * aspectRatio;
      world.add(SpriteComponent(sprite: Sprite(image), size: Vector2(singleAreaWidth, finalHeight), position: Vector2(0, 0), priority: -10));
    }

    // 🌟 اضافه کردن بیلبورد و ایستگاه تاکسی (فقط توی منطقه ۱)
    if (regionId == 0) {
      world.add(BillboardComponent(position: Vector2(1200, 160), onTap: () => onBillboardTap?.call()));
      world.add(TaxiStandComponent(position: Vector2(1800, size.y - 160), onTap: () => onTaxiStandTap?.call()));
    }

    // 🌟 لود کردن آرین
    try {
      final idleSprite = Sprite(await images.load('arian_idle.png'));
      final leftSprites = [Sprite(await images.load('arian_left_1.png')), Sprite(await images.load('arian_left_2.png')), Sprite(await images.load('arian_left_3.png')), Sprite(await images.load('arian_left_4.png'))];
      final rightSprites = [Sprite(await images.load('arian_right_1.png')), Sprite(await images.load('arian_right_2.png')), Sprite(await images.load('arian_right_3.png')), Sprite(await images.load('arian_right_4.png'))];

      idleAnimation = SpriteAnimation.spriteList([idleSprite], stepTime: 1.0);
      walkLeftAnimation = SpriteAnimation.spriteList(leftSprites, stepTime: 0.1, loop: true);
      walkRightAnimation = SpriteAnimation.spriteList(rightSprites, stepTime: 0.1, loop: true);

      player = SpriteAnimationComponent(animation: idleAnimation, size: Vector2(110, 170), anchor: Anchor.bottomCenter);
      player.position = Vector2(playerX, size.y - 80); 
      player.priority = 10;
      world.add(player);
    } catch (e) {
      debugPrint("عکس‌های آرین پیدا نشد: $e");
    }
  }

  // 🌟 تابع عمومی برای رفتن به منطقه جدید (توسط تاکسی صدا زده می‌شود)
  void goToRegion(int regionId) {
    _loadRegion(regionId);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (player.animation == null) return;

    double maxX = (currentRegion == 0) ? 4000 : 1000; // محدوده‌ی حرکت

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

// 🌟 کامپوننت دکمه‌ی ورود
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

// 🌟 کامپوننت بیلبورد
class BillboardComponent extends PositionComponent with TapCallbacks {
  final VoidCallback onTap;
  BillboardComponent({required Vector2 position, required this.onTap}) : super(position: position, size: Vector2(160, 90), anchor: Anchor.bottomLeft);
  @override
  Future<void> onLoad() async {
    add(RectangleComponent(size: size, paint: Paint()..color = Colors.black));
    add(RectangleComponent(size: size, paint: Paint()..style = PaintingStyle.stroke..strokeWidth = 4..color = Colors.white));
    add(TextComponent(text: "این فضا برای\nتبلیغات شماست!", anchor: Anchor.center, position: Vector2(size.x / 2, size.y / 2), textRenderer: TextPaint(style: const TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold))));
  }
  @override
  void onTapDown(TapDownEvent event) => onTap();
}

// 🌟 کامپوننت ایستگاه تاکسی
class TaxiStandComponent extends PositionComponent with TapCallbacks {
  final VoidCallback onTap;
  TaxiStandComponent({required Vector2 position, required this.onTap}) : super(position: position, size: Vector2(60, 80), anchor: Anchor.center);
  @override
  Future<void> onLoad() async {
    add(RectangleComponent(size: size, paint: Paint()..color = Colors.blueGrey));
    add(TextComponent(text: "🚕", anchor: Anchor.center, position: Vector2(size.x / 2, size.y / 2), textRenderer: TextPaint(style: const TextStyle(color: Colors.white, fontSize: 30))));
  }
  @override
  void onTapDown(TapDownEvent event) => onTap();
}
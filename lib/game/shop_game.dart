import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ShopGame extends FlameGame {
  late SpriteComponent background;
  final double worldWidth = 4000; // عرض کل دنیا (۴ منطقه × ۱۰۰۰)
  
  // لیست عکس‌ها به ترتیب
  final List<String> areaImages = [
    'street_area_1.png',
    'street_area_2.png',
    'street_area_3.png',
    'street_area_4.png',
  ];

  @override
  Future<void> onLoad() async {
    // 🌟 دوربین آزاد باشه تا بتونه حرکت کنه
    camera.viewfinder.anchor = Anchor.topLeft;

    // 🌟 ساخت پس‌زمینه‌ی بلند (۴ تصویر رو به هم می‌چسبونیم)
    // ما یه کامپوننت PositionComponent می‌سازیم که ۴ تا Sprite رو کنار هم نگه می‌داره.
    // برای سادگی، من از یک PositionComponent با ۴ فرزند SpriteComponent استفاده می‌کنم.
    // اینطوری می‌تونیم عرض هر کدوم رو ۱۰۰۰ بذاریم.
    
    double singleAreaWidth = worldWidth / 4; // 1000

    for (int i = 0; i < areaImages.length; i++) {
      try {
        final image = await images.load(areaImages[i]);
        // هر عکس رو با عرض ۱۰۰۰ و ارتفاع کل صفحه رسم می‌کنیم
        final spriteComp = SpriteComponent(
          sprite: Sprite(image),
          size: Vector2(singleAreaWidth, size.y), // ارتفاع کل صفحه
          position: Vector2(i * singleAreaWidth, 0), // قرارگیری به ترتیب
          priority: -10,
        );
        world.add(spriteComp);
      } catch (e) {
        debugPrint("عکس ${areaImages[i]} پیدا نشد");
        // اگه عکس نبود، یه مستطیل رنگی بذار
        world.add(RectangleComponent(
          size: Vector2(singleAreaWidth, size.y),
          position: Vector2(i * singleAreaWidth, 0),
          paint: Paint()..color = Colors.grey.shade800,
          priority: -10,
        ));
      }
    }
  }

  // 🌟 این تابع دیگه برای تغییر پس‌زمینه نیست، چون پس‌زمینه‌ها همیشه کنار هم هستن
  // و دوربین حرکت می‌کنه.
  // ما فقط برای سازگاری با کدهای قبلی، این تابع رو خالی نگه می‌داریم 
  // (یا می‌تونیم کلاً حذفش کنیم، ولی فعلاً نگه می‌داریم که خطا نده).
  void changeBackground(String imagePath) {
    // نیازی به تغییر پس‌زمینه نیست، چون کل دنیا رو ساختیم.
    // این تابع رو خالی می‌ذاریم.
  }
}
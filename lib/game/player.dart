import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Player extends PositionComponent {
  // سرعت حرکت
  double speed = 200.0; 
  
  // وضعیت دکمه‌ها
  bool moveLeft = false;
  bool moveRight = false;
  
  // وضعیت ظاهری (آیا در حال حرکت است؟)
  bool isMoving = false;

  Player() : super(size: Vector2(50, 50), anchor: Anchor.bottomCenter);

  @override
  void update(double dt) {
    super.update(dt);
    
    // منطق حرکت
    double direction = 0;
    if (moveLeft) direction -= 1;
    if (moveRight) direction += 1;

    if (direction != 0) {
      position.x += direction * speed * dt;
      isMoving = true;
      
      // جلوگیری از خروج از صفحه
      if (position.x < size.x / 2) {
        position.x = size.x / 2;
      }
      // فرض میکنیم عرض بازی 400 هست، اگه بیشتر شد اینجا محدود میشه
      // (چون دوربین ثابت است)
    } else {
      isMoving = false;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // چون فعلاً عکس نداریم، یه شکل ساده (آرین) میکشیم
    // بعداً میتونی این خطوط رو پاک کنی و از SpriteComponent استفاده کنی
    
    final paint = Paint()
      ..color = isMoving ? Colors.blueAccent : Colors.blue; // اگه راه بره رنگش عوض میشه

    // بدن
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(5, 10, size.x - 10, size.y - 10),
        const Radius.circular(15),
      ),
      paint,
    );

    // سر
    canvas.drawCircle(
      Offset(size.x / 2, 5),
      10,
      Paint()..color = Colors.orangeAccent,
    );
    
    // چشم‌ها (برای نشون دادن جهت)
    final eyePaint = Paint()..color = Colors.black;
    double eyeOffset = 0;
    if (moveLeft) eyeOffset = -3;
    if (moveRight) eyeOffset = 3;
    
    canvas.drawCircle(Offset((size.x / 2) - 4 + eyeOffset, 3), 2, eyePaint);
    canvas.drawCircle(Offset((size.x / 2) + 4 + eyeOffset, 3), 2, eyePaint);
  }
}
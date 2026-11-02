import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Player extends PositionComponent {
  double speed = 200.0; 
  bool moveLeft = false;
  bool moveRight = false;
  bool isMoving = false;

  Player() : super(size: Vector2(50, 50), anchor: Anchor.bottomCenter);

  @override
  void update(double dt) {
    super.update(dt);
    
    double direction = 0;
    if (moveLeft) direction -= 1;
    if (moveRight) direction += 1;

    if (direction != 0) {
      position.x += direction * speed * dt;
      isMoving = true;
      
      if (position.x < size.x / 2) {
        position.x = size.x / 2;
      }
    } else {
      isMoving = false;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()
      ..color = isMoving ? Colors.blueAccent : Colors.blue;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(5, 10, size.x - 10, size.y - 10),
        const Radius.circular(15),
      ),
      paint,
    );

    canvas.drawCircle(
      Offset(size.x / 2, 5),
      10,
      Paint()..color = Colors.orangeAccent,
    );
    
    final eyePaint = Paint()..color = Colors.black;
    double eyeOffset = 0;
    if (moveLeft) eyeOffset = -3;
    if (moveRight) eyeOffset = 3;
    
    canvas.drawCircle(Offset((size.x / 2) - 4 + eyeOffset, 3), 2, eyePaint);
    canvas.drawCircle(Offset((size.x / 2) + 4 + eyeOffset, 3), 2, eyePaint);
  }
}
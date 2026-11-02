import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/shop_game.dart';

void main() {
  runApp(const FardayeManApp());
}

class FardayeManApp extends StatelessWidget {
  const FardayeManApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'فردای من',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late ShopGame _game;

  @override
  void initState() {
    super.initState();
    _game = ShopGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // موتور بازی Flame
          GameWidget(game: _game),
          
          // دکمه‌های کنترل روی صفحه
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // دکمه چپ (نگه دار تا راه بره)
                GestureDetector(
                  onTapDown: (_) => _game.player.moveLeft = true,
                  onTapUp: (_) => _game.player.moveLeft = false,
                  onTapCancel: () => _game.player.moveLeft = false,
                  child: _buildControlButton(Icons.arrow_back_ios_new_rounded),
                ),
                
                // دکمه راست (نگه دار تا راه بره)
                GestureDetector(
                  onTapDown: (_) => _game.player.moveRight = true,
                  onTapUp: (_) => _game.player.moveRight = false,
                  onTapCancel: () => _game.player.moveRight = false,
                  child: _buildControlButton(Icons.arrow_forward_ios_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ظاهر دکمه‌ها
  Widget _buildControlButton(IconData icon) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 35,
      ),
    );
  }
}
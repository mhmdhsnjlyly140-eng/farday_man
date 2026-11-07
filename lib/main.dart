import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart'; 
import 'package:flame/game.dart';
import 'game/shop_game.dart';
import 'game_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const FardayeManApp());
}

class FardayeManApp extends StatelessWidget {
  const FardayeManApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'فردای من',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late ShopGame _game;
  final gameState = GameState();
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  int currentArea = 0;
  final List<String> areaImages = [
    'street_area_1.png',
    'street_area_2.png',
    'street_area_3.png',
    'street_area_4.png',
  ];
  final List<String> areaNames = [
    'خیابان محله',
    'خیابان بازار',
    'خیابان خانه',
    'سالن مسابقات',
  ];

  @override
  void initState() {
    super.initState();
    _game = ShopGame();
    gameState.money += 50; 

    _ticker = createTicker((elapsed) {
      final dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0; 
      _lastElapsed = elapsed;

      if (!mounted) return;

      // تشخیص لبه برای تعویض منطقه (بدون درگیری با Flame)
      if (_game.playerX >= MediaQuery.of(context).size.width - 90 && _game.moveRight) {
        if (currentArea < areaImages.length - 1) {
          _changeArea(currentArea + 1);
        }
      } else if (_game.playerX <= 90 && _game.moveLeft) {
        if (currentArea > 0) {
          _changeArea(currentArea - 1);
        }
      }
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose(); 
    super.dispose();
  }

  void _changeArea(int newArea) {
    _game.moveLeft = false;
    _game.moveRight = false;
    
    setState(() {
      currentArea = newArea;
      // آرین رو ببر وسط صفحه تا حس پرش نداشته باشه
      _game.playerX = MediaQuery.of(context).size.width / 2; 
    });

    _game.changeAreaImage(areaImages[newArea]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      body: Stack(
        children: [
          // موتور بازی
          GameWidget(game: _game),

          // نام منطقه (بالای صفحه)
          Positioned(
            top: 20,
            left: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                areaNames[currentArea],
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),

          // پول (بالای صفحه)
          Positioned(
            top: 20, 
            right: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    '${gameState.money}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // دکمه‌های حرکت (پایین صفحه)
          Positioned(
            bottom: 20,
            left: 30,
            right: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTapDown: (_) => _game.moveLeft = true,
                  onTapUp: (_) => _game.moveLeft = false,
                  onTapCancel: () => _game.moveLeft = false,
                  child: _buildControlButton(Icons.arrow_back_ios_new_rounded),
                ),
                GestureDetector(
                  onTapDown: (_) => _game.moveRight = true,
                  onTapUp: (_) => _game.moveRight = false,
                  onTapCancel: () => _game.moveRight = false,
                  child: _buildControlButton(Icons.arrow_forward_ios_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: Icon(icon, color: Colors.white, size: 35),
    );
  }
}
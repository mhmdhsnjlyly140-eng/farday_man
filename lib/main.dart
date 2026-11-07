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

  double cameraOffset = 0.0;
  double screenWidth = 0;

  @override
  void initState() {
    super.initState();
    _game = ShopGame();
    gameState.money += 50; 

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        screenWidth = MediaQuery.of(context).size.width;
      });
    });

    // تیکر ساده برای حرکت دوربین (بدون درگیری با Flame)
    _ticker = createTicker((elapsed) {
      final dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0; 
      _lastElapsed = elapsed;

      if (!mounted || screenWidth == 0) return;

      // محاسبه موقعیت دوربین
      double targetCam = _game.playerX - (screenWidth / 2);
      if (targetCam < 0) targetCam = 0;
      if (targetCam > _game.worldWidth - screenWidth) {
        targetCam = _game.worldWidth - screenWidth;
      }

      // حرکت نرم دوربین
      setState(() {
        cameraOffset += (targetCam - cameraOffset) * dt * 10;
      });
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      body: Stack(
        children: [
          // 🌟 کادر مخفی که دنیای بزرگ رو نگه می‌داره
          Positioned.fill(
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.topLeft,
                minWidth: _game.worldWidth,
                maxWidth: _game.worldWidth,
                child: Transform.translate(
                  offset: Offset(-cameraOffset, 0),
                  child: SizedBox(
                    width: _game.worldWidth,
                    height: MediaQuery.of(context).size.height,
                    child: GameWidget(game: _game),
                  ),
                ),
              ),
            ),
          ),

          // پول
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

          // دکمه‌های حرکت
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
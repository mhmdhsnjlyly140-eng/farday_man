import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'game/shop_game.dart';
import 'story_screen.dart';
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
      initialRoute: '/',
      routes: {
        '/': (context) => const StoryScreen(),
        '/game': (context) => const GameScreen(),
      },
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
  final gameState = GameState();

  // 👈 مختصات آرین رو اینجا نگه می‌داریم (برای نمایش با Flutter)
  double arianX = 400; 
  bool isMoving = false;

  @override
  void initState() {
    super.initState();
    _game = ShopGame();
    gameState.money += 50; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      body: Stack(
        children: [
          // موتور بازی Flame (فقط برای پس‌زمینه)
          GameWidget(game: _game),
          
          // 🌟 لایه‌ی نمایش آرین با Flutter (مطمئن‌ترین روش)
          Positioned(
            bottom: 40, // فاصله از پایین
            left: arianX - 70, // وسط آرین
            child: Image.asset(
              isMoving ? 'assets/images/arian_walk_2.png' : 'assets/images/arian_walk_1.png',
              width: 140,
              height: 230,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 140,
                  height: 230,
                  color: Colors.red.withOpacity(0.5),
                  child: const Center(child: Text("عکس آرین\nپیدا نشد!", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12))),
                );
              },
            ),
          ),

          // نوار بالای صفحه (نمایش پول)
          Positioned(
            top: 20, // 👈 از زیر نوار وضعیت گوشی اومد پایین‌تر
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
                  onTapDown: (_) {
                    setState(() {
                      isMoving = true;
                      arianX -= 20; // حرکت به چپ
                      if (arianX < 70) arianX = 70;
                    });
                  },
                  onTapUp: (_) => setState(() => isMoving = false),
                  onTapCancel: () => setState(() => isMoving = false),
                  child: _buildControlButton(Icons.arrow_back_ios_new_rounded),
                ),
                GestureDetector(
                  onTapDown: (_) {
                    setState(() {
                      isMoving = true;
                      arianX += 20; // حرکت به راست
                      if (arianX > MediaQuery.of(context).size.width - 70) {
                        arianX = MediaQuery.of(context).size.width - 70;
                      }
                    });
                  },
                  onTapUp: (_) => setState(() => isMoving = false),
                  onTapCancel: () => setState(() => isMoving = false),
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
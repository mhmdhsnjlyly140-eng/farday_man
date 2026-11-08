import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      home: const MainMenuScreen(),
    );
  }
}

// 🌟 صفحه منوی اصلی
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. عکس آیکون به عنوان پس‌زمینه
          Positioned.fill(
            child: Image.asset(
              'assets/images/app_icon.png',
              fit: BoxFit.cover, // کل صفحه رو پر می‌کنه
              errorBuilder: (context, error, stackTrace) {
                return Container(color: const Color(0xFF1E1E2C));
              },
            ),
          ),
          
          // 2. یه لایه تاریک برای اینکه دکمه‌ها و لوگو خوانا باشن
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5), 
            ),
          ),
          
          // 3. محتوای منو (لوگو و دکمه‌ها)
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // لوگوی بازی
                  const Text(
                    'فردای من',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 70,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Vazirmatn', // اگه فونت وزیر رو اضافه کنی خیلی خوشگل تر میشه
                      shadows: [
                        Shadow(color: Colors.black, blurRadius: 20, offset: Offset(0, 5)),
                        Shadow(color: Colors.blueAccent, blurRadius: 10),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'فردای من رو خودم می‌سازم',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // دکمه‌ها
                  _buildMenuButton(
                    text: 'شروع بازی جدید',
                    icon: Icons.play_arrow_rounded,
                    color: Colors.green.shade600,
                    onPressed: () => _startGame(context),
                  ),
                  const SizedBox(height: 15),

                  _buildMenuButton(
                    text: 'ادامه بازی',
                    icon: Icons.history,
                    color: Colors.blue.shade600,
                    onPressed: () => _startGame(context), // فعلاً مثل شروع کار می‌کنه (برای ذخیره باید کد اضافه بشه)
                  ),
                  const SizedBox(height: 15),

                  _buildMenuButton(
                    text: 'تنظیمات',
                    icon: Icons.settings,
                    color: Colors.grey.shade700,
                    onPressed: () {
                      // بعداً کد تنظیمات رو می‌ذاریم
                    },
                  ),
                  const SizedBox(height: 15),

                  _buildMenuButton(
                    text: 'خروج از بازی',
                    icon: Icons.exit_to_app_rounded,
                    color: Colors.red.shade700,
                    onPressed: () {
                      SystemNavigator.pop(); 
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startGame(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const GameScreen()),
    );
  }

  // 🌟 ویجت دکمه‌های منو (شیشه‌ای و شیک)
  Widget _buildMenuButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 100),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.85),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 5))
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 30),
              const SizedBox(width: 15),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 5)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 🌟 صفحه بازی (همون کد قبلی)
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late ShopGame _game;
  final gameState = GameState();

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
          GameWidget(game: _game),

          // دکمه برگشت به منو
          Positioned(
            top: 20,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainMenuScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              ),
            ),
          ),

          // نام منطقه
          Positioned(
            top: 20,
            left: 80,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'خیابان محله',
                style: TextStyle(color: Colors.white, fontSize: 16),
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
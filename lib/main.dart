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

  // مختصات آرین در دنیای بازی (نه در صفحه)
  double arianX = 400; // وسط دنیا
  bool isMovingLeft = false;
  bool isMovingRight = false;
  bool isMoving = false; 
  
  // نام مناطقی که با راه رفتن آرین عوض می‌شن (برای نمایش اسم بالای صفحه)
  int currentArea = 0;
  final List<String> areaNames = [
    'خیابان محله',
    'خیابان بازار',
    'خیابان خانه',
    'سالن مسابقات',
  ];

  int animationFrame = 1;
  double _animationTimer = 0.0;

  // 🌟 تنظیمات دوربین و مقیاس
  double screenWidth = 0;
  double scale = 1.0; 

  @override
  void initState() {
    super.initState();
    _game = ShopGame();
    gameState.money += 50; 

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        screenWidth = MediaQuery.of(context).size.width;
        // 🌟 محاسبه مقیاس: می‌خوایم کل عرض ۴ تا عکس (مثلاً ۴۰۰۰ پیکسل) توی دوربین جا بشه
        // ولی ما می‌خوایم آرین بزرگ دیده بشه. پس یه مقیاس منطقی انتخاب می‌کنیم.
        // فرض می‌کنیم هر منطقه ۱۰۰۰ پیکسل عرض داره. کل دنیا ۴۰۰۰ پیکسله.
        // ما می‌خوایم ۴ تا عکس پیوسته کنار هم باشن.
      });
    });

    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose(); 
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0; 
    _lastElapsed = elapsed;

    if (!mounted) return;

    // 🌟 حرکت آرین در دنیا
    if (isMovingLeft || isMovingRight) {
      setState(() {
        isMoving = true;
        
        // سرعت آرین (پیکسل بر ثانیه)
        double speed = 250; 
        
        if (isMovingLeft) {
          arianX -= speed * dt; 
          // محدودیت سمت چپ کل دنیا
          if (arianX < 100) arianX = 100;
        } else if (isMovingRight) {
          arianX += speed * dt; 
          // محدودیت سمت راست کل دنیا (فرض: ۴ تا منطقه، هر کدوم ۱۰۰۰ پیکسل)
          if (arianX > 3900) arianX = 3900; 
        }

        // 🌟 به‌روزرسانی انیمیشن راه رفتن (سرعت 0.08 برای نرمی)
        _animationTimer += dt;
        if (_animationTimer >= 0.08) { 
          animationFrame++;
          if (animationFrame > 4) animationFrame = 1; 
          _animationTimer = 0;
        }
      });
    } else {
      if (isMoving) {
        setState(() {
          isMoving = false;
          animationFrame = 1; 
        });
      }
    }
    
    // 🌟 تشخیص منطقه بر اساس مختصات آرین
    int newArea = (arianX / 1000).floor().clamp(0, 3);
    if (newArea != currentArea) {
      setState(() {
        currentArea = newArea;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🌟 محاسبه موقعیت دوربین: دوربین همیشه وسط صفحه رو نشون می‌ده
    // اما وقتی آرین به لبه‌های دنیا می‌رسه، دوربین متوقف می‌شه.
    double cameraOffset = arianX - (screenWidth / 2);
    // محدودیت دوربین (نذار از دنیا بیرون بزنه)
    if (cameraOffset < 0) cameraOffset = 0;
    // عرض کل دنیا ۴۰۰۰ فرض شده. عرض صفحه رو کم می‌کنیم.
    if (cameraOffset > 4000 - screenWidth) cameraOffset = 4000 - screenWidth;

    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      body: Stack(
        children: [
          // 🌟 موتور بازی Flame (که کل دنیای ۴۰۰۰ پیکسلی رو با دوربین نشون می‌ده)
          GameWidget(game: _game),
          
          // 🌟 نمایش آرین با موقعیت جدید (متناسب با دوربین)
          // ما آرین رو با استفاده از موقعیت دوربین جابه‌جا می‌کنیم
          Positioned(
            // مختصات آرین روی صفحه = مختصاتش در دنیا - موقعیت دوربین
            left: (arianX - cameraOffset) - 80, 
            bottom: 80, // روی پیاده‌رو
            child: _buildArianImage(),
          ),

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

          // دکمه‌های حرکت
          Positioned(
            bottom: 20,
            left: 30,
            right: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTapDown: (_) => setState(() => isMovingLeft = true),
                  onTapUp: (_) => setState(() => isMovingLeft = false),
                  onTapCancel: () => setState(() => isMovingLeft = false),
                  child: _buildControlButton(Icons.arrow_back_ios_new_rounded),
                ),
                GestureDetector(
                  onTapDown: (_) => setState(() => isMovingRight = true),
                  onTapUp: (_) => setState(() => isMovingRight = false),
                  onTapCancel: () => setState(() => isMovingRight = false),
                  child: _buildControlButton(Icons.arrow_forward_ios_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArianImage() {
    String imagePath;
    if (isMovingLeft) {
      imagePath = 'assets/images/arian_left_$animationFrame.png';
    } else if (isMovingRight) {
      imagePath = 'assets/images/arian_right_$animationFrame.png';
    } else {
      imagePath = 'assets/images/arian_idle.png';
    }

    // 🌟 سایز آرین رو کوچیک‌تر کردیم (160x250)
    return Image.asset(
      imagePath,
      width: 160,
      height: 250,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 160,
          height: 250,
          color: Colors.red.withOpacity(0.5),
          child: const Center(child: Text("عکس آرین\nپیدا نشد!", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12))),
        );
      },
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
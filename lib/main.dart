import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart'; 
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
  final gameState = GameState();
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  // 🌟 مختصات آرین (همیشه وسط صفحه ثابت می‌مونه)
  double arianX = 0;
  bool isMovingLeft = false;
  bool isMovingRight = false;
  bool isMoving = false; 

  // 🌟 مختصات دنیا و پس‌زمینه
  double backgroundOffset = 0;
  double screenWidth = 800;
  double worldWidth = 3200; // 4 عکس 800 پیکسلی

  // انیمیشن
  int animationFrame = 1;
  double _animationTimer = 0.0;

  @override
  void initState() {
    super.initState();
    gameState.money += 50; 

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        screenWidth = MediaQuery.of(context).size.width;
        arianX = screenWidth / 2;
        worldWidth = screenWidth * 4; // 4 منطقه
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

    if (isMovingLeft || isMovingRight) {
      setState(() {
        isMoving = true;
        double speed = 250; // سرعت حرکت

        if (isMovingLeft) {
          // اگه آرین وسط بود، پس‌زمینه بره راست (برگشت به عقب)
          if (backgroundOffset > 0) {
            backgroundOffset -= speed * dt;
            if (backgroundOffset < 0) backgroundOffset = 0;
          } else {
            // اگه پس‌زمینه اول بود، آرین بره چپ
            arianX -= speed * dt;
            if (arianX < 60) arianX = 60;
          }
        } else if (isMovingRight) {
          // اگه آرین وسط بود، پس‌زمینه بره چپ (جلو رفتن)
          if (backgroundOffset < worldWidth - screenWidth) {
            backgroundOffset += speed * dt;
            if (backgroundOffset > worldWidth - screenWidth) {
              backgroundOffset = worldWidth - screenWidth;
            }
          } else {
            // اگه پس‌زمینه آخر بود، آرین بره راست
            arianX += speed * dt;
            if (arianX > screenWidth - 60) arianX = screenWidth - 60;
          }
        }

        // انیمیشن راه رفتن
        _animationTimer += dt;
        if (_animationTimer >= 0.1) { 
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      body: Stack(
        children: [
          // 🌟 پس‌زمینه متحرک
          Positioned.fill(
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.centerLeft,
                minWidth: worldWidth,
                maxWidth: worldWidth,
                child: Transform.translate(
                  offset: Offset(-backgroundOffset, 0),
                  child: Row(
                    children: [
                      Image.asset('assets/images/street_area_1.png', width: screenWidth, height: double.infinity, fit: BoxFit.cover),
                      Image.asset('assets/images/street_area_2.png', width: screenWidth, height: double.infinity, fit: BoxFit.cover),
                      Image.asset('assets/images/street_area_3.png', width: screenWidth, height: double.infinity, fit: BoxFit.cover),
                      Image.asset('assets/images/street_area_4.png', width: screenWidth, height: double.infinity, fit: BoxFit.cover),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 🌟 آرین
          Positioned(
            bottom: 100, 
            left: arianX - 80, 
            child: _buildArianImage(),
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
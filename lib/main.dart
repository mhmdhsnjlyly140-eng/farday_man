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

  double arianX = 200;
  bool isMovingLeft = false;
  bool isMovingRight = false;
  bool isMoving = false; 
  
  int currentArea = 0;
  final List<String> areaBackgrounds = [
    'street_area_1.png', 
    'shop_bg.png',       
    'street_area_2.png', 
    'street_area_3.png', 
    'street_area_4.png', 
  ];
  final List<String> areaNames = [
    'خیابان محله',
    'داخل مغازه',
    'خیابان بازار',
    'خیابان خانه',
    'سالن مسابقات',
  ];

  int animationFrame = 1;
  double _animationTimer = 0.0;
  bool _isTransitioning = false;
  
  // 🌟 متغیرهای مربوط به افکت محو شدن (Fade)
  bool _isBlackOverlayVisible = false;
  double _overlayOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _game = ShopGame();
    gameState.money += 50; 

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        arianX = MediaQuery.of(context).size.width / 2;
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

    if (!mounted || _isTransitioning) return;

    final screenWidth = MediaQuery.of(context).size.width;

    if (isMovingLeft || isMovingRight) {
      setState(() {
        isMoving = true;
        if (isMovingLeft) {
          arianX -= 300 * dt; 
          if (arianX <= 40) {
            if (currentArea > 0) {
              _changeArea(currentArea - 1); 
            } else {
              arianX = 40; 
            }
          }
        } else if (isMovingRight) {
          arianX += 300 * dt; 
          if (arianX >= screenWidth - 40) {
            if (currentArea < areaBackgrounds.length - 1) {
              _changeArea(currentArea + 1); 
            } else {
              arianX = screenWidth - 40; 
            }
          }
        }

        _animationTimer += dt;
        if (_animationTimer >= 0.12) { 
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

  // 🌟 تابع جدید برای انتقال با افکت سینمایی
  Future<void> _changeArea(int newArea) async {
    setState(() {
      _isTransitioning = true;
      isMoving = false;
      isMovingLeft = false;
      isMovingRight = false;
      _isBlackOverlayVisible = true;
      _overlayOpacity = 1.0; // صفحه رو سیاه کن
    });

    // 2 ثانیه صبر کن در حالی که صفحه سیاهه
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      final previousArea = currentArea;
      currentArea = newArea;
      
      if (newArea > previousArea) {
        arianX = 60;
      } else {
        arianX = MediaQuery.of(context).size.width - 60;
      }
    });

    _game.changeBackground(areaBackgrounds[newArea]);

    // یه لحظه صبر کن تا عکس جدید لود بشه
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _overlayOpacity = 0.0; // صفحه رو آروم شفاف کن تا مغازه دیده بشه
    });

    // صبر کن تا افکت محو شدن تموم بشه
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isTransitioning = false;
      _isBlackOverlayVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      body: Stack(
        children: [
          GameWidget(game: _game),
          
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

          if (currentArea == 0 && !_isTransitioning)
            Positioned(
              top: 100, 
              left: 100,
              child: GestureDetector(
                onTap: () => _changeArea(1), 
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.8),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.door_front_door, color: Colors.white, size: 30),
                ),
              ),
            ),
            
          if (currentArea == 1 && !_isTransitioning)
            Positioned(
              top: 100,
              right: 100,
              child: GestureDetector(
                onTap: () => _changeArea(0), 
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.8),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.exit_to_app, color: Colors.white, size: 30),
                ),
              ),
            ),

          Positioned(
            bottom: 10, 
            left: arianX - 90, 
            child: AnimatedOpacity(
              opacity: _isTransitioning ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: _buildArianImage(),
            ),
          ),

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

          // 🌟 لایه سیاه (Overlay)
          if (_isBlackOverlayVisible)
            Positioned.fill(
              child: IgnorePointer( // اجازه بده کلیک‌ها ازش رد بشن
                child: AnimatedOpacity(
                  opacity: _overlayOpacity,
                  duration: const Duration(milliseconds: 500), // سرعت محو شدن
                  child: Container(
                    color: Colors.black,
                  ),
                ),
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
      width: 180,
      height: 300,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 180,
          height: 300,
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
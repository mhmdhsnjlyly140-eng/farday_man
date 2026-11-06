import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart'; 
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

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late ShopGame _game;
  final gameState = GameState();
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  double arianX = 200;
  bool isMovingLeft = false;
  bool isMovingRight = false;
  bool isMoving = false; 
  
  int animationFrame = 1;
  double _animationTimer = 0.0;

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

    if (!mounted) return;

    if (isMovingLeft || isMovingRight) {
      setState(() {
        isMoving = true;
        if (isMovingLeft) {
          arianX -= 300 * dt; 
          if (arianX < 90) arianX = 90;
        } else if (isMovingRight) {
          arianX += 300 * dt; 
          if (arianX > MediaQuery.of(context).size.width - 90) {
            arianX = MediaQuery.of(context).size.width - 90;
          }
        }

        // 🌟 تغییرات مهم: حالا بین 4 فریم می‌چرخه
        _animationTimer += dt;
        if (_animationTimer >= 0.12) { 
          animationFrame++;
          if (animationFrame > 4) animationFrame = 1; // برگشت به فریم اول
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
          GameWidget(game: _game),
          
          Positioned(
            bottom: 10, 
            left: arianX - 90, 
            child: _buildArianImage(),
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
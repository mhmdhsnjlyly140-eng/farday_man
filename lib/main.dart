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

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/app_icon.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: const Color(0xFF1E1E2C));
              },
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'فردای من',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 70,
                      fontWeight: FontWeight.w900,
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
                    ),
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildMenuButton(
                        text: 'شروع',
                        icon: Icons.play_arrow_rounded,
                        isGreen: true,
                        onPressed: () => _startGame(context),
                      ),
                      const SizedBox(width: 20),
                      _buildMenuButton(
                        text: 'تنظیمات',
                        icon: Icons.settings,
                        isGreen: false,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildMenuButton(
                        text: 'ادامه',
                        icon: Icons.history,
                        isGreen: false,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('سیستم ذخیره‌سازی به زودی اضافه می‌شود!')),
                          );
                        },
                      ),
                      const SizedBox(width: 20),
                      _buildMenuButton(
                        text: 'خروج',
                        icon: Icons.exit_to_app_rounded,
                        isGreen: false,
                        onPressed: () => SystemNavigator.pop(),
                      ),
                    ],
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

  Widget _buildMenuButton({
    required String text,
    required IconData icon,
    required bool isGreen,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 180,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isGreen ? Colors.green.withOpacity(0.7) : Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isGreen ? Colors.greenAccent.withOpacity(0.5) : Colors.white.withOpacity(0.3), 
            width: 2
          ),
          boxShadow: const [
            BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 5))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
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
  
  bool showDialogue = false;
  int dialogueIndex = 0;

  final List<Map<String, String>> dialogues = [
    {"speaker": "عمو رضا", "text": "آرین! این دفترهای جدید رو چیدی روی هم؟"},
    {"speaker": "آرین", "text": "صبح بخیر عمو. دیروز که گفتی مرتبشون کنم!"},
    {"speaker": "سارا", "text": "سلام عمو! سلام آرین! این کتاب رو دیدم و یاد تو افتادم."},
    {"speaker": "سارا", "text": "راستی آرین... شنیدی مسابقات علمی شهر داره شروع می‌شه؟"}
  ];

  @override
  void initState() {
    super.initState();
    _game = ShopGame();
    gameState.money += 50; 
  }

  void _startDialogue() {
    setState(() {
      showDialogue = true;
      dialogueIndex = 0;
      _game.moveLeft = false;
      _game.moveRight = false;
    });
  }

  void _nextDialogue() {
    if (dialogueIndex < dialogues.length - 1) {
      setState(() => dialogueIndex++);
    } else {
      setState(() {
        showDialogue = false;
        dialogueIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      body: Stack(
        children: [
          GameWidget(game: _game),

          if (!showDialogue)
            Positioned(
              top: 20,
              left: 20,
              child: GestureDetector(
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainMenuScreen()),
                ),
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

          if (!showDialogue)
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
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

          if (!showDialogue)
            Positioned(
              top: 80,
              right: 40,
              child: GestureDetector(
                onTap: _startDialogue,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.chat_bubble, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text("صحبت", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
              ),
            ),

          if (!showDialogue)
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

          if (showDialogue)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.85),
                  border: const Border(top: BorderSide(color: Colors.amber, width: 3)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      dialogues[dialogueIndex]["speaker"]!,
                      style: const TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      dialogues[dialogueIndex]["text"]!,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 15),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(
                        onPressed: _nextDialogue,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                        child: Text(
                          dialogueIndex == dialogues.length - 1 ? "پایان" : "ادامه",
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
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
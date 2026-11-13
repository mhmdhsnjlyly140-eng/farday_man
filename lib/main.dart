import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'game/shop_game.dart';
import 'game_state.dart';
import 'story_data.dart';
import 'shop_screen.dart';
import 'dart:async';

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

// 🌟 منوی اصلی
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
              errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF1E1E2C)),
            ),
          ),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.4))),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('فردای من', style: TextStyle(color: Colors.amber, fontSize: 70, fontWeight: FontWeight.w900, shadows: [Shadow(color: Colors.black, blurRadius: 20, offset: Offset(0, 5)), Shadow(color: Colors.blueAccent, blurRadius: 10)])),
                  const SizedBox(height: 5),
                  const Text('فردای من رو خودم می‌سازم', style: TextStyle(color: Colors.white70, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 50),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _buildMenuButton(text: 'شروع', icon: Icons.play_arrow_rounded, isGreen: true, onPressed: () => _startGame(context)),
                    const SizedBox(width: 20),
                    _buildMenuButton(text: 'تنظیمات', icon: Icons.settings, isGreen: false, onPressed: () {}),
                  ]),
                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _buildMenuButton(text: 'ادامه', icon: Icons.history, isGreen: false, onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سیستم ذخیره‌سازی به زودی اضافه می‌شود!')));
                    }),
                    const SizedBox(width: 20),
                    _buildMenuButton(text: 'خروج', icon: Icons.exit_to_app_rounded, isGreen: false, onPressed: () => SystemNavigator.pop()),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startGame(BuildContext context) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const GameScreen()));
  }

  Widget _buildMenuButton({required String text, required IconData icon, required bool isGreen, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 180,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isGreen ? Colors.green.withOpacity(0.7) : Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isGreen ? Colors.greenAccent.withOpacity(0.5) : Colors.white.withOpacity(0.3), width: 2),
          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 5))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 10),
            Text(text, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// 🌟 صفحه بازی
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late ShopGame _game;
  final gameState = GameState();
  Timer? _energyTimer;

  int currentPhase = 0; // 0: خیابون، 1: مغازه، 2: خونه
  bool showDialogue = true;
  int dialogueIndex = 0;
  String currentSpeakerImage = 'mother_portrait.png';
  
  List<Map<String, dynamic>> currentDialogues = StoryData.homeDialogue;

  @override
  void initState() {
    super.initState();
    _game = ShopGame();
    _game.onShopEnter = _enterShop;
    _game.onHomeEnter = _enterHome;
    _game.onTaxiEnter = _requestTaxi;
    _loadGameData();
    
    _energyTimer = Timer.periodic(const Duration(minutes: 45), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _energyTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadGameData() async {
    await gameState.loadGame();
    setState(() {});
  }

  void _nextDialogue() {
    if (dialogueIndex < currentDialogues.length - 1) {
      setState(() {
        dialogueIndex++;
        currentSpeakerImage = currentDialogues[dialogueIndex]["portrait"];
      });
    } else {
      setState(() {
        showDialogue = false;
      });
    }
  }

  void _enterShop() {
    setState(() {
      currentPhase = 1;
      showDialogue = true;
      dialogueIndex = 0;
      currentDialogues = StoryData.shopDialogue;
      currentSpeakerImage = currentDialogues[0]["portrait"];
      _game.moveLeft = false;
      _game.moveRight = false;
    });
  }

  void _enterHome() {
    setState(() {
      currentPhase = 2;
      _game.moveLeft = false;
      _game.moveRight = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('وارد خونه شدی! (هال، اتاق، آشپزخانه به زودی)')),
      );
    });
  }

  // 🌟 درخواست تاکسی
  void _requestTaxi() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2C),
          title: const Text("تاکسی", style: TextStyle(color: Colors.amber)),
          content: const Text("برای رفتن به این منطقه باید ۴۰,۰۰۰ تومان پرداخت کنید. آیا موافقید؟", style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("لغو", style: TextStyle(color: Colors.redAccent)),
            ),
            ElevatedButton(
              onPressed: () {
                if (gameState.buyPersonal(40000)) {
                  Navigator.pop(context);
                  _game.moveLeft = false;
                  _game.moveRight = false;
                  _game.playerX = 5000; // بردن به منطقه جدید
                  setState(() {});
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('پول کافی نداری!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("پرداخت و رفتن", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      body: Stack(
        children: [
          GameWidget(game: _game),

          // 🌟 آیکون‌های انرژی و سکه
          Positioned(
            top: 20,
            right: 40,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.redAccent, width: 1),
                  ),
                  child: Row(
                    children: [
                      Image.asset('assets/images/icon_energy.png', width: 18, height: 18, errorBuilder: (c, e, s) => const Icon(Icons.favorite, color: Colors.redAccent, size: 18)),
                      const SizedBox(width: 5),
                      Text('${gameState.currentEnergy}/${gameState.maxEnergy}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ShopScreen()));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.amber, width: 1),
                    ),
                    child: Row(
                      children: [
                        Image.asset('assets/images/icon_coin.png', width: 18, height: 18, errorBuilder: (c, e, s) => const Icon(Icons.star, color: Colors.amber, size: 18)),
                        const SizedBox(width: 5),
                        Text('${gameState.coins}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🌟 دکمه‌های حرکت
          if (!showDialogue && currentPhase == 0)
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

          // 🌟 دکمه خروج از مکان‌های داخلی
          if (currentPhase != 0)
            Positioned(
              top: 20,
              left: 20,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    currentPhase = 0;
                    showDialogue = false;
                  });
                },
                icon: const Icon(Icons.exit_to_app, color: Colors.white),
                label: const Text("خروج"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              ),
            ),

          // 🌟 کادر دیالوگ
          if (showDialogue)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.black, 
                  border: Border(top: BorderSide(color: Colors.amber, width: 3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.amber, width: 2)),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/$currentSpeakerImage',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.white, size: 40),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(currentDialogues[dialogueIndex]["speaker"]!, style: const TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text(currentDialogues[dialogueIndex]["text"]!, style: const TextStyle(color: Colors.white, fontSize: 18)),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton(
                              onPressed: _nextDialogue,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                              child: Text(
                                dialogueIndex == currentDialogues.length - 1 ? "پایان" : "ادامه",
                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
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
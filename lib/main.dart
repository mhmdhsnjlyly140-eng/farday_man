import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'game/shop_game.dart';
import 'game_state.dart';
import 'story_data.dart';

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

class _GameScreenState extends State<GameScreen> {
  late ShopGame _game;
  final gameState = GameState();

  // 🌟 فازها: 0 = خانه (داستان)، 1 = خیابون (بازی آزاد)
  int currentPhase = 0; 
  
  // 🌟 وضعیت دیالوگ
  bool showDialogue = true;
  int dialogueIndex = 0;
  String currentSpeakerImage = 'mother_portrait.png';
  
  // 🌟 لیست دیالوگ‌های فاز فعلی
  List<Map<String, dynamic>> currentDialogues = StoryData.homeDialogue;

  @override
  void initState() {
    super.initState();
    _game = ShopGame();
    _loadGameData();
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
        // 🌟 تغییر پس‌زمینه بر اساس دیالوگ (اتاق یا آشپزخانه)
        _game.setBackground(currentDialogues[dialogueIndex]["bg"]);
      });
    } else {
      // 🌟 پایان دیالوگ‌های خانه -> رفتن به خیابون
      if (currentPhase == 0) {
        setState(() {
          currentPhase = 1; // برو به فاز خیابون
          showDialogue = false; // بستن دیالوگ
          _game.setBackground('street_area_1.png'); // پس‌زمینه خیابون
        });
      } else {
        // پایان دیالوگ‌های خیابون
        setState(() {
          showDialogue = false;
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

          // 🌟 نمایش پول و سکه (بالای صفحه)
          Positioned(
            top: 20,
            right: 40,
            child: Row(
              children: [
                // صندوق مغازه
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.blueAccent, width: 1),
                  ),
                  child: Row(
                    children: [
                      Image.asset('assets/images/item_cash_register.png', width: 18, height: 18, errorBuilder: (c, e, s) => const Icon(Icons.store, color: Colors.blueAccent, size: 18)),
                      const SizedBox(width: 5),
                      Text('${gameState.shopMoney}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // جیب آرین
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.amber, width: 1),
                  ),
                  child: Row(
                    children: [
                      Image.asset('assets/images/wallet_icon.png', width: 18, height: 18, errorBuilder: (c, e, s) => const Icon(Icons.person, color: Colors.amber, size: 18)),
                      const SizedBox(width: 5),
                      Text('${gameState.arianMoney}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 🌟 دکمه‌های حرکت (فقط توی فاز خیابون)
          if (!showDialogue && currentPhase == 1)
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
                                dialogueIndex == currentDialogues.length - 1 
                                  ? (currentPhase == 0 ? "برو به خیابون" : "پایان")
                                  : "ادامه",
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'game/shop_game.dart';
import 'game_state.dart';
import 'story_data.dart';
import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const FardayeManApp());
}

class FardayeManApp extends StatelessWidget {
  const FardayeManApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'فردای من', debugShowCheckedModeBanner: false, theme: ThemeData(brightness: Brightness.dark), home: const MainMenuScreen());
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
          Positioned.fill(child: Image.asset('assets/images/app_icon.png', fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(color: const Color(0xFF1E1E2C)))),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.4))),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('فردای من', style: TextStyle(color: Colors.amber, fontSize: 70, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 5),
                  const Text('فردای من رو خودم می‌سازم', style: TextStyle(color: Colors.white70, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 50),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _buildMenuButton(text: 'شروع', icon: Icons.play_arrow_rounded, isGreen: true, onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const GameScreen()))),
                    const SizedBox(width: 20),
                    _buildMenuButton(text: 'تنظیمات', icon: Icons.settings, isGreen: false, onPressed: () {}),
                  ]),
                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _buildMenuButton(text: 'ادامه', icon: Icons.history, isGreen: false, onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سیستم ذخیره‌سازی به زودی!'))); }),
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

  Widget _buildMenuButton({required String text, required IconData icon, required bool isGreen, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 180,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(color: isGreen ? Colors.green.withOpacity(0.7) : Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(15), border: Border.all(color: isGreen ? Colors.greenAccent.withOpacity(0.5) : Colors.white.withOpacity(0.3), width: 2)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: Colors.white, size: 28), const SizedBox(width: 10), Text(text, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))]),
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

  bool showDialogue = true;
  int dialogueIndex = 0;
  String currentSpeakerImage = 'mother_portrait.png';
  List<Map<String, dynamic>> currentDialogues = StoryData.dialogues;

  @override
  void initState() {
    super.initState();
    _game = ShopGame();
    _game.onTaxiStandTap = _openTaxiMenu;
    _game.onBillboardTap = _showBillboardInfo;
    _loadGameData();
  }

  @override
  void dispose() { _energyTimer?.cancel(); super.dispose(); }

  Future<void> _loadGameData() async { await gameState.loadGame(); setState(() {}); }

  void _nextDialogue() {
    if (dialogueIndex < currentDialogues.length - 1) {
      setState(() { dialogueIndex++; currentSpeakerImage = currentDialogues[dialogueIndex]["portrait"]; });
    } else { setState(() { showDialogue = false; }); }
  }

  void _openTaxiMenu() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2C),
          title: const Text("تاکسی", style: TextStyle(color: Colors.amber)),
          content: const Text("این بخش به زودی فعال می‌شود!", style: TextStyle(color: Colors.white)),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("بستن", style: TextStyle(color: Colors.redAccent)))],
        );
      },
    );
  }

  void _showBillboardInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2C),
          title: const Text("تبلیغات در بازی", style: TextStyle(color: Colors.amber)),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("صاحب کسب‌وکار هستید؟", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text("📞 09052380706", style: TextStyle(color: Colors.white, fontSize: 16)),
              Text("⏰ ۷ تا ۹ شب", style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("بستن", style: TextStyle(color: Colors.redAccent)))],
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
          Positioned(
            top: 20, right: 40,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.redAccent, width: 1)),
                  child: Row(children: [Image.asset('assets/images/icon_energy.png', width: 18, height: 18, errorBuilder: (c,e,s) => const Icon(Icons.favorite, color: Colors.redAccent, size: 18)), const SizedBox(width: 5), Text('${gameState.currentEnergy}/${gameState.maxEnergy}', style: const TextStyle(color: Colors.white, fontSize: 14))]),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.amber, width: 1)),
                  child: Row(children: [Image.asset('assets/images/icon_coin.png', width: 18, height: 18, errorBuilder: (c,e,s) => const Icon(Icons.star, color: Colors.amber, size: 18)), const SizedBox(width: 5), Text('${gameState.coins}', style: const TextStyle(color: Colors.white, fontSize: 14))]),
                ),
              ],
            ),
          ),
          if (!showDialogue)
            Positioned(
              bottom: 20, left: 30, right: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(onTapDown: (_) => _game.moveLeft = true, onTapUp: (_) => _game.moveLeft = false, onTapCancel: () => _game.moveLeft = false, child: _buildControlButton(Icons.arrow_back_ios_new_rounded)),
                  GestureDetector(onTapDown: (_) => _game.moveRight = true, onTapUp: (_) => _game.moveRight = false, onTapCancel: () => _game.moveRight = false, child: _buildControlButton(Icons.arrow_forward_ios_rounded)),
                ],
              ),
            ),
          if (showDialogue)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: Colors.black, border: Border(top: BorderSide(color: Colors.amber, width: 3))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.amber, width: 2)), child: ClipOval(child: Image.asset('assets/images/$currentSpeakerImage', fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.person, color: Colors.white, size: 40)))),
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
                          Align(alignment: Alignment.centerLeft, child: ElevatedButton(onPressed: _nextDialogue, style: ElevatedButton.styleFrom(backgroundColor: Colors.amber), child: Text(dialogueIndex == currentDialogues.length - 1 ? "پایان" : "ادامه", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))),
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
    return Container(width: 70, height: 70, decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 2)), child: Icon(icon, color: Colors.white, size: 35));
  }
}
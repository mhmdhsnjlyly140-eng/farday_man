import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:url_launcher/url_launcher.dart'; // 👈 اضافه شد
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
  Timer? _energyTimer;

  int currentPhase = 0; 
  bool showDialogue = true;
  int dialogueIndex = 0;
  String currentSpeakerImage = 'mother_portrait.png';
  
  List<Map<String, dynamic>> currentDialogues = StoryData.homeDialogue;
  
  bool isInsideShop = false; 

  // 🌟 انیمیشن چشمک زدن چراغ بیلبوردها
  bool _isLightOn = true;
  late Timer _blinkTimer;

  @override
  void initState() {
    super.initState();
    _game = ShopGame();
    _loadGameData();
    
    _energyTimer = Timer.periodic(const Duration(minutes: 45), (timer) {
      setState(() {});
    });

    _blinkTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _isLightOn = !_isLightOn;
        });
      }
    });
  }

  @override
  void dispose() {
    _energyTimer?.cancel();
    _blinkTimer.cancel();
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
      if (currentPhase == 0) {
        setState(() {
          currentPhase = 1;
          showDialogue = false;
        });
      } else if (currentPhase == 2) {
         setState(() {
          showDialogue = false;
        });
      }
    }
  }

  void _startShopDialogue() {
    setState(() {
      isInsideShop = true;
      currentPhase = 2;
      showDialogue = true;
      dialogueIndex = 0;
      currentDialogues = StoryData.shopDialogue;
      currentSpeakerImage = currentDialogues[0]["portrait"];
      _game.moveLeft = false;
      _game.moveRight = false;
    });
  }

  // 🌟 تابع باز کردن لینک روبیکا
  Future<void> _openRubika() async {
    final Uri url = Uri.parse('https://rubika.ir/support_1i');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('نمی‌توان لینک را باز کرد');
    }
  }

  // 🌟 پنجره‌ی اطلاعات تماس بیلبورد
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
              Text("دوست دارید محصول یا خدمات خودتون رو به بازیکنان «فردای من» معرفی کنید؟", style: TextStyle(color: Colors.white70)),
              SizedBox(height: 20),
              Text("راه‌های ارتباط با ما:", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text("📞 شماره تماس: 09052380706", style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 5),
              Text("⏰ ساعات پاسخگویی: ۷ تا ۹ شب", style: TextStyle(color: Colors.white70, fontSize: 14)),
              SizedBox(height: 15),
              Text("💬 روبیکا (پشتیبانی):", style: TextStyle(color: Colors.white70)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("بستن", style: TextStyle(color: Colors.redAccent)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _openRubika(); // 👈 باز کردن روبیکا
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              child: const Text("ورود به روبیکا"),
            ),
          ],
        );
      },
    );
  }

  // 🌟 ویجت بیلبورد (برای استفاده‌ی مکرر)
  Widget _buildBillboard() {
    return GestureDetector(
      onTap: _showBillboardInfo,
      child: Column(
        children: [
          // چراغ چشمک زن
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isLightOn ? Colors.red : Colors.red.shade900,
              boxShadow: _isLightOn 
                ? [const BoxShadow(color: Colors.red, blurRadius: 15, spreadRadius: 5)]
                : [],
            ),
          ),
          const SizedBox(height: 5),
          // بدنه بیلبورد
          Container(
            width: 140, // کمی کوچک‌تر برای جا شدن ۳ تا
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Column(
              children: [
                Text(
                  "این فضا برای تبلیغات شماست!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 3),
                Text(
                  "برای رزرو کلیک کنید",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 9),
                ),
              ],
            ),
          ),
          // پایه بیلبورد
          Container(
            width: 8,
            height: 30,
            color: Colors.grey.shade700,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      body: Stack(
        children: [
          GameWidget(game: _game),

          // 🌟 سه تا بیلبورد روی خونه‌ها
          if (!isInsideShop && currentPhase == 1) ...[
            Positioned(
              top: 80,
              left: 200, // بیلبورد اول (سمت چپ)
              child: _buildBillboard(),
            ),
            Positioned(
              top: 50,
              right: 250, // بیلبورد دوم (وسط)
              child: _buildBillboard(),
            ),
            Positioned(
              top: 90,
              right: 50, // بیلبورد سوم (سمت راست)
              child: _buildBillboard(),
            ),
          ],

          // 🌟 آیکون‌های انرژی، پول و سکه
          if (!isInsideShop)
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
          if (!showDialogue && currentPhase == 1 && !isInsideShop)
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

          // 🌟 دکمه ورود به مغازه
          if (!showDialogue && !isInsideShop)
             Positioned(
              bottom: 120,
              left: 100,
              child: ElevatedButton.icon(
                onPressed: _startShopDialogue,
                icon: const Icon(Icons.store, color: Colors.white),
                label: const Text("ورود به مغازه"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
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
                                  ? (currentPhase == 0 ? "برو به خیابون" : (currentPhase == 2 ? "برو به خیابون" : "پایان"))
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
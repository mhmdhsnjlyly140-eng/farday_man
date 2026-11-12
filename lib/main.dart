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

// ==========================================
// 🌟 صفحه بازی
// ==========================================
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
  String currentSpeakerImage = 'arian_portrait.png'; 

  final List<String> areaNames = [
    'خیابان محله',
    'خیابان بازار',
    'خیابان خانه',
    'سالن مسابقات',
    'خیابان بهار (نانوایی)',
    'خیابان مدرسه و کتابخانه'
  ];

  final List<String> areaImages = [
    'street_area_1.png',
    'street_area_2.png',
    'street_area_3.png',
    'street_area_4.png',
    'street_area_5.jpg',
    'street_area_6.png',
  ];

  final List<int> taxiAreas = [4, 5]; 
  final int taxiCost = 40000;

  final List<Map<String, dynamic>> dialogues = [
    {"speaker": "مادر", "text": "آرین! پاشو مادر، ساعت هفت و نیمه!", "portrait": "mother_portrait.png"},
    {"speaker": "آرین", "text": "مامان، پنج دقیقه دیگه...", "portrait": "arian_portrait.png"},
    {"speaker": "مادر", "text": "پنج دقیقه دیگه یعنی چی؟ مغازه رو کی می‌خوای باز کنی؟", "portrait": "mother_portrait.png"},
    {"speaker": "آرین", "text": "الان بلند می‌شم!", "portrait": "arian_portrait.png"},
    {"speaker": "مادر", "text": "صبحانه‌ات رو هم آماده کردم. زودتر بیا.", "portrait": "mother_portrait.png"},
  ];

  @override
  void initState() {
    super.initState();
    _game = ShopGame();
  }

  void _startDialogue() {
    setState(() {
      showDialogue = true;
      dialogueIndex = 0;
      _game.moveLeft = false;
      _game.moveRight = false;
      _updateSpeakerImage(0);
    });
  }

  void _updateSpeakerImage(int index) {
    setState(() {
      currentSpeakerImage = dialogues[index]["portrait"];
    });
  }

  void _nextDialogue() {
    if (dialogueIndex < dialogues.length - 1) {
      setState(() {
        dialogueIndex++;
        _updateSpeakerImage(dialogueIndex);
      });
    } else {
      setState(() {
        showDialogue = false;
        dialogueIndex = 0;
      });
    }
  }

  void _requestTaxi(int newArea) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2C),
          title: const Text("تاکسی", style: TextStyle(color: Colors.amber)),
          content: Text(
            "برای رفتن به ${areaNames[newArea]} باید تاکسی بگیرید.\nهزینه: ۴۰,۰۰۰ تومان",
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("لغو", style: TextStyle(color: Colors.redAccent)),
            ),
            ElevatedButton(
              onPressed: () {
                if (gameState.buyPersonal(taxiCost)) {
                  Navigator.pop(context);
                  setState(() {
                    _game.changeArea(newArea, areaImages[newArea]);
                  });
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('پول کافی برای تاکسی نداری! باید بیشتر کار کنی.')),
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
                    border: Border.all(color: Colors.blueAccent, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.store, color: Colors.blueAccent, size: 18),
                      const SizedBox(width: 5),
                      Text('${gameState.shopMoney}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.amber, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: Colors.amber, size: 18),
                      const SizedBox(width: 5),
                      Text('${gameState.arianMoney}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                ),
              ],
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
                    onTapDown: (_) {
                      if (_game.isNearRightEdge) {
                        int newArea = _game.currentArea + 1;
                        if (newArea < areaImages.length) {
                          if (taxiAreas.contains(newArea)) {
                            _requestTaxi(newArea);
                          } else {
                            setState(() {
                              _game.changeArea(newArea, areaImages[newArea]);
                            });
                          }
                        }
                      } else {
                        _game.moveRight = true;
                      }
                    },
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
                          Text(dialogues[dialogueIndex]["speaker"]!, style: const TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text(dialogues[dialogueIndex]["text"]!, style: const TextStyle(color: Colors.white, fontSize: 18)),
                          const SizedBox(height: 10),
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
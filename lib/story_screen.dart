import 'package:flutter/material.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final List<Map<String, dynamic>> dialogues = [
    {
      "speaker": "راوی",
      "text": "ساعت ۸ صبحه. مغازه‌ی عمو رضا تازه باز شده. آرین مثل همیشه اول از همه رسیده.",
      "image": "assets/images/narrator.png",
      "color": Colors.grey.shade700,
      "icon": Icons.book
    },
    {
      "speaker": "عمو رضا",
      "text": "آرین! این ویترین رو دوباره چیدی؟",
      "image": "assets/images/uncle_portrait.png",
      "color": Colors.orange.shade800,
      "icon": Icons.face_retouching_natural
    },
    {
      "speaker": "آرین",
      "text": "صبح بخیر عمو. دیروز که خودت گفتی به‌هم‌ریخته‌ست.",
      "image": "assets/images/arian_portrait.png",
      "color": Colors.blue.shade700,
      "icon": Icons.person
    },
    {
      "speaker": "عمو رضا",
      "text": "گفتم به‌هم‌ریخته، نگفتم مثل نمایشگاه اپل بچینش!",
      "image": "assets/images/uncle_portrait.png",
      "color": Colors.orange.shade800,
      "icon": Icons.face_retouching_natural
    }
  ];

  int currentIndex = 0;

  void nextDialogue() {
    if (currentIndex < dialogues.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      Navigator.pushReplacementNamed(context, '/game');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentDialogue = dialogues[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentDialogue["color"],
                      boxShadow: [
                        BoxShadow(
                          color: currentDialogue["color"].withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ]
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        currentDialogue["image"],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            currentDialogue["icon"],
                            size: 100,
                            color: Colors.white,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: currentDialogue["color"], width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentDialogue["speaker"],
                        style: TextStyle(
                          color: currentDialogue["color"],
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Text(
                          currentDialogue["text"],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            height: 1.5,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton(
                          onPressed: nextDialogue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: currentDialogue["color"],
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            currentIndex == dialogues.length - 1 ? "ورود به مغازه" : "ادامه",
                            style: const TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
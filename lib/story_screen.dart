
import 'package:flutter/material.dart';
import 'story_data.dart';

class StoryScreen extends StatefulWidget {
  final VoidCallback? onClose;

  const StoryScreen({
    super.key,
    this.onClose,
  });

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  int currentIndex = 0;

  void nextDialogue() {
    if (currentIndex < storyData.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      widget.onClose?.call();
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final line = storyData[currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF17243D),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.amber,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/${line.portrait}',
                  width: 115,
                  height: 150,
                  fit: BoxFit.contain,
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        line.speaker,
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        line.text,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          height: 1.7,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                ElevatedButton(
                  onPressed: nextDialogue,
                  child: const Text('ادامه'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

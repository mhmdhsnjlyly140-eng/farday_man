
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'game_state.dart';

class ShopScreen extends StatefulWidget {
  final GameState gameState;

  const ShopScreen({
    super.key,
    required this.gameState,
  });

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final Random random = Random();

  Timer? timer;

  int coinPrice = 75000000;
  int change = 0;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(seconds: 2),
      (_) {
        if (!mounted) return;

        setState(() {
          change = random.nextInt(1000000) - 500000;
          coinPrice = max(1000000, coinPrice + change);
        });
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String formatPrice(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17243D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF263B5C),
        foregroundColor: Colors.white,
        title: const Text('طلافروشی'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/icon_coin.png',
              width: 90,
              height: 90,
            ),

            const SizedBox(height: 20),

            const Text(
              'قیمت لحظه‌ای سکه',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              '${formatPrice(coinPrice)} تومان',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              change >= 0
                  ? 'افزایش قیمت: ${formatPrice(change)}'
                  : 'کاهش قیمت: ${formatPrice(change.abs())}',
              style: TextStyle(
                color: change >= 0
                    ? Colors.greenAccent
                    : Colors.redAccent,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 25),

            Text(
              'موجودی سکه: ${widget.gameState.coins}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

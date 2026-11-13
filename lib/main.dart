
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game_widget.dart';

import 'game/shop_game.dart';
import 'game_state.dart';
import 'shop_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  runApp(const MyGameApp());
}

class MyGameApp extends StatelessWidget {
  const MyGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'فردای من',
      theme: ThemeData(
        fontFamily: 'Arial',
        useMaterial3: true,
      ),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final Future<GameState> stateFuture = GameState.load();

  ShopGame? game;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GameState>(
      future: stateFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final gameState = snapshot.data!;
        game ??= ShopGame();

        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: GameWidget<ShopGame>(
                  game: game!,
                ),
              ),

              // نوار انرژی و سکه
              Positioned(
                top: 12,
                right: 18,
                child: AnimatedBuilder(
                  animation: gameState,
                  builder: (context, child) {
                    return Row(
                      children: [
                        _statusBox(
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/icon_energy.png',
                                width: 25,
                                height: 25,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${gameState.energy}/5',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ShopScreen(
                                  gameState: gameState,
                                ),
                              ),
                            );
                          },
                          child: _statusBox(
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/icon_coin.png',
                                  width: 25,
                                  height: 25,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${gameState.coins}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // دکمه حرکت چپ
              Positioned(
                bottom: 25,
                left: 55,
                child: _movementButton(
                  icon: Icons.arrow_back_ios_new,
                  onDown: game!.moveLeft,
                  onUp: game!.stopPlayer,
                ),
              ),

              // دکمه حرکت راست
              Positioned(
                bottom: 25,
                right: 55,
                child: _movementButton(
                  icon: Icons.arrow_forward_ios,
                  onDown: game!.moveRight,
                  onUp: game!.stopPlayer,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statusBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: child,
    );
  }

  Widget _movementButton({
    required IconData icon,
    required VoidCallback onDown,
    required VoidCallback onUp,
  }) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => onDown(),
      onPointerUp: (_) => onUp(),
      onPointerCancel: (_) => onUp(),
      child: Container(
        width: 105,
        height: 105,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
            width: 3,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 42,
        ),
      ),
    );
  }
}

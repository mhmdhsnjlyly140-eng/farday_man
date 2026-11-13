
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameState extends ChangeNotifier {
  int coins = 0;
  int energy = 5;

  static Future<GameState> load() async {
    final state = GameState();
    final prefs = await SharedPreferences.getInstance();

    state.coins = prefs.getInt('coins') ?? 0;
    state.energy = prefs.getInt('energy') ?? 5;

    return state;
  }

  Future<void> addCoins(int amount) async {
    coins += amount;
    await _save();
    notifyListeners();
  }

  Future<bool> spendCoins(int amount) async {
    if (coins < amount) return false;

    coins -= amount;
    await _save();
    notifyListeners();
    return true;
  }

  Future<void> useEnergy() async {
    if (energy <= 0) return;

    energy--;
    await _save();
    notifyListeners();
  }

  Future<void> restoreEnergy() async {
    energy = 5;
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('coins', coins);
    await prefs.setInt('energy', energy);
  }
}

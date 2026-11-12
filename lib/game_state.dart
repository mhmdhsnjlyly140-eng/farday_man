import 'package:shared_preferences/shared_preferences.dart';

class GameState {
  static final GameState _instance = GameState._internal();
  factory GameState() => _instance;
  GameState._internal();

  int shopMoney = 100000;
  int arianMoney = 50000;
  int coins = 0;
  int day = 1;

  Future<void> saveGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('shopMoney', shopMoney);
    await prefs.setInt('arianMoney', arianMoney);
    await prefs.setInt('coins', coins);
    await prefs.setInt('day', day);
  }

  Future<void> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    shopMoney = prefs.getInt('shopMoney') ?? 100000;
    arianMoney = prefs.getInt('arianMoney') ?? 50000;
    coins = prefs.getInt('coins') ?? 0;
    day = prefs.getInt('day') ?? 1;
  }

  void addSaleIncome(int totalAmount) {
    int shopShare = (totalAmount * 0.8).toInt();
    int arianShare = totalAmount - shopShare;
    shopMoney += shopShare;
    arianMoney += arianShare;
    saveGame();
  }

  bool buyPersonal(int cost) {
    if (arianMoney >= cost) {
      arianMoney -= cost;
      saveGame();
      return true;
    }
    return false;
  }
}
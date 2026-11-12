import 'package:shared_preferences/shared_preferences.dart';

class GameState {
  static final GameState _instance = GameState._internal();
  factory GameState() => _instance;
  GameState._internal();

  int shopMoney = 100000;
  int arianMoney = 50000;
  int coins = 0;
  int day = 1;

  // 🌟 سیستم انرژی
  int maxEnergy = 5;
  int currentEnergy = 5;
  DateTime? lastEnergyUpdate;

  // 🌟 قیمت لحظه‌ای سکه (طلا)
  int currentCoinPrice = 1700000;

  // 🌟 ذخیره و لود
  Future<void> saveGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('shopMoney', shopMoney);
    await prefs.setInt('arianMoney', arianMoney);
    await prefs.setInt('coins', coins);
    await prefs.setInt('day', day);
    await prefs.setInt('currentEnergy', currentEnergy);
    await prefs.setString('lastEnergyUpdate', (lastEnergyUpdate ?? DateTime.now()).toIso8601String());
    await prefs.setInt('currentCoinPrice', currentCoinPrice);
  }

  Future<void> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    shopMoney = prefs.getInt('shopMoney') ?? 100000;
    arianMoney = prefs.getInt('arianMoney') ?? 50000;
    coins = prefs.getInt('coins') ?? 0;
    day = prefs.getInt('day') ?? 1;
    currentEnergy = prefs.getInt('currentEnergy') ?? 5;
    currentCoinPrice = prefs.getInt('currentCoinPrice') ?? 1700000;

    String? lastUpdateStr = prefs.getString('lastEnergyUpdate');
    if (lastUpdateStr != null) {
      lastEnergyUpdate = DateTime.parse(lastUpdateStr);
      _regenEnergy();
    }
  }

  // 🌟 پر شدن انرژی (هر ۴۵ دقیقه ۱ قلب)
  void _regenEnergy() {
    if (lastEnergyUpdate == null) {
      lastEnergyUpdate = DateTime.now();
      return;
    }

    final now = DateTime.now();
    final difference = now.difference(lastEnergyUpdate!);
    final minutesPassed = difference.inMinutes;
    final energyToAdd = minutesPassed ~/ 45; // هر ۴۵ دقیقه ۱ قلب

    if (energyToAdd > 0) {
      currentEnergy = (currentEnergy + energyToAdd).clamp(0, maxEnergy);
      lastEnergyUpdate = now;
    }
  }

  // 🌟 مصرف انرژی
  bool useEnergy(int amount) {
    _regenEnergy();
    if (currentEnergy >= amount) {
      currentEnergy -= amount;
      saveGame();
      return true;
    }
    return false;
  }

  // 🌟 نوسان قیمت سکه
  void fluctuateCoinPrice() {
    int change = (DateTime.now().millisecondsSinceEpoch % 20000) - 10000; // بین -۱۰ تا +۱۰ هزار
    currentCoinPrice = (currentCoinPrice + change).clamp(1600000, 1850000);
    saveGame();
  }

  // 🌟 خرید سکه (طلا)
  bool buyCoin() {
    if (arianMoney >= currentCoinPrice) {
      arianMoney -= currentCoinPrice;
      coins++;
      saveGame();
      return true;
    }
    return false;
  }

  // 🌟 فروش سکه
  void sellCoin() {
    if (coins > 0) {
      coins--;
      arianMoney += currentCoinPrice;
      saveGame();
    }
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
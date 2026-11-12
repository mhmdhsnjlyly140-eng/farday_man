class GameState {
  static final GameState _instance = GameState._internal();
  factory GameState() => _instance;
  GameState._internal();

  int shopMoney = 100000; 
  int arianMoney = 50000; 
  int coins = 0;
  int knowledge = 0;
  int day = 1;
  List<String> inventory = [];

  void addSaleIncome(int totalAmount) {
    int shopShare = (totalAmount * 0.8).toInt();
    int arianShare = totalAmount - shopShare;
    shopMoney += shopShare;
    arianMoney += arianShare;
  }

  bool buyFromWholesaler(int cost) {
    if (shopMoney >= cost) {
      shopMoney -= cost;
      return true;
    }
    return false; 
  }

  bool buyPersonal(int cost) {
    if (arianMoney >= cost) {
      arianMoney -= cost;
      return true;
    }
    return false;
  }

  void addItem(String item) {
    inventory.add(item);
  }

  bool hasItem(String item) {
    return inventory.contains(item);
  }
}
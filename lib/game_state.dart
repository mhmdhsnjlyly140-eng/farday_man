class GameState {
  static final GameState _instance = GameState._internal();
  factory GameState() => _instance;
  GameState._internal();

  int money = 0;
  int day = 1;
  int knowledge = 0;

  void endDay() {
    day++;
    money += 50;
  }
}
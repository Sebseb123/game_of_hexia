import 'dart:math';

/// Rolls two standard six-sided dice.
class Dices {
  final diceValues = [1, 2, 3, 4, 5, 6];
  final random = Random();

  Dices();

  /// Returns the values of both dice separately for later display.
  (int, int) rollDices() {
    final dice1 = diceValues[random.nextInt(diceValues.length)];
    final dice2 = diceValues[random.nextInt(diceValues.length)];
    return (dice1, dice2);
  }
}

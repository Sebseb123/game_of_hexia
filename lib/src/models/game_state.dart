import 'package:game_of_hexia/src/models/bank_of_resource.dart';
import 'package:game_of_hexia/src/models/development_card_deck.dart';
import 'package:game_of_hexia/src/models/hexagon_board.dart';
import 'package:game_of_hexia/src/models/player.dart';

/// Stores the mutable state of one game session.
class GameState {
  final HexagonBoard gameBoard;
  final List<Player> players;
  final DevelopmentCardDeck developmentCardDeck = DevelopmentCardDeck();
  final BankOfResource bank = BankOfResource();

  int activePlayerIndex;
  Player? largestArmyOwner;
  Player? longestRoadOwner;

  GameState({
    required this.gameBoard,
    required this.players,
    this.activePlayerIndex = 0,
  });

  /// Returns the player whose turn is currently active.
  Player get activePlayer => players[activePlayerIndex];
}

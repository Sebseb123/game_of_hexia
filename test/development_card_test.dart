import 'package:flutter_test/flutter_test.dart';
import 'package:game_of_hexia/src/logic/dice.dart';
import 'package:game_of_hexia/src/logic/game_controller.dart';
import 'package:game_of_hexia/src/models/development_card_deck.dart';
import 'package:game_of_hexia/src/models/development_card_type.dart';
import 'package:game_of_hexia/src/models/hexagon_board.dart';
import 'package:game_of_hexia/src/models/player.dart';

void main() {
  test('creates a complete development card deck', () {
    final deck = DevelopmentCardDeck();

    expect(deck.cardDeck, hasLength(25));
    expect(
      deck.cardDeck.where((card) => card == DevelopmentCardType.knight),
      hasLength(14),
    );
    expect(
      deck.cardDeck.where((card) => card == DevelopmentCardType.monopoly),
      hasLength(2),
    );
    expect(
      deck.cardDeck.where((card) => card == DevelopmentCardType.roadBuilding),
      hasLength(2),
    );
    expect(
      deck.cardDeck.where((card) => card == DevelopmentCardType.yearOfPlenty),
      hasLength(2),
    );
    expect(
      deck.cardDeck.where((card) => card == DevelopmentCardType.victoryPoint),
      hasLength(5),
    );
  });

  test('active player buys the top development card', () {
    final player = Player(color: PlayerColor.blue, name: 'Blue')
      ..cattle = 1
      ..fishes = 1
      ..iron = 1;
    final controller = GameController(
      gameBoard: HexagonBoard(radius: 1),
      dice: Dices(),
      players: [player],
    );
    final expectedCard = controller.developmentCardDeck.cardDeck.last;

    final purchased = controller.developmentCardPurchase(player);

    expect(purchased, isTrue);
    expect(player.cattle, 0);
    expect(player.fishes, 0);
    expect(player.iron, 0);
    expect(player.developmentCards, [(expectedCard, false)]);
    expect(controller.developmentCardDeck.cardDeck, hasLength(24));
  });

  test('rejects a development card purchase without enough resources', () {
    final player = Player(color: PlayerColor.blue, name: 'Blue')
      ..cattle = 1
      ..fishes = 1;
    final controller = GameController(
      gameBoard: HexagonBoard(radius: 1),
      dice: Dices(),
      players: [player],
    );

    final purchased = controller.developmentCardPurchase(player);

    expect(purchased, isFalse);
    expect(player.cattle, 1);
    expect(player.fishes, 1);
    expect(player.iron, 0);
    expect(player.developmentCards, isEmpty);
    expect(controller.developmentCardDeck.cardDeck, hasLength(25));
  });

  test('rejects a development card purchase by an inactive player', () {
    final activePlayer = Player(color: PlayerColor.blue, name: 'Blue');
    final inactivePlayer = Player(color: PlayerColor.red, name: 'Red')
      ..cattle = 1
      ..fishes = 1
      ..iron = 1;
    final controller = GameController(
      gameBoard: HexagonBoard(radius: 1),
      dice: Dices(),
      players: [activePlayer, inactivePlayer],
    );

    final purchased = controller.developmentCardPurchase(inactivePlayer);

    expect(purchased, isFalse);
    expect(inactivePlayer.cattle, 1);
    expect(inactivePlayer.fishes, 1);
    expect(inactivePlayer.iron, 1);
    expect(inactivePlayer.developmentCards, isEmpty);
    expect(controller.developmentCardDeck.cardDeck, hasLength(25));
  });

  test('rejects a development card purchase when the deck is empty', () {
    final player = Player(color: PlayerColor.blue, name: 'Blue')
      ..cattle = 1
      ..fishes = 1
      ..iron = 1;
    final controller = GameController(
      gameBoard: HexagonBoard(radius: 1),
      dice: Dices(),
      players: [player],
    );
    controller.developmentCardDeck.cardDeck.clear();

    final purchased = controller.developmentCardPurchase(player);

    expect(purchased, isFalse);
    expect(player.cattle, 1);
    expect(player.fishes, 1);
    expect(player.iron, 1);
    expect(player.developmentCards, isEmpty);
  });
}

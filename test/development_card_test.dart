import 'package:flutter_test/flutter_test.dart';
import 'package:game_of_hexia/src/logic/dice.dart';
import 'package:game_of_hexia/src/logic/game_controller.dart';
import 'package:game_of_hexia/src/models/building_type.dart';
import 'package:game_of_hexia/src/models/development_card_deck.dart';
import 'package:game_of_hexia/src/models/development_card_type.dart';
import 'package:game_of_hexia/src/models/game_state.dart';
import 'package:game_of_hexia/src/models/hexagon_board.dart';
import 'package:game_of_hexia/src/models/player.dart';
import 'package:game_of_hexia/src/models/resource_type.dart';
import 'package:game_of_hexia/src/models/robber.dart';

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
      ..fish = 1
      ..iron = 1;
    final controller = GameController(
      state: GameState(gameBoard: HexagonBoard(radius: 1), players: [player]),
      dice: Dices(),
    );
    final expectedCard = controller.state.developmentCardDeck.cardDeck.last;

    final purchased = controller.developmentCardPurchase(player);

    expect(purchased, isTrue);
    expect(player.cattle, 0);
    expect(player.fish, 0);
    expect(player.iron, 0);
    expect(player.developmentCards, [(expectedCard, false)]);
    expect(controller.state.developmentCardDeck.cardDeck, hasLength(24));
  });

  test('rejects a development card purchase without enough resources', () {
    final player = Player(color: PlayerColor.blue, name: 'Blue')
      ..cattle = 1
      ..fish = 1;
    final controller = GameController(
      state: GameState(gameBoard: HexagonBoard(radius: 1), players: [player]),
      dice: Dices(),
    );

    final purchased = controller.developmentCardPurchase(player);

    expect(purchased, isFalse);
    expect(player.cattle, 1);
    expect(player.fish, 1);
    expect(player.iron, 0);
    expect(player.developmentCards, isEmpty);
    expect(controller.state.developmentCardDeck.cardDeck, hasLength(25));
  });

  test('rejects a development card purchase by an inactive player', () {
    final activePlayer = Player(color: PlayerColor.blue, name: 'Blue');
    final inactivePlayer = Player(color: PlayerColor.red, name: 'Red')
      ..cattle = 1
      ..fish = 1
      ..iron = 1;
    final controller = GameController(
      state: GameState(
        gameBoard: HexagonBoard(radius: 1),
        players: [activePlayer, inactivePlayer],
      ),
      dice: Dices(),
    );

    final purchased = controller.developmentCardPurchase(inactivePlayer);

    expect(purchased, isFalse);
    expect(inactivePlayer.cattle, 1);
    expect(inactivePlayer.fish, 1);
    expect(inactivePlayer.iron, 1);
    expect(inactivePlayer.developmentCards, isEmpty);
    expect(controller.state.developmentCardDeck.cardDeck, hasLength(25));
  });

  test('rejects a development card purchase when the deck is empty', () {
    final player = Player(color: PlayerColor.blue, name: 'Blue')
      ..cattle = 1
      ..fish = 1
      ..iron = 1;
    final controller = GameController(
      state: GameState(gameBoard: HexagonBoard(radius: 1), players: [player]),
      dice: Dices(),
    );
    controller.state.developmentCardDeck.cardDeck.clear();

    final purchased = controller.developmentCardPurchase(player);

    expect(purchased, isFalse);
    expect(player.cattle, 1);
    expect(player.fish, 1);
    expect(player.iron, 1);
    expect(player.developmentCards, isEmpty);
  });

  test('year of plenty takes two different resources from the bank', () {
    final player = Player(color: PlayerColor.blue, name: 'Blue');
    player.developmentCards.add((DevelopmentCardType.yearOfPlenty, true));
    final controller = GameController(
      state: GameState(gameBoard: HexagonBoard(radius: 1), players: [player]),
      dice: Dices(),
    );

    final played = controller.playYearOfPlentyCard(
      ResourceType.wood,
      ResourceType.iron,
    );

    expect(played, isTrue);
    expect(player.wood, 1);
    expect(player.iron, 1);
    expect(controller.state.bank.getAmount(ResourceType.wood), 18);
    expect(controller.state.bank.getAmount(ResourceType.iron), 18);
    expect(
      player.developmentCards,
      isNot(contains((DevelopmentCardType.yearOfPlenty, true))),
    );
  });

  test('year of plenty takes two cards of the same resource', () {
    final player = Player(color: PlayerColor.blue, name: 'Blue');
    player.developmentCards.add((DevelopmentCardType.yearOfPlenty, true));
    final controller = GameController(
      state: GameState(gameBoard: HexagonBoard(radius: 1), players: [player]),
      dice: Dices(),
    );

    final played = controller.playYearOfPlentyCard(
      ResourceType.fish,
      ResourceType.fish,
    );

    expect(played, isTrue);
    expect(player.fish, 2);
    expect(controller.state.bank.getAmount(ResourceType.fish), 17);
    expect(player.developmentCards, isEmpty);
  });

  test('rejects year of plenty when the bank lacks both cards', () {
    final player = Player(color: PlayerColor.blue, name: 'Blue');
    player.developmentCards.add((DevelopmentCardType.yearOfPlenty, true));
    final controller = GameController(
      state: GameState(gameBoard: HexagonBoard(radius: 1), players: [player]),
      dice: Dices(),
    );
    controller.state.bank.getResource(ResourceType.stone, amount: 18);

    final played = controller.playYearOfPlentyCard(
      ResourceType.stone,
      ResourceType.stone,
    );

    expect(played, isFalse);
    expect(player.stone, 0);
    expect(controller.state.bank.getAmount(ResourceType.stone), 1);
    expect(
      player.developmentCards,
      contains((DevelopmentCardType.yearOfPlenty, true)),
    );
  });

  test('monopoly transfers all cards of the selected resource', () {
    final activePlayer = Player(color: PlayerColor.blue, name: 'Blue');
    final firstVictim = Player(color: PlayerColor.red, name: 'Red')
      ..wood = 3
      ..fish = 1;
    final secondVictim = Player(color: PlayerColor.green, name: 'Green')
      ..wood = 2;
    activePlayer.developmentCards.add((DevelopmentCardType.monopoly, true));
    final controller = GameController(
      state: GameState(
        gameBoard: HexagonBoard(radius: 1),
        players: [activePlayer, firstVictim, secondVictim],
      ),
      dice: Dices(),
    );

    final played = controller.playMonopolyCard(ResourceType.wood);

    expect(played, isTrue);
    expect(activePlayer.wood, 5);
    expect(firstVictim.wood, 0);
    expect(firstVictim.fish, 1);
    expect(secondVictim.wood, 0);
    expect(activePlayer.developmentCards, isEmpty);
  });

  test('knight moves the robber, steals and removes the card', () {
    final board = HexagonBoard(radius: 1);
    final currentHexagon = board.getHexagons()[0];
    final targetHexagon = board.getHexagons()[1];
    board.robber = Robber(currentHexagon);
    final activePlayer = Player(color: PlayerColor.blue, name: 'Blue');
    final victim = Player(color: PlayerColor.red, name: 'Red')..wood = 1;
    activePlayer.developmentCards.add((DevelopmentCardType.knight, true));
    final controller = GameController(
      state: GameState(gameBoard: board, players: [activePlayer, victim]),
      dice: Dices(),
    );

    final played = controller.playAKnightCard(
      activePlayer,
      targetHexagon,
      victim,
    );

    expect(played, isTrue);
    expect(board.robber!.currentPosition, targetHexagon);
    expect(activePlayer.wood, 1);
    expect(victim.wood, 0);
    expect(activePlayer.playedKnights, 1);
    expect(activePlayer.developmentCards, isEmpty);
  });

  test('largest army is awarded and transferred to a stronger player', () {
    final firstPlayer = Player(color: PlayerColor.blue, name: 'Blue')
      ..playedKnights = 3;
    final secondPlayer = Player(color: PlayerColor.red, name: 'Red')
      ..playedKnights = 2;
    final controller = GameController(
      state: GameState(
        gameBoard: HexagonBoard(radius: 1),
        players: [firstPlayer, secondPlayer],
      ),
      dice: Dices(),
    );

    controller.updateLargestArmyOwner();

    expect(controller.state.largestArmyOwner, firstPlayer);
    expect(firstPlayer.winPoints, 2);

    secondPlayer.playedKnights = 4;
    controller.updateLargestArmyOwner();

    expect(controller.state.largestArmyOwner, secondPlayer);
    expect(firstPlayer.winPoints, 0);
    expect(secondPlayer.winPoints, 2);
  });

  test('road building places one road without resource costs', () {
    final board = HexagonBoard(radius: 1);
    final player = Player(color: PlayerColor.blue, name: 'Blue');
    player.developmentCards.add((DevelopmentCardType.roadBuilding, true));
    final controller = GameController(
      state: GameState(gameBoard: board, players: [player]),
      dice: Dices(),
    );
    final edge = board.allEdges.first;
    edge.n.owner = PlayerColor.blue;
    edge.n.building = BuildingType.settlement;

    final played = controller.playRoadDevelopmentCard(edge);

    expect(played, isTrue);
    expect(edge.roadOwner, PlayerColor.blue);
    expect(player.remainingRoads, 14);
    expect(player.wood, 0);
    expect(player.stone, 0);
  });
}

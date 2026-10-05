import 'package:flutter_test/flutter_test.dart';
import 'package:game_of_hexia/src/logic/dice.dart';
import 'package:game_of_hexia/src/logic/game_controller.dart';
import 'package:game_of_hexia/src/models/building_type.dart';
import 'package:game_of_hexia/src/models/hexagon_board.dart';
import 'package:game_of_hexia/src/models/player.dart';
import 'package:game_of_hexia/src/models/resource_type.dart';
import 'package:game_of_hexia/src/models/robber.dart';

void main() {
  test('rolls values between 2 and 12', () {
    final board = HexagonBoard(radius: 2);
    final controller = GameController(
      gameBoard: board,
      dice: Dices(),
      players: [],
    );

    for (var i = 0; i < 100; i++) {
      expect(controller.rollDice(), inInclusiveRange(2, 12));
    }
  });

  test('gives a settlement one resource from a rolled field', () {
    final board = HexagonBoard(radius: 1);
    final hexagon = board.getHexagon(1, 0)!;
    hexagon.type = ResourceType.wood;
    hexagon.numberDisc = 8;
    final node = board.getNode(hexagon.top.x, hexagon.top.y)!;
    node.owner = PlayerColor.blue;
    node.building = BuildingType.settlement;
    final player = Player(color: PlayerColor.blue, name: 'Blue');
    final controller = GameController(
      gameBoard: board,
      dice: Dices(),
      players: [player],
    );

    controller.distributeResources(8);

    expect(player.wood, 1);
  });

  test('gives a city two resources from a rolled field', () {
    final board = HexagonBoard(radius: 1);
    final hexagon = board.getHexagon(1, 0)!;
    hexagon.type = ResourceType.iron;
    hexagon.numberDisc = 6;
    final node = board.getNode(hexagon.top.x, hexagon.top.y)!;
    node.owner = PlayerColor.red;
    node.building = BuildingType.city;
    final player = Player(color: PlayerColor.red, name: 'Red');
    final controller = GameController(
      gameBoard: board,
      dice: Dices(),
      players: [player],
    );

    controller.distributeResources(6);

    expect(player.iron, 2);
  });

  test('discards the selected resource amounts for the robber', () {
    final player = Player(color: PlayerColor.blue, name: 'Blue');
    final controller = GameController(
      gameBoard: HexagonBoard(radius: 1),
      dice: Dices(),
      players: [player],
    );
    player.wood = 4;
    player.fish = 4;

    final discarded = controller.discardResourcesForRobber(player, {
      ResourceType.wood: 2,
      ResourceType.fish: 2,
    });

    expect(discarded, isTrue);
    expect(player.wood, 2);
    expect(player.fish, 2);
  });

  test(
    'rejects invalid robber resource amounts without changing the player',
    () {
      final player = Player(color: PlayerColor.blue, name: 'Blue');
      final controller = GameController(
        gameBoard: HexagonBoard(radius: 1),
        dice: Dices(),
        players: [player],
      );
      player.wood = 4;
      player.fish = 4;

      final discarded = controller.discardResourcesForRobber(player, {
        ResourceType.wood: 5,
        ResourceType.fish: -1,
      });

      expect(discarded, isFalse);
      expect(player.wood, 4);
      expect(player.fish, 4);
    },
  );

  test('steals one card from the victim and gives it to the active player', () {
    final active = Player(color: PlayerColor.blue, name: 'Blue');
    final victim = Player(color: PlayerColor.red, name: 'Red');
    final controller = GameController(
      gameBoard: HexagonBoard(radius: 1),
      dice: Dices(),
      players: [active, victim],
    );
    victim.wood = 3;
    victim.fish = 2;

    final stolen = controller.stealRandomResource(victim);

    expect(stolen, isNotNull);
    expect(victim.getResourceCards().values.fold(0, (sum, n) => sum + n), 4);
    expect(active.getResourceCards().values.fold(0, (sum, n) => sum + n), 1);
  });

  test('steals nothing when the victim has no cards left', () {
    final active = Player(color: PlayerColor.blue, name: 'Blue');
    final victim = Player(color: PlayerColor.red, name: 'Red');
    final controller = GameController(
      gameBoard: HexagonBoard(radius: 1),
      dice: Dices(),
      players: [active, victim],
    );

    expect(controller.stealRandomResource(victim), isNull);
    expect(active.getResourceCards(), isEmpty);
  });

  test('does not give resources from a field blocked by the robber', () {
    final board = HexagonBoard(radius: 1);
    final hexagon = board.getHexagon(1, 0)!;
    hexagon.type = ResourceType.wood;
    hexagon.numberDisc = 8;
    final node = board.getNode(hexagon.top.x, hexagon.top.y)!;
    node.owner = PlayerColor.blue;
    node.building = BuildingType.settlement;
    final player = Player(color: PlayerColor.blue, name: 'Blue');
    final controller = GameController(
      gameBoard: board,
      dice: Dices(),
      players: [player],
    );
    board.robber = Robber(hexagon);

    controller.distributeResources(8);

    expect(player.wood, 0);
  });

  test('checks the possibleToPlaceSettlement method', () {
    final board = HexagonBoard(radius: 2);
    final player = Player(color: PlayerColor.blue, name: 'Blue');
    final controller = GameController(
      gameBoard: board,
      dice: Dices(),
      players: [player],
    );
    final corner = board.getHexagon(2, 0)!.bottomRight;
    final node = board.getNode(corner.x, corner.y)!;

    expect(controller.possibleToPlaceSettlement(node), isTrue);

    node.owner = PlayerColor.blue;
    node.building = BuildingType.settlement;
    expect(controller.possibleToPlaceSettlement(node), isFalse);

    node.owner = null;
    node.building = null;
    final neighbor = board.getAdjacentNodesToNode(node).first;
    neighbor.owner = PlayerColor.red;
    neighbor.building = BuildingType.settlement;
    expect(controller.possibleToPlaceSettlement(node), isFalse);
  });

  test('checks the possibleToPlaceCity method', () {
    final board = HexagonBoard(radius: 2);
    final player = Player(color: PlayerColor.blue, name: 'Blue');
    final controller = GameController(
      gameBoard: board,
      dice: Dices(),
      players: [player],
    );
    final corner = board.getHexagon(2, 0)!.bottomRight;
    final node = board.getNode(corner.x, corner.y)!;

    node.owner = PlayerColor.blue;
    node.building = BuildingType.settlement;
    expect(controller.possibleToPlaceCity(node), isTrue);

    node.owner = PlayerColor.red;
    expect(controller.possibleToPlaceCity(node), isFalse);

    node.owner = PlayerColor.blue;
    final neighbor = board.getAdjacentNodesToNode(node).first;
    neighbor.owner = PlayerColor.red;
    neighbor.building = BuildingType.settlement;
    expect(controller.possibleToPlaceCity(node), isFalse);
  });

  test('checks the possibleToPlaceRoad method', () {
    final board = HexagonBoard(radius: 2);
    final player = Player(color: PlayerColor.blue, name: 'Blue');
    final controller = GameController(
      gameBoard: board,
      dice: Dices(),
      players: [player],
    );
    final edge = board.allEdges.first;

    expect(controller.possibleToPlaceRoad(edge), isFalse);

    edge.n.owner = PlayerColor.blue;
    edge.n.building = BuildingType.settlement;
    expect(controller.possibleToPlaceRoad(edge), isTrue);

    edge.n.owner = null;
    edge.n.building = null;
    final connectedEdge = board.allEdges.firstWhere(
      (otherEdge) =>
          otherEdge != edge && (otherEdge.n == edge.n || otherEdge.m == edge.n),
    );
    connectedEdge.roadOwner = PlayerColor.blue;
    expect(controller.possibleToPlaceRoad(edge), isTrue);

    edge.n.owner = PlayerColor.red;
    edge.n.building = BuildingType.settlement;
    expect(controller.possibleToPlaceRoad(edge), isFalse);

    edge.m.owner = PlayerColor.blue;
    edge.m.building = BuildingType.settlement;
    expect(controller.possibleToPlaceRoad(edge), isTrue);

    edge.roadOwner = PlayerColor.red;
    expect(controller.possibleToPlaceRoad(edge), isFalse);
  });

  test('pays city costs only with enough resources', () {
    final player = Player(color: PlayerColor.blue, name: 'Blue');
    final controller = GameController(
      gameBoard: HexagonBoard(radius: 1),
      dice: Dices(),
      players: [player],
    );
    player.iron = 3;
    player.fish = 2;

    expect(controller.tryPayForCity(player), isTrue);
    expect(player.iron, 0);
    expect(player.fish, 0);

    player.iron = 2;
    player.fish = 2;
    expect(controller.tryPayForCity(player), isFalse);
    expect(player.iron, 2);
    expect(player.fish, 2);
  });

  test('pays road costs only with enough resources', () {
    final player = Player(color: PlayerColor.blue, name: 'Blue');
    final controller = GameController(
      gameBoard: HexagonBoard(radius: 1),
      dice: Dices(),
      players: [player],
    );
    player.wood = 1;
    player.stone = 1;

    expect(controller.tryPayForRoad(player), isTrue);
    expect(player.wood, 0);
    expect(player.stone, 0);

    player.wood = 1;
    expect(controller.tryPayForRoad(player), isFalse);
    expect(player.wood, 1);
    expect(player.stone, 0);
  });

  test('upgrades an owned settlement to a city', () {
    final board = HexagonBoard(radius: 1);
    final player = Player(color: PlayerColor.blue, name: 'Blue');
    final controller = GameController(
      gameBoard: board,
      dice: Dices(),
      players: [player],
    );
    final hexagon = board.getHexagon(1, 0)!;
    final node = board.getNode(hexagon.top.x, hexagon.top.y)!;
    node.owner = PlayerColor.blue;
    node.building = BuildingType.settlement;
    player.remainingSettlements = 4;
    player.iron = 3;
    player.fish = 2;

    expect(controller.upgradeSettlementToCity(node), isTrue);
    expect(node.building, BuildingType.city);
    expect(player.remainingCities, 3);
    expect(player.remainingSettlements, 5);
    expect(player.iron, 0);
    expect(player.fish, 0);
  });

  test('places and pays for a road', () {
    final board = HexagonBoard(radius: 1);
    final player = Player(color: PlayerColor.blue, name: 'Blue');
    final controller = GameController(
      gameBoard: board,
      dice: Dices(),
      players: [player],
    );
    final edge = board.allEdges.first;
    edge.n.owner = PlayerColor.blue;
    edge.n.building = BuildingType.settlement;
    player.wood = 1;
    player.stone = 1;

    expect(controller.placeRoad(edge), isTrue);
    expect(edge.roadOwner, PlayerColor.blue);
    expect(player.remainingRoads, 14);
    expect(player.wood, 0);
    expect(player.stone, 0);

    expect(controller.placeRoad(edge), isFalse);
    expect(player.remainingRoads, 14);
  });
}

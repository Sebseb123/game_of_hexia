import 'package:flutter_test/flutter_test.dart';
import 'package:game_of_hexia/src/logic/dice.dart';
import 'package:game_of_hexia/src/logic/game_controller.dart';
import 'package:game_of_hexia/src/models/building_type.dart';
import 'package:game_of_hexia/src/models/hexagon_board.dart';
import 'package:game_of_hexia/src/models/player.dart';
import 'package:game_of_hexia/src/models/resource_type.dart';

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

    expect(player.woods, 1);
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
}

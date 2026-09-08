import 'package:flutter_test/flutter_test.dart';
import 'package:game_of_hexia/src/models/hexagon_board.dart';

void main() {
  test('finds the three hexagons adjacent to a shared node', () {
    final board = HexagonBoard();
    board.placeHexagons();
    board.initNodes();
    final node = board.getHexagon(2, 0)!.bottomRight;

    final adjacentHexagons = board.getAdjacentHexagonsToNode(
      Node(x: node.x, y: node.y),
    );

    expect(adjacentHexagons, hasLength(3));
    expect(
      adjacentHexagons.map((hexagon) => hexagon.axial).toSet(),
      {
        (x: 2, y: 0),
        (x: 3, y: 0),
        (x: 2, y: 1),
      },
    );
  });
}

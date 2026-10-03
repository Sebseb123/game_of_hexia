import 'package:flutter_test/flutter_test.dart';
import 'package:game_of_hexia/src/models/hexagon_board.dart';
import 'package:game_of_hexia/src/models/node.dart';
import 'package:game_of_hexia/src/models/edge.dart';




void main() {

  group('HexagonBoard', (){
  test('creates boards with the correct number of hexagons', () {
    expect(HexagonBoard(radius: 1).length, 7);
    expect(HexagonBoard(radius: 2).length, 19);
    expect(HexagonBoard(radius: 3).length, 37);
  });

  test('finds the three hexagons adjacent to a shared node', () {

    final board = HexagonBoard(radius: 2);
    final node = board.getHexagon(2, 0)!.bottomRight;
    final adjacentHexagons = board.getAdjacentHexagonsToNode(
      Node(x: node.x, y: node.y),
    );
    expect(adjacentHexagons, hasLength(3));
    expect(adjacentHexagons.map((hexagon) => hexagon.axial).toSet(), {
      (x: 2, y: 0),
      (x: 3, y: 0),
      (x: 2, y: 1),
    });
  });

  test('init the Edges Set and check the amount of edges depended on the board size ', (){
    final board = HexagonBoard(radius: 2);
    expect(board.allEdges, hasLength(72));
  });

  test('initializes every board node once', () {
    final board = HexagonBoard(radius: 2);

    expect(board.initNodes(), hasLength(54));
  });

  test('treats reversed edges as duplicates', () {
    final a = Node(x: 0, y: 0);
    final b = Node(x: 0.5, y: 0.25);

    final edges = {
      Edge(a, b),
      Edge(b, a),
    };
    expect(edges, hasLength(1));
  });

  test('checks amound of adjacents nodes to an inner node and an outer node', () {

    final board = HexagonBoard(radius: 2);

    final corner = board.getHexagon(1, 0)!.top;
    Node? outerNode = board.getNode(corner.x, corner.y)!;
    expect(board.getAdjacentNodesToNode(outerNode), hasLength(2));

    final corner2 = board.getHexagon(2, 0)!.bottomRight;
    Node? innerNode = board.getNode(corner2.x, corner2.y);
    expect(board.getAdjacentNodesToNode(innerNode!), hasLength(3));

  });

  });
}

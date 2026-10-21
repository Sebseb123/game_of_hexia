import 'package:flutter_test/flutter_test.dart';
import 'package:game_of_hexia/src/models/edge.dart';
import 'package:game_of_hexia/src/models/hexagon_board.dart';
import 'package:game_of_hexia/src/models/node.dart';

void main() {
  group('HexagonBoard', () {
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

    test('creates every board edge once', () {
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

      final edges = {Edge(a, b), Edge(b, a)};
      expect(edges, hasLength(1));
    });

    test('finds the adjacent nodes of outer and inner nodes', () {
      final board = HexagonBoard(radius: 2);

      final corner = board.getHexagon(1, 0)!.top;
      final outerNode = board.getNode(corner.x, corner.y)!;
      expect(board.getAdjacentNodesToNode(outerNode), hasLength(2));

      final corner2 = board.getHexagon(2, 0)!.bottomRight;
      final innerNode = board.getNode(corner2.x, corner2.y)!;
      expect(board.getAdjacentNodesToNode(innerNode), hasLength(3));
    });

    test('places harbors at least one node apart', () {
      final board = HexagonBoard(radius: 2);
      final harbors = board.harbors.toList();

      for (var i = 0; i < harbors.length; i++) {
        for (var j = i + 1; j < harbors.length; j++) {
          final firstEdge = harbors[i].edge;
          final secondEdge = harbors[j].edge;
          final distances = [
            board.getShortestDistance(firstEdge.n, secondEdge.n),
            board.getShortestDistance(firstEdge.n, secondEdge.m),
            board.getShortestDistance(firstEdge.m, secondEdge.n),
            board.getShortestDistance(firstEdge.m, secondEdge.m),
          ];

          expect(
            distances.every((distance) => distance != null && distance > 1),
            isTrue,
            reason: 'Harbors $i and $j are too close.',
          );
        }
      }
    });

    test('creates general and special harbors', () {
      for (final radius in [2, 3, 4]) {
        final board = HexagonBoard(radius: radius);

        expect(
          board.harbors.any((harbor) => harbor.exchangeRatio == 2),
          isTrue,
          reason: 'Radius $radius should have a general harbor.',
        );
        expect(
          board.harbors.any((harbor) => harbor.exchangeRatio == 3),
          isTrue,
          reason: 'Radius $radius should have a special harbor.',
        );
      }
    });
  });
}

import 'package:game_of_hexia/src/models/hexagon_board.dart';

import 'dart:io';

void main() {
  stdout.write('Radius eingeben: ');
  final radius = int.parse(stdin.readLineSync()!);
  final board = HexagonBoard(radius: radius);
  board.placeHexagons();
  board.placeNumberDiscs();
  print(board);
  final node = board.getHexagon(radius, 0)!.bottomRight;
  print(board.initNodes().length);
  final adjacentHexagons = board.getAdjacentHexagonsToNode(
    Node(x: node.x, y: node.y),
  );
  print(adjacentHexagons);
}

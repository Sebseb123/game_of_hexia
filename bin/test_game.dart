import 'package:game_of_hexia/src/models/hexagon_board.dart';

void main() {
  HexagonBoard board = HexagonBoard();
  board.placeHexagons();
  print(board);
  var node = board.getHexagon(2, 0)!.bottomRight;
  print(board.initNodes().length);
  final adjacentHexagons = board.getAdjacentHexagonsToNode(Node(x: node.x, y: node.y));
  print(adjacentHexagons);

}
import 'package:game_of_hexia/src/models/hexagon_board.dart';
import 'package:game_of_hexia/src/models/edge.dart';

void main() {
  final board = HexagonBoard(radius: 2);
  board.placeHexagons();
  print(board);
}
import 'package:game_of_hexia/src/logic/dice.dart';
import 'package:game_of_hexia/src/logic/game_controller.dart';
import 'package:game_of_hexia/src/models/hexagon_board.dart';
import 'package:game_of_hexia/src/models/player.dart';

import 'dart:io';

void main() {
  // Collect the players before creating the game controller.
  var playerCount = 0;
  while (playerCount < 2 || playerCount > 6) {
    stdout.write('Wie viele Spieler? (2-6): ');
    playerCount = int.tryParse(stdin.readLineSync() ?? '') ?? 0;
  }

  final players = <Player>[];
  while (players.length < playerCount) {
    final playerNumber = players.length + 1;
    stdout.write('Name von Spieler $playerNumber: ');
    final name = (stdin.readLineSync() ?? '').trim();
    if (name.isEmpty) {
      print('Der Name darf nicht leer sein.');
      continue;
    }

    for (var i = 0; i < PlayerColor.values.length; i++) {
      print('${i + 1}: ${PlayerColor.values[i].name}');
    }
    stdout.write('Farbe fuer Spieler $playerNumber waehlen: ');
    final colorIndex = int.tryParse(stdin.readLineSync() ?? '') ?? 0;
    if (colorIndex < 1 || colorIndex > PlayerColor.values.length) {
      print('Ungueltige Farbauswahl.');
      continue;
    }

    final color = PlayerColor.values[colorIndex - 1];
    if (players.any((player) => player.color == color)) {
      print('Diese Farbe wurde bereits gewaehlt.');
      continue;
    }
    players.add(Player(color: color, name: name));
  }

  // Create and populate a board with the selected size.
  stdout.write('Radius eingeben: ');
  final radius = int.parse(stdin.readLineSync()!);
  final board = HexagonBoard(radius: radius);
  final dice = Dices();
  final gameController = GameController(
    gameBoard: board,
    dice: dice,
    players: players,
  );

  board.placeHexagons();
  board.placeNumberDiscs();

  // Print the board and a few geometry and dice diagnostics.
  print(board);
  final node = board.getHexagon(radius, 0)!.bottomRight;
  print(board.initNodes().length);
  final adjacentHexagons = board.getAdjacentHexagonsToNode(
    Node(x: node.x, y: node.y),
  );
  print(adjacentHexagons);
  int rolled = gameController.rollDice();
  print(rolled);
  print(gameController.getRolledHexagons(rolled));

}

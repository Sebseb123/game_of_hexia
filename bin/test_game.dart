// ignore_for_file: avoid_print

import 'dart:io';

import 'package:game_of_hexia/src/logic/dice.dart';
import 'package:game_of_hexia/src/logic/game_controller.dart';
import 'package:game_of_hexia/src/models/development_card_type.dart';
import 'package:game_of_hexia/src/models/edge.dart';
import 'package:game_of_hexia/src/models/game_state.dart';
import 'package:game_of_hexia/src/models/hexagon.dart';
import 'package:game_of_hexia/src/models/hexagon_board.dart';
import 'package:game_of_hexia/src/models/node.dart';
import 'package:game_of_hexia/src/models/player.dart';
import 'package:game_of_hexia/src/models/resource_type.dart';

void main() {
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

  stdout.write('Radius eingeben: ');
  final radius = int.parse(stdin.readLineSync()!);
  final board = HexagonBoard(radius: radius);
  final dice = Dices();
  final gameController = GameController(
    state: GameState(gameBoard: board, players: players),
    dice: dice,
  );

  board.placeHexagons();
  board.placeNumberDiscs();

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
  if (rolled == 7) handleRobberTurn(gameController, rolled);
}

/// Prompts every affected player to discard the required resources.
void handleRobberDiscard(GameController gc) {
  for (final player in gc.state.players) {
    int amountToDiscard = gc.calculateCardsToThrowAway(player);
    if (amountToDiscard > 0) {
      while (true) {
        final selectedResources = readResourcesFromConsole(
          player,
          amountToDiscard,
        );
        if (gc.discardResourcesForRobber(player, selectedResources)) {
          break;
        }
        print('Der Spieler besitzt die ausgewählten Ressourcen nicht.');
      }
    }
  }
}

/// Prompts [player] until exactly [amount] resources are selected.
///
/// Returns an empty selection when [amount] is not positive.
Map<ResourceType, int> readResourcesFromConsole(Player player, int amount) {
  if (amount <= 0) {
    return {};
  }

  final resourceTypes = ResourceType.values.where(
    (resource) => resource != ResourceType.empty,
  );

  while (true) {
    print('${player.name} muss genau $amount Ressourcen abwerfen.');
    final selectedResources = <ResourceType, int>{};

    for (final resource in resourceTypes) {
      int? selectedAmount;

      while (selectedAmount == null) {
        stdout.write('${resource.name}: ');
        final input = stdin.readLineSync();
        final parsedAmount = int.tryParse(input?.trim() ?? '');

        if (parsedAmount == null || parsedAmount < 0) {
          print('Bitte eine nichtnegative ganze Zahl eingeben.');
          continue;
        }

        selectedAmount = parsedAmount;
      }

      if (selectedAmount > 0) {
        selectedResources[resource] = selectedAmount;
      }
    }

    final selectedCount = selectedResources.values.fold(
      0,
      (sum, resourceAmount) => sum + resourceAmount,
    );

    if (selectedCount == amount) {
      return selectedResources;
    }

    print(
      'Es wurden $selectedCount Ressourcen ausgewaehlt. '
      'Erforderlich sind genau $amount.',
    );
  }
}

/// Prompts for an opponent with a building adjacent to [target].
///
/// Returns null when no such opponent exists.
Player? pickVictimFromConsole(GameController gc, Hexagon target) {
  final victims = gc.getPossibleVictimsForRobber(target);

  if (victims.isEmpty) {
    print('Kein Gegner hat eine Siedlung an diesem Feld.');
    return null;
  }

  while (true) {
    print('Welchem Gegner möchtest Du eine Ressource stehlen?');

    for (var i = 0; i < victims.length; i++) {
      print('${i + 1}: ${victims[i].color.name} (${victims[i].name})');
    }

    stdout.write('Nummer des Gegners: ');
    final choice = int.tryParse(stdin.readLineSync() ?? '');

    if (choice == null || choice < 1 || choice > victims.length) {
      print('Bitte eine gueltige Nummer eingeben.');
      continue;
    }

    return victims[choice - 1];
  }
}

/// Prompts for a robber destination other than its current field.
///
/// Entering zero cancels the selection.
Hexagon? pickRobberTarget(GameController gc) {
  final board = gc.state.gameBoard;
  final currentPosition = board.robber?.currentPosition;
  final fields = board
      .getHexagons()
      .where((hex) => hex != currentPosition)
      .toList();

  while (true) {
    print('Wohin soll der Räuber gestellt werden?');

    for (var i = 0; i < fields.length; i++) {
      final hex = fields[i];
      final number = hex.numberDisc == 0 ? '' : ' (${hex.numberDisc})';
      print('${i + 1}: ${hex.type.name}$number');
    }

    stdout.write('Nummer des Feldes: ');
    final choice = int.tryParse(stdin.readLineSync() ?? '');

    if (choice == null) {
      print('Bitte eine Zahl eingeben.');
      continue;
    }

    if (choice == 0) {
      return null;
    }

    if (choice < 1 || choice > fields.length) {
      print('Bitte eine gueltige Nummer eingeben.');
      continue;
    }

    return fields[choice - 1];
  }
}

/// Handles discarding, robber movement, and stealing after a seven is rolled.
void handleRobberTurn(GameController gc, int diceValue) {
  if (diceValue != 7) return;

  gc.distributeResources(diceValue);
  handleRobberDiscard(gc);

  // Retry invalid destinations; cancellation leaves the robber in place.
  Hexagon? target;
  while (true) {
    final choice = pickRobberTarget(gc);

    if (choice == null) {
      print('Der Räuber bleibt liegen. Der Spieler hat ihn nicht versetzt.');
      return;
    }

    if (gc.moveRobber(choice)) {
      target = choice;
      break;
    }

    print('Der Räuber muss die Position wechseln. Bitte erneut wählen.');
  }

  final victim = pickVictimFromConsole(gc, target);
  if (victim == null) {
    return;
  }

  final stolen = gc.stealRandomResource(victim);
  if (stolen == null) {
    print('Der Gegner hat keine Karte zum Stehlen.');
    return;
  }

  print('Es wurde ${stolen.name} gestohlen.');
}

/// Prompts for a resource and plays the active player's Monopoly card.
void handlePlayedMonopolyCardTurn(GameController gc) {
  final resourceTypes = ResourceType.values
      .where((resource) => resource != ResourceType.empty)
      .toList();

  while (true) {
    print(
      'Du hast die Monopolkarte ausgespielt. '
      'Welche Ressource möchtest Du stehlen?',
    );

    for (var i = 0; i < resourceTypes.length; i++) {
      print('${i + 1}: ${resourceTypes[i].name}');
    }

    stdout.write('Nummer des Rohstoffs: ');
    final choice = int.tryParse(stdin.readLineSync() ?? '');

    if (choice == null || choice < 1 || choice > resourceTypes.length) {
      print('Bitte eine gueltige Nummer eingeben.');
      continue;
    }

    final ResourceType stealingType = resourceTypes[choice - 1];
    gc.playMonopolyCard(stealingType);
    return;
  }
}

/// Prompts for a robber target and plays the active player's Knight card.
void handlePlayedKnightCardTurn(GameController gc) {
  if (!gc.getActivePlayer().developmentCards.contains((
    DevelopmentCardType.knight,
    true,
  ))) {
    return;
  }

  final target = pickRobberTarget(gc);
  if (target == null) return;
  final victim = pickVictimFromConsole(gc, target);
  gc.playAKnightCard(gc.getActivePlayer(), target, victim);
}

/// Prompts for up to two free roads from a Road Building card.
void handleRoadDevelopmentCard(GameController gc) {
  if (!gc.getActivePlayer().developmentCards.contains((
    DevelopmentCardType.roadBuilding,
    true,
  ))) {
    return;
  }

  if (gc.getActivePlayer().remainingRoads <= 0) {
    gc.getActivePlayer().developmentCards.remove((
      DevelopmentCardType.roadBuilding,
      true,
    ));
    return;
  }

  List<Edge> possibleEdges = gc.getPossibleEdgesToPlaceRoad();
  if (possibleEdges.isEmpty) {
    gc.getActivePlayer().developmentCards.remove((
      DevelopmentCardType.roadBuilding,
      true,
    ));
    return;
  }

  while (true) {
    print(
      'Du hast die Straßenkarte ausgespielt. '
      'Auf welcher Kante möchtest Du eine Straße bauen?',
    );

    for (var i = 0; i < possibleEdges.length; i++) {
      print(
        '${i + 1}: '
        '(${possibleEdges[i].n.x}, ${possibleEdges[i].n.y}) -> '
        '(${possibleEdges[i].m.x}, ${possibleEdges[i].m.y})',
      );
    }

    stdout.write(
      'Schreib die Nummer des Kante: '
      'Möchtest Du keine weitere Straße bauen, tippe die 0.',
    );
    final choice = int.tryParse(stdin.readLineSync() ?? '');

    if (choice == 0) {
      gc.getActivePlayer().developmentCards.remove((
        DevelopmentCardType.roadBuilding,
        true,
      ));
      return;
    }

    if (choice == null || choice < 1 || choice > possibleEdges.length) {
      print('Bitte eine gueltige Nummer eingeben.');
      continue;
    }

    Edge firstRoad = possibleEdges[choice - 1];
    if (!gc.playRoadDevelopmentCard(firstRoad)) continue;
    break;
  }

  possibleEdges = gc.getPossibleEdgesToPlaceRoad();
  if (possibleEdges.isEmpty) {
    gc.getActivePlayer().developmentCards.remove((
      DevelopmentCardType.roadBuilding,
      true,
    ));
    return;
  }

  while (true) {
    if (gc.getActivePlayer().remainingRoads > 0) {
      print(
        'Du hast die Straßenkarte ausgespielt. '
        'Da du noch eine Straße bauen kannst: '
        'Auf welcher Kante möchtest Du deine zweite Straße bauen? '
        'Möchtest Du keine weitere Straße bauen, tippe die 0.',
      );

      for (var i = 0; i < possibleEdges.length; i++) {
        print(
          '${i + 1}: '
          '(${possibleEdges[i].n.x}, ${possibleEdges[i].n.y}) -> '
          '(${possibleEdges[i].m.x}, ${possibleEdges[i].m.y})',
        );
      }

      stdout.write('Schreib die Nummer des Kante: ');
      final choice = int.tryParse(stdin.readLineSync() ?? '');
      if (choice == 0) {
        gc.getActivePlayer().developmentCards.remove((
          DevelopmentCardType.roadBuilding,
          true,
        ));
        return;
      }

      if (choice == null || choice < 1 || choice > possibleEdges.length) {
        print('Bitte eine gueltige Nummer eingeben.');
        continue;
      }

      Edge secondRoad = possibleEdges[choice - 1];
      if (!gc.playRoadDevelopmentCard(secondRoad)) continue;
      gc.getActivePlayer().developmentCards.remove((
        DevelopmentCardType.roadBuilding,
        true,
      ));
      return;
    } else {
      gc.getActivePlayer().developmentCards.remove((
        DevelopmentCardType.roadBuilding,
        true,
      ));
      return;
    }
  }
}

/// Prompts for two available resources and plays Year of Plenty.
void handleYearOfPlentyCardTurn(GameController gc) {
  if (!gc.getActivePlayer().developmentCards.contains((
    DevelopmentCardType.yearOfPlenty,
    true,
  ))) {
    return;
  }

  final resourceTypes = ResourceType.values
      .where((resource) => resource != ResourceType.empty)
      .toList();
  final selectedResources = <ResourceType>[];

  while (selectedResources.length < 2) {
    print(
      'Welche Ressource möchtest Du als '
      '${selectedResources.length + 1}. Karte nehmen?',
    );

    for (var i = 0; i < resourceTypes.length; i++) {
      print(
        '${i + 1}: ${resourceTypes[i].name} '
        '(Bank: ${gc.state.bank.getAmount(resourceTypes[i])})',
      );
    }

    stdout.write('Nummer des Rohstoffs: ');
    final choice = int.tryParse(stdin.readLineSync() ?? '');

    if (choice == null || choice < 1 || choice > resourceTypes.length) {
      print('Bitte eine gueltige Nummer eingeben.');
      continue;
    }

    final resource = resourceTypes[choice - 1];
    final alreadySelected = selectedResources
        .where((selected) => selected == resource)
        .length;

    if (gc.state.bank.getAmount(resource) <= alreadySelected) {
      print('Dieser Rohstoff ist nicht ausreichend in der Bank vorhanden.');
      continue;
    }

    selectedResources.add(resource);
  }

  gc.playYearOfPlentyCard(selectedResources[0], selectedResources[1]);
}

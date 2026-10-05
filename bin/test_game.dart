import 'package:game_of_hexia/src/logic/dice.dart';
import 'package:game_of_hexia/src/logic/game_controller.dart';
import 'package:game_of_hexia/src/models/hexagon.dart';
import 'package:game_of_hexia/src/models/hexagon_board.dart';
import 'package:game_of_hexia/src/models/player.dart';
import 'package:game_of_hexia/src/models/node.dart';
import 'package:game_of_hexia/src/models/edge.dart';
import 'package:game_of_hexia/src/models/development_card_type.dart';
import 'package:game_of_hexia/src/models/resource_type.dart';

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
  if (rolled == 7) handleRobberTurn(gameController, rolled);
}

/// Durchläuft alle Spieler mit mehr als 7 Karten, ruft readResourcesFromConsole auf
/// und übergibt sie dem Controller
void handleRobberDiscard(GameController gc) {
  for (final player in gc.players) {
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

/// Liest die Auswahl der Ressourcen, die ein Spieler abwerfen möchte, wenn
/// der Räuber gewürfelt wurde und der Spieler mehr als 7 Karten besitzt
/// Vorübergehend als I/O, später über GUI
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

/// Fragt ab, von welchem Gegner am Hexagon [target] eine Ressource
/// gestohlen werden soll. Gibt null zurück, wenn niemand bestohlen
/// werden kann.
/// Vorübergehend als I/O, später über GUI
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

/// Fragt ab, auf welches Feld der Räuber gesetzt werden soll. Das aktuelle
/// Räuberfeld wird nicht angeboten, weil der Räuber die Position wechseln
/// muss. Gibt null zurück, wenn der Spieler abbrechen will.
/// Vorübergehend als I/O, später über GUI
Hexagon? pickRobberTarget(GameController gc) {
  final board = gc.gameBoard;
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

/// Den ganzen Ablauf des Räubers in einer Methode zusammengefasst
void handleRobberTurn(GameController gc, int diceValue) {
  if (diceValue != 7) return;

  gc.distributeResources(diceValue);
  handleRobberDiscard(gc); // 7-Karten-Regel

  // Der Räuber muss versetzt werden. Solange moveRobber scheitert, wird
  // erneut gefragt, damit der Zug nicht unvollständig endet.
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

  // Ziel ist jetzt die neue Position, nicht das Feld davor
  final victim = pickVictimFromConsole(gc, target);
  if (victim == null) {
    return;
  }

  // addResource braucht benannte Parameter, amount ist optional
  final stolen = gc.stealRandomResource(victim);
  if (stolen == null) {
    print('Der Gegner hat keine Karte zum Stehlen.');
    return;
  }

  // stealRandomResource gibt dem aktiven Spieler die Karte bereits
  print('Es wurde ${stolen.name} gestohlen.');
}

/// Ablauf, wenn ein Spieler eine Monopolkarte spielt

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

///  Ablauf, wenn ein Spieler eine Ritterkarte spielt
void handlePlayedKnightCardTurn(GameController gc) {
  if (!gc.getActivePlayer().developmentCards.contains((
    DevelopmentCardType.knight,
    true,
  )))
    return;

  final target = pickRobberTarget(gc);
  if (target == null) return;
  final victim = pickVictimFromConsole(gc, target);
  gc.playAKnightCard(gc.getActivePlayer(), target, victim);
}

/// Ablauf, wenn ein Spieler eine Straßen Entwicklungskarte spielt
void handleRoadDevelopmentCard(GameController gc) {
  if (!gc.getActivePlayer().developmentCards.contains((
    DevelopmentCardType.roadBuilding,
    true,
  )))
    return;

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
        'Da du noch eine Straße bauen kannst:'
        'Auf welcher Kante möchtest Du deine zweite Straße bauen?'
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

/// Ablauf, wenn ein Spieler eine Year of Plenty (2 Ressourcen)
/// Entwicklungskarte spielt
void handleYearOfPlentyCardTurn(GameController gc) {

  if (!gc.getActivePlayer().developmentCards.contains((DevelopmentCardType.yearOfPlenty, true, ))) {return;}

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
        '(Bank: ${gc.bank.getAmount(resourceTypes[i])})',
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

    if (gc.bank.getAmount(resource) <= alreadySelected) {
      print('Dieser Rohstoff ist nicht ausreichend in der Bank vorhanden.');
      continue;
    }

    selectedResources.add(resource);
  }

  gc.playYearOfPlentyCard(selectedResources[0], selectedResources[1]);
}

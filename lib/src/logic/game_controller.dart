import 'package:game_of_hexia/src/logic/dice.dart';
import 'package:game_of_hexia/src/models/hexagon_board.dart';
import 'package:game_of_hexia/src/models/building_type.dart';
import 'package:game_of_hexia/src/models/hexagon.dart';
import 'package:game_of_hexia/src/models/node.dart';
import 'package:game_of_hexia/src/models/edge.dart';
import 'package:game_of_hexia/src/models/player.dart';
import 'package:game_of_hexia/src/models/resource_type.dart';

/// Coordinates game actions between the board, dice and players.
class GameController {
  final HexagonBoard gameBoard;
  final Dices dice;
  final List<Player> players;
  int activePlayerIndex = 0;

  GameController({
    required this.gameBoard,
    required this.dice,
    required this.players,
  });

  /// Rolls once and distributes resources for the resulting total.
  int rollDice() {
    int dice1 = 0;
    int dice2 = 0;
    (int, int) result = dice.rollDices();
    dice1 = result.$1;
    dice2 = result.$2;
    final total = dice1 + dice2;

    // Bei einer 7 wird hier nichts verteilt. Die Verteilung der 7-Felder
    // übernimmt handleRobberTurn in test_game (gerade noch), wo
    // die Räuber Mechanik zusammengefasst ist
    if (total == 7) {
      return total;
    }
    distributeResources(total);
    return total;
  }

  /// Steals one card of the resources from [victim] and gives it to the
  /// active player. Returns the stolen resource, or null if the victim has
  /// no cards left.
  ResourceType? stealRandomResource(Player victim) {
    final keys = victim.getResourceCards().keys.toList()..shuffle();

    if (keys.isEmpty) return null;

    final stolen = keys.first;
    if (!victim.removeResource(stolen)) return null;

    getActivePlayer().addResource(resource: stolen);
    return stolen;
  }

  /// Gibt alle Gegner zurück, deren Siedlung oder Stadt an das Hexagon
  /// [target] angrenzt. Der aktive Spieler selbst sowie Spieler ohne
  /// Gebäude an diesem Feld werden nicht zurückgegeben.
  List<Player> getPossibleVictimsForRobber(Hexagon target) {
    final activePlayer = getActivePlayer();
    final victimColors = <PlayerColor>{};

    for (final corner in target.corners) {
      final node = gameBoard.getNode(corner.x, corner.y);
      if (node == null || node.building == null) continue;

      final owner = node.owner;
      if (owner == null || owner == activePlayer.color) continue;

      victimColors.add(owner);
    }

    return players
        .where((player) => victimColors.contains(player.color))
        .toList();
  }

  /// Returns whether the active player has a settlement or city next to
  /// [target]. The robber must not be placed on the active players own field.
  bool isRobberBlockedForActivePlayer(Hexagon target) {
    final activeColor = getActivePlayer().color;

    for (final corner in target.corners) {
      final node = gameBoard.getNode(corner.x, corner.y);
      if (node == null || node.building == null) continue;

      if (node.owner == activeColor) return true;
    }

    return false;
  }

  /// calculates the number of cards a player has to give away when the robber gets
  /// rolled
  int calculateCardsToThrowAway(Player p) {
    int sum = p.stone + p.cattle + p.fishes + p.iron + p.woods;
    return sum > 7 ? sum ~/ 2 : 0;
  }

  /// Räuber umplatzieren
  bool moveRobber(Hexagon target) {
    /// Räuber MUSS Position ändern
    final robber = gameBoard.robber;
    if (robber == null) return false;
    if (target == robber.currentPosition) return false;
    robber.currentPosition = target;
    return true;
  }

  /// zieht die Ressourcen vom Spieler ab, die er ausgwählt hatte.
  /// sollte er zu wenig besitzen, wird false zurück gegeben
  bool discardResourcesForRobber(
    Player player,
    Map<ResourceType, int> selectedResources,
  ) {
    if (selectedResources.containsKey(ResourceType.empty) ||
        selectedResources.values.any((amount) => amount < 0)) {
      return false;
    }

    final selectedCount = selectedResources.values.fold(
      0,
      (sum, amount) => sum + amount,
    );

    if (calculateCardsToThrowAway(player) != selectedCount) return false;

    final discardWoods = selectedResources[ResourceType.wood] ?? 0;
    final discardFishes = selectedResources[ResourceType.fish] ?? 0;
    final discardCattle = selectedResources[ResourceType.cattle] ?? 0;
    final discardStone = selectedResources[ResourceType.stone] ?? 0;
    final discardIron = selectedResources[ResourceType.iron] ?? 0;

    if (player.woods < discardWoods ||
        player.fishes < discardFishes ||
        player.cattle < discardCattle ||
        player.stone < discardStone ||
        player.iron < discardIron) {
      return false;
    }

    player.woods -= discardWoods;
    player.fishes -= discardFishes;
    player.iron -= discardIron;
    player.stone -= discardStone;
    player.cattle -= discardCattle;

    return true;
  }

  /// Returns all resource fields that produce for [diceValue].
  List<Hexagon> getRolledHexagons(int diceValue) {
    return gameBoard.getHexagonWithRolledNumber(diceValue);
  }

  /// Gives each settlement or city next to a producing field its resource.
  void distributeResources(int diceValue) {
    List<Hexagon> rolledHexagons = getRolledHexagons(diceValue);
    // Für jedes Hexagon prüfen, ob eine der Ecken ein Node ist, der im
    // Besitz eines Spielers ist
    for (final hex in rolledHexagons) {
      // Felder mit Räuber liefern keine Ressourcen
      if (gameBoard.robber?.currentPosition == hex) continue;

      List<Point2D> hexCorners = hex.corners;

      for (final corner in hexCorners) {
        final node = gameBoard.getNode(corner.x, corner.y);

        if (node != null) {
          final PlayerColor? owner = node.owner;
          final BuildingType? building = node.building;

          if (owner != null && building != null) {
            for (final p in players) {
              if (p.color == owner) {
                p.addResource(
                  resource: hex.type,
                  amount: 1,
                  building: building,
                );
              }
            }
          }
        }
      }
    }
  }

  /// Returns the player whose turn is currently active.
  Player getActivePlayer() {
    return players[activePlayerIndex];
  }

  // setzt aktiven Spieler für die nächste Runde, wird später bei
  // am Ende jeder Runde aufgerufen
  void endTurn() {
    activePlayerIndex = (activePlayerIndex + 1) % players.length;
  }

  // setzt/baut eine Siedlung auf einen node. Falls erfolgreich: true, sonst false
  bool placeSettlement(Node node) {
    // Abstände zur nächsten Siedlung/Stadt prüfen, usw.
    if (possibleToPlaceSettlement(node) == false) return false;

    final activePlayer = getActivePlayer();

    if (activePlayer.remainingSettlements <= 0) return false;

    if (!tryPayForSettlement(activePlayer)) {
      // print('Not enough resources to build a settlement.');
      return false;
    }

    node.owner = activePlayer.color;
    node.building = BuildingType.settlement;
    activePlayer.remainingSettlements--;
    return true;
  }

  // baut eine Stadt auf einen Knoten, auf dem schon eine Siedlung des sleben
  // Spielers gesetzt sein muss
  bool upgradeSettlementToCity(Node node) {
    if (!possibleToPlaceCity(node)) return false;

    final activePlayer = getActivePlayer();

    if (activePlayer.remainingCities <= 0) return false;
    if (!tryPayForCity(activePlayer)) return false;

    node.building = BuildingType.city;
    activePlayer.remainingCities--;
    activePlayer.remainingSettlements++;
    return true;
  }

  // Baut eine Straße auf einer freien, mit dem Spieler verbundenen Kante.
  // Falls erfolgreich: true, sonst false.
  bool placeRoad(Edge edge) {
    // Kante und Verbindung zum eigenen Straßennetz oder Gebäude prüfen.
    if (!possibleToPlaceRoad(edge)) return false;

    final activePlayer = getActivePlayer();

    // Verfügbare Straßen und Ressourcen prüfen.
    if (activePlayer.remainingRoads <= 0) return false;
    if (!tryPayForRoad(activePlayer)) return false;

    // Straße platzieren und den Vorrat des Spielers reduzieren.
    edge.roadOwner = activePlayer.color;
    activePlayer.remainingRoads--;
    return true;
  }

  // Prüft Abstandsregeln zum Siedlung/Stadt bauen:
  // beide dürfen nicht direkt neben einer anderen gebauet werden
  bool possibleToPlaceSettlement(Node n) {
    if (n.owner != null || n.building != null) {
      return false;
    }

    Set<Node> adjacentNodes = gameBoard.getAdjacentNodesToNode(n);
    for (final node in adjacentNodes) {
      if (node.owner != null || node.building != null) return false;
    }
    return true;
  }

  // Prüft, ob ein Knoten geeignet dafür ist, eine Stadt zu bauen
  // Prüfung ist nur ein Teil, Ressourcen und Straßen werden in
  // anderen Methoden geprüft
  bool possibleToPlaceCity(Node n) {
    Player activePlayer = getActivePlayer();
    Set<Node> adjacentNodes = gameBoard.getAdjacentNodesToNode(n);
    for (final node in adjacentNodes) {
      if (node.owner != null || node.building != null) return false;
    }
    return n.owner == activePlayer.color &&
        n.building == BuildingType.settlement;
  }

  // Prüft, ob es möglich ist, eine Straße zwischen zwei Knoten zu bauen
  bool possibleToPlaceRoad(Edge edge) {
    final activePlayer = getActivePlayer();

    if (!gameBoard.allEdges.contains(edge) || edge.roadOwner != null) {
      return false;
    }

    for (final node in [edge.n, edge.m]) {
      final hasOpponentBuilding =
          node.building != null && node.owner != activePlayer.color;
      if (hasOpponentBuilding) continue;

      final hasOwnBuilding =
          node.building != null && node.owner == activePlayer.color;
      if (hasOwnBuilding) return true;

      final connectsToOwnRoad = gameBoard.allEdges.any(
        (otherEdge) =>
            otherEdge.roadOwner == activePlayer.color &&
            (otherEdge.n == node || otherEdge.m == node),
      );
      if (connectsToOwnRoad) return true;
    }

    return false;
  }

  // Ressourcen abziehen, wenn Spieler Siedlung baut
  bool tryPayForSettlement(Player activePlayer) {
    if (activePlayer.woods >= 1 &&
        activePlayer.stone >= 1 &&
        activePlayer.fishes >= 1 &&
        activePlayer.cattle >= 1) {
      activePlayer.woods -= 1;
      activePlayer.fishes -= 1;
      activePlayer.cattle -= 1;
      activePlayer.stone -= 1;
      return true;
    }
    return false;
  }

  // Ressourcen abziehen, wenn Spieler eine Stadt baut
  bool tryPayForCity(Player activePlayer) {
    if (activePlayer.iron >= 3 && activePlayer.fishes >= 2) {
      activePlayer.iron -= 3;
      activePlayer.fishes -= 2;
      return true;
    }
    return false;
  }

  // Ressourcen abziehen, wenn Spieler eine Straße baut
  bool tryPayForRoad(Player activePlayer) {
    if (activePlayer.woods >= 1 && activePlayer.stone >= 1) {
      activePlayer.woods -= 1;
      activePlayer.stone -= 1;
      return true;
    }
    return false;
  }
}

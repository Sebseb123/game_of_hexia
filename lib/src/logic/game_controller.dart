import 'package:game_of_hexia/src/logic/dice.dart';
import 'package:game_of_hexia/src/models/building_type.dart';
import 'package:game_of_hexia/src/models/development_card_type.dart';
import 'package:game_of_hexia/src/models/edge.dart';
import 'package:game_of_hexia/src/models/game_state.dart';
import 'package:game_of_hexia/src/models/hexagon.dart';
import 'package:game_of_hexia/src/models/node.dart';
import 'package:game_of_hexia/src/models/player.dart';
import 'package:game_of_hexia/src/models/resource_type.dart';

/// Applies game rules to the mutable data stored in [state].
class GameController {
  final GameState state;
  final Dices dice;

  GameController({required this.state, required this.dice});

  /// Rolls both dice and distributes resources unless the total is seven.
  ///
  /// A total of seven is returned for the caller to handle the robber turn.
  int rollDice() {
    int dice1 = 0;
    int dice2 = 0;
    (int, int) result = dice.rollDices();
    dice1 = result.$1;
    dice2 = result.$2;
    final total = dice1 + dice2;

    if (total == 7) {
      return total;
    }
    distributeResources(total);
    return total;
  }

  /// Charges [player] and draws the top card when the purchase is valid.
  ///
  /// A newly purchased card is initially marked as unplayable.
  bool developmentCardPurchase(Player player) {
    if (player != getActivePlayer()) return false;
    if (!player.canBuyDevelopmentCard()) return false;
    if (state.developmentCardDeck.cardDeck.isEmpty) return false;

    player.iron--;
    player.fish--;
    player.cattle--;

    final card = state.developmentCardDeck.cardDeck.removeLast();

    player.developmentCards.add((card, false));

    if (card == DevelopmentCardType.victoryPoint) player.hiddenWinPoints++;

    return true;
  }

  /// Places one free road while the active player has a Road Building card.
  ///
  /// The card remains available so the caller can place its second road.
  bool playRoadDevelopmentCard(Edge edge) {
    Player activePlayer = getActivePlayer();
    if (!getActivePlayer().developmentCards.contains((
      DevelopmentCardType.roadBuilding,
      true,
    ))) {
      return false;
    }
    if (activePlayer.remainingRoads <= 0) return false;
    if (!possibleToPlaceRoad(edge)) return false;
    activePlayer.remainingRoads--;
    edge.roadOwner = activePlayer.color;

    return true;
  }

  /// Transfers up to [amount] cards of [resource] from the bank to the active
  /// player and returns the number actually transferred.
  int getResourceFromBank(ResourceType resource, {int amount = 1}) {
    if (resource == ResourceType.empty) return 0;
    if (amount <= 0) return 0;

    final activePlayer = getActivePlayer();
    int resourceAmount = state.bank.getResource(resource, amount: amount);

    activePlayer.addResource(resource: resource, amount: resourceAmount);

    return resourceAmount;
  }

  /// Plays Year of Plenty with the two selected resources.
  bool playYearOfPlentyCard(ResourceType card1, ResourceType card2) {
    if (!getActivePlayer().developmentCards.contains((
      DevelopmentCardType.yearOfPlenty,
      true,
    ))) {
      return false;
    }
    if (card1 == ResourceType.empty || card2 == ResourceType.empty) {
      return false;
    }

    if (card1 == card2) {
      if (state.bank.getAmount(card1) < 2) return false;
    } else {
      if (state.bank.getAmount(card1) < 1 || state.bank.getAmount(card2) < 1) {
        return false;
      }
    }

    getResourceFromBank(card1);
    getResourceFromBank(card2);

    getActivePlayer().developmentCards.remove((
      DevelopmentCardType.yearOfPlenty,
      true,
    ));

    return true;
  }

  /// Transfers the selected resource from every opponent to the active player.
  bool playMonopolyCard(ResourceType stealingType) {
    if (!getActivePlayer().developmentCards.contains((
      DevelopmentCardType.monopoly,
      true,
    ))) {
      return false;
    }
    if (stealingType == ResourceType.empty) return false;

    getActivePlayer().developmentCards.remove((
      DevelopmentCardType.monopoly,
      true,
    ));

    int sum = 0;

    for (final player in state.players) {
      if (player == getActivePlayer()) continue;
      int playerAmount = player.getResourceCards()[stealingType] ?? 0;
      sum += playerAmount;
      for (playerAmount; playerAmount > 0; playerAmount--) {
        player.removeResource(stealingType);
      }
    }

    getActivePlayer().addResource(resource: stealingType, amount: sum);

    return true;
  }

  /// Plays a Knight card, moves the robber, and optionally steals from [victim].
  ///
  /// The caller must validate [victim] and update Largest Army separately.
  bool playAKnightCard(Player player, Hexagon target, Player? victim) {
    if (player != getActivePlayer()) return false;
    if (!player.developmentCards.contains((DevelopmentCardType.knight, true))) {
      return false;
    }
    if (!moveRobber(target)) return false;

    if (victim != null) stealRandomResource(victim);

    player.playedKnights++;
    player.developmentCards.remove((DevelopmentCardType.knight, true));
    return true;
  }

  /// Awards Largest Army to the player with the most played Knights.
  ///
  /// At least three Knights are required. Initial ties favor player order;
  /// later ties do not transfer ownership.
  void updateLargestArmyOwner() {
    Player? strongestArmyOwner;

    for (final player in state.players) {
      if (player.playedKnights >= 3 &&
          (strongestArmyOwner == null ||
              player.playedKnights > strongestArmyOwner.playedKnights)) {
        strongestArmyOwner = player;
      }
    }
    if (strongestArmyOwner == null) return;
    if (state.largestArmyOwner == null) {
      state.largestArmyOwner = strongestArmyOwner;
      strongestArmyOwner.winPoints += 2;
      return;
    }

    if (strongestArmyOwner.playedKnights >
        state.largestArmyOwner!.playedKnights) {
      state.largestArmyOwner!.winPoints -= 2;
      state.largestArmyOwner = strongestArmyOwner;
      strongestArmyOwner.winPoints += 2;
      return;
    }
  }

  /// Steals one random resource from [victim] and gives it to the active
  /// player. Returns null if the victim has no cards.
  ResourceType? stealRandomResource(Player victim) {
    final resourceCards = <ResourceType>[];

    for (final entry in victim.getResourceCards().entries) {
      for (var i = 0; i < entry.value; i++) {
        resourceCards.add(entry.key);
      }
    }

    if (resourceCards.isEmpty) return null;
    resourceCards.shuffle();
    final stolen = resourceCards.first;

    if (!victim.removeResource(stolen)) return null;

    getActivePlayer().addResource(resource: stolen);
    return stolen;
  }

  /// Returns opponents with a settlement or city adjacent to [target].
  List<Player> getPossibleVictimsForRobber(Hexagon target) {
    final activePlayer = getActivePlayer();
    final victimColors = <PlayerColor>{};

    for (final corner in target.corners) {
      final node = state.gameBoard.getNode(corner.x, corner.y);
      if (node == null || node.building == null) continue;

      final owner = node.owner;
      if (owner == null || owner == activePlayer.color) continue;

      victimColors.add(owner);
    }

    return state.players
        .where((player) => victimColors.contains(player.color))
        .toList();
  }

  /// Returns how many cards [p] must discard after a seven is rolled.
  int calculateCardsToThrowAway(Player p) {
    int sum = p.stone + p.cattle + p.fish + p.iron + p.wood;
    return sum > 7 ? sum ~/ 2 : 0;
  }

  /// Moves the robber to [target].
  ///
  /// Returns false if no robber exists or [target] is its current position.
  /// Board membership is not validated.
  bool moveRobber(Hexagon target) {
    final robber = state.gameBoard.robber;
    if (robber == null) return false;
    if (target == robber.currentPosition) return false;
    robber.currentPosition = target;
    return true;
  }

  /// Removes the required resources from [player] when the selection is valid.
  ///
  /// Removed cards are not returned to the bank.
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

    if (player.wood < discardWoods ||
        player.fish < discardFishes ||
        player.cattle < discardCattle ||
        player.stone < discardStone ||
        player.iron < discardIron) {
      return false;
    }

    player.wood -= discardWoods;
    player.fish -= discardFishes;
    player.iron -= discardIron;
    player.stone -= discardStone;
    player.cattle -= discardCattle;

    return true;
  }

  /// Returns all resource fields that produce for [diceValue].
  List<Hexagon> getRolledHexagons(int diceValue) {
    return state.gameBoard.getHexagonWithRolledNumber(diceValue);
  }

  /// Gives each settlement or city next to a producing field its resource.
  ///
  /// Resources are currently added without reducing the bank stock.
  void distributeResources(int diceValue) {
    List<Hexagon> rolledHexagons = getRolledHexagons(diceValue);
    for (final hex in rolledHexagons) {
      // A field occupied by the robber does not produce resources.
      if (state.gameBoard.robber?.currentPosition == hex) continue;

      List<Point2D> hexCorners = hex.corners;

      for (final corner in hexCorners) {
        final node = state.gameBoard.getNode(corner.x, corner.y);

        if (node != null) {
          final PlayerColor? owner = node.owner;
          final BuildingType? building = node.building;

          if (owner != null && building != null) {
            for (final p in state.players) {
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
    return state.activePlayer;
  }

  /// Advances the turn to the next player.
  void endTurn() {
    state.activePlayerIndex =
        (state.activePlayerIndex + 1) % state.players.length;
  }

  /// Builds and pays for a settlement on [node].
  bool placeSettlement(Node node) {
    if (possibleToPlaceSettlement(node) == false) return false;

    final activePlayer = getActivePlayer();

    if (activePlayer.remainingSettlements <= 0) return false;

    if (!tryPayForSettlement(activePlayer)) {
      return false;
    }

    node.owner = activePlayer.color;
    node.building = BuildingType.settlement;
    activePlayer.remainingSettlements--;
    return true;
  }

  /// Upgrades an owned settlement on [node] to a city.
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

  /// Builds and pays for a road on [edge].
  bool placeRoad(Edge edge) {
    if (!possibleToPlaceRoad(edge)) return false;

    final activePlayer = getActivePlayer();

    if (activePlayer.remainingRoads <= 0) return false;
    if (!tryPayForRoad(activePlayer)) return false;

    edge.roadOwner = activePlayer.color;
    activePlayer.remainingRoads--;
    return true;
  }

  /// Checks that [n] is empty and has no adjacent building.
  bool possibleToPlaceSettlement(Node n) {
    if (n.owner != null || n.building != null) {
      return false;
    }

    Set<Node> adjacentNodes = state.gameBoard.getAdjacentNodesToNode(n);
    for (final node in adjacentNodes) {
      if (node.owner != null || node.building != null) return false;
    }
    return true;
  }

  /// Checks that [n] is the active player's settlement and that all adjacent
  /// nodes are empty.
  bool possibleToPlaceCity(Node n) {
    Player activePlayer = getActivePlayer();
    Set<Node> adjacentNodes = state.gameBoard.getAdjacentNodesToNode(n);
    for (final node in adjacentNodes) {
      if (node.owner != null || node.building != null) return false;
    }
    return n.owner == activePlayer.color &&
        n.building == BuildingType.settlement;
  }

  /// Returns all edges on which the active player can currently build a road.
  List<Edge> getPossibleEdgesToPlaceRoad() {
    List<Edge> possibleEdges = [];

    for (final edge in state.gameBoard.allEdges) {
      if (possibleToPlaceRoad(edge)) {
        possibleEdges.add(edge);
      }
    }
    return possibleEdges;
  }

  /// Checks whether [edge] is free and connected to the active player.
  bool possibleToPlaceRoad(Edge edge) {
    final activePlayer = getActivePlayer();

    if (!state.gameBoard.allEdges.contains(edge) || edge.roadOwner != null) {
      return false;
    }

    for (final node in [edge.n, edge.m]) {
      final hasOpponentBuilding =
          node.building != null && node.owner != activePlayer.color;
      if (hasOpponentBuilding) continue;

      final hasOwnBuilding =
          node.building != null && node.owner == activePlayer.color;
      if (hasOwnBuilding) return true;

      final connectsToOwnRoad = state.gameBoard.allEdges.any(
        (otherEdge) =>
            otherEdge.roadOwner == activePlayer.color &&
            (otherEdge.n == node || otherEdge.m == node),
      );
      if (connectsToOwnRoad) return true;
    }

    return false;
  }

  /// Deducts the settlement cost if [activePlayer] can afford it.
  bool tryPayForSettlement(Player activePlayer) {
    if (activePlayer.wood >= 1 &&
        activePlayer.stone >= 1 &&
        activePlayer.fish >= 1 &&
        activePlayer.cattle >= 1) {
      activePlayer.wood -= 1;
      activePlayer.fish -= 1;
      activePlayer.cattle -= 1;
      activePlayer.stone -= 1;
      return true;
    }
    return false;
  }

  /// Deducts the city cost if [activePlayer] can afford it.
  bool tryPayForCity(Player activePlayer) {
    if (activePlayer.iron >= 3 && activePlayer.fish >= 2) {
      activePlayer.iron -= 3;
      activePlayer.fish -= 2;
      return true;
    }
    return false;
  }

  /// Deducts the road cost if [activePlayer] can afford it.
  bool tryPayForRoad(Player activePlayer) {
    if (activePlayer.wood >= 1 && activePlayer.stone >= 1) {
      activePlayer.wood -= 1;
      activePlayer.stone -= 1;
      return true;
    }
    return false;
  }
}

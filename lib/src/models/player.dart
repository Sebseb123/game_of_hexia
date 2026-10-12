import 'package:game_of_hexia/src/models/building_type.dart';
import 'package:game_of_hexia/src/models/development_card_type.dart';
import 'package:game_of_hexia/src/models/resource_type.dart';

enum PlayerColor { blue, red, yellow, green, black, white }

/// Stores a player's identity, cards, score, resources, and remaining pieces.
class Player {
  final PlayerColor color;
  final String name;

  /// Development cards paired with whether they are currently playable.
  final List<(DevelopmentCardType, bool)> developmentCards = [];

  int playedKnights = 0;

  int winPoints = 0;
  int hiddenWinPoints = 0;
  int totalWinPoints = 0;

  int remainingSettlements = 5;
  int remainingCities = 4;
  int remainingRoads = 15;

  int wood = 0;
  int fish = 0;
  int iron = 0;
  int stone = 0;
  int cattle = 0;

  Player({required this.color, required this.name});

  /// Adds [amount] of [resource], doubled for a city.
  ///
  /// [ResourceType.empty] is ignored.
  void addResource({
    required ResourceType resource,
    int amount = 1,
    BuildingType? building,
  }) {
    final factor = building == BuildingType.city ? 2 : 1;

    switch (resource) {
      case ResourceType.wood:
        wood += amount * factor;
      case ResourceType.fish:
        fish += amount * factor;
      case ResourceType.iron:
        iron += amount * factor;
      case ResourceType.stone:
        stone += amount * factor;
      case ResourceType.cattle:
        cattle += amount * factor;
      case ResourceType.empty:
        return;
    }
  }

  /// Returns the positive resource counts in the player's hand.
  Map<ResourceType, int> getResourceCards() {
    Map<ResourceType, int> resourceCards = {};
    if (wood > 0) {
      resourceCards[ResourceType.wood] = wood;
    }
    if (fish > 0) {
      resourceCards[ResourceType.fish] = fish;
    }
    if (iron > 0) {
      resourceCards[ResourceType.iron] = iron;
    }
    if (stone > 0) {
      resourceCards[ResourceType.stone] = stone;
    }
    if (cattle > 0) {
      resourceCards[ResourceType.cattle] = cattle;
    }
    return resourceCards;
  }

  /// Removes one [resource] card, returning false if none is available.
  bool removeResource(ResourceType resource) {
    switch (resource) {
      case ResourceType.wood:
        if (wood == 0) return false;
        wood--;
      case ResourceType.fish:
        if (fish == 0) return false;
        fish--;
      case ResourceType.iron:
        if (iron == 0) return false;
        iron--;
      case ResourceType.stone:
        if (stone == 0) return false;
        stone--;
      case ResourceType.cattle:
        if (cattle == 0) return false;
        cattle--;
      case ResourceType.empty:
        return false;
    }
    return true;
  }

  /// Whether the player can afford a development card.
  bool canBuyDevelopmentCard() {
    if (cattle > 0 && fish > 0 && iron > 0) return true;
    return false;
  }
}

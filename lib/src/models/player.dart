import 'package:game_of_hexia/src/models/building_type.dart';
import 'package:game_of_hexia/src/models/development_card_type.dart';
import 'package:game_of_hexia/src/models/resource_type.dart';

enum PlayerColor { blue, red, yellow, green, black, white }

/// Stores a player's identity and collected resources.
class Player {
  final PlayerColor color;
  final String name;
  final List<(DevelopmentCardType, bool)> developmentCards = [];


  // Rittermacht
  int playedKnights = 0;

  // winPoints
  int winPoints = 0;
  int hiddenWinPoints = 0;
  int totalWinPoints = 0;

  // buildings
  int remainingSettlements = 5;
  int remainingCities = 4;
  int remainingRoads = 15;

  // resources
  int wood = 0;
  int fish = 0;
  int iron = 0;
  int stone = 0;
  int cattle = 0;

  Player({required this.color, required this.name});

  /// Adds resources and doubles the amount when the building is a city.
  /// Ohne [building] wird genau die Menge hinzugefügt, zum Beispiel beim
  /// Stehlen einer Karte.
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

  /// Returns the amount of each resource card in the players hand.
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

  /// Removes a given resource
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


  /// kleine Prüfmethode, ob eine Entwicklungskarte gekauft werden kann
   bool canBuyDevelopmentCard() {
        if(cattle > 0 && fish > 0 && iron > 0) return true;
        return false;
   }



}

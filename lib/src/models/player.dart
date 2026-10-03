import 'package:game_of_hexia/src/models/building_type.dart';
import 'package:game_of_hexia/src/models/resource_type.dart';

enum PlayerColor { blue, red, yellow, green, black, white }

/// Stores a player's identity and collected resources.
class Player {

  final PlayerColor color;
  final String name;

  // buildings
  int remainingSettlements = 5;
  int remainingCities = 4;
  int remainingRoads = 15;

  // resources
  int woods = 0;
  int fishes = 0;
  int iron = 0;
  int stone = 0;
  int cattle = 0;

  Player({required this.color, required this.name});

  /// Adds resources and doubles the amount when the building is a city.
  void addResource({required ResourceType resource, required int amount,
    required BuildingType building}) {

    final factor = building == BuildingType.settlement ? 1 : 2;

    switch (resource) {
      case ResourceType.wood:
        woods += amount * factor;
      case ResourceType.fish:
        fishes += amount * factor;
      case ResourceType.iron:
        iron += amount * factor;
      case ResourceType.stone:
       stone += amount * factor;
      case ResourceType.cattle:
        cattle+= amount * factor;
      case ResourceType.empty:
        return;
    }
  }


}

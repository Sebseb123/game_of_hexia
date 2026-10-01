import 'package:game_of_hexia/src/models/building_type.dart';
import 'package:game_of_hexia/src/models/player.dart';


//Eigentlich spielt sich alles auf den Knoten zwischen den Hexagons ab. Jeder Knoten grenzt an 1-3 Hexagons
//und hat möglicherweise einen Besitzer (Stadt)
//Die Koordinaten könnten sich wie auf https://www.redblobgames.com/grids/hexagons/#basics darstellen lassen
//Also für das erste Hexagon (2,0) <-- das ist center
// gäbe es die Knoten mit Positionen:
//            (2, -0.5)
//
//(1.75, -0.25)         (2.25, -0.25)
//
//(1.75, 0.25)          (2.25, 0.25)
//
//            (2, 0.5)
// A node can be owned by a player and a building (settlement or city) can be placed on a node
class Node {
  Node({required this.x, required this.y});
  final double x;
  final double y;
  PlayerColor? owner;
  BuildingType? building;


  // Vergleichsoperator damit bei @initNodes() nicht die gleichen Nodes in das Set kommen
  // Set sind diese Methoden bekannt und nutzt sie automatisch
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Node && other.x == x && other.y == y;
  }

  //Siehe Methode "bool operator"
  @override
  int get hashCode => Object.hash(x, y);
}

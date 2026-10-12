import 'package:game_of_hexia/src/models/building_type.dart';
import 'package:game_of_hexia/src/models/player.dart';

/// A Cartesian board vertex shared by up to three hexagons.
///
/// Nodes are equal when their coordinates match.
class Node {
  final double x;
  final double y;
  PlayerColor? owner;
  BuildingType? building;

  Node({required this.x, required this.y});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Node && other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);
}

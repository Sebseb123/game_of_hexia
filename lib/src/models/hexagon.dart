import 'package:game_of_hexia/src/models/resource_type.dart';

/// A two-dimensional Cartesian point.
typedef Point2D = ({double x, double y});

/// A board tile identified by axial coordinates and positioned in Cartesian
/// space.
class Hexagon {
  /// Creates a tile at axial coordinate ([x], [y]) and derives its center.
  Hexagon({required this.type, required int x, required int y})
    : axial = (x: x, y: y),
      center = (x: x + (y.isEven ? 0.0 : 0.5), y: 0.5 + y * 0.75);

  final ({int x, int y}) axial;
  ResourceType type;

  /// The dice total that produces this tile, or zero when none is assigned.
  int numberDisc = 0;

  /// The Cartesian center derived from [axial].
  final Point2D center;

  ({double x, double y}) get top => (x: center.x + 0.0, y: center.y - 0.5);
  ({double x, double y}) get topRight =>
      (x: center.x + 0.5, y: center.y - 0.25);
  ({double x, double y}) get bottomRight =>
      (x: center.x + 0.5, y: center.y + 0.25);
  ({double x, double y}) get bottom => (x: center.x + 0.0, y: center.y + 0.5);
  ({double x, double y}) get bottomLeft =>
      (x: center.x - 0.5, y: center.y + 0.25);
  ({double x, double y}) get topLeft => (x: center.x - 0.5, y: center.y - 0.25);

  /// The six corners in clockwise order, starting at [top].
  List<Point2D> get corners => [
    top,
    topRight,
    bottomRight,
    bottom,
    bottomLeft,
    topLeft,
  ];

  /// Converts Cartesian tile-center coordinates to axial coordinates.
  static ({int x, int y}) cartesianToAxial(double x, double y) {
    int axialY = ((y - 0.5) * 4 / 3).toInt();
    int axialX = (axialY.isEven ? x : x - 0.5).toInt();
    return (x: axialX, y: axialY);
  }

  @override
  String toString() {
    return type.name;
  }
}

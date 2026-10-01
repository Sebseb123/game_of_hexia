import 'package:game_of_hexia/src/models/resource_type.dart';



///Record to hold a 2D Point in cartesian
typedef Point2D = ({double x, double y});

//The game tile
class Hexagon {
  //Hier wird x und y als Axial-Punkt übergeben. Center ist aber eine karthesische Koordiante
  //deswegen wird umgerechnet
  Hexagon({required this.type, required int x, required int y})
      : axial = (x: x, y: y),
        center = (
        x: x + (y.isEven ? 0.0 : 0.5), // x-Offset: Die Hexagons zweier Reihen sind immer um genau 0.5 verschoben
        y: 0.5 + y * 0.75, //y- Offsett: Hexagon center an der y-Achse ist wie folgt: 0.5, 1.25, 2.0, 2.75, 3.5
        );

  final ({int x, int y}) axial;
  ResourceType type;
  int numberDisc = 0; //jedes Hexagon hat ja einen Wert fürs Würfeln zum Ressourcen vergeben
  final Point2D center; //cartesian coordinates

  //Das sind die jeweiligen Ecken des Hexagons mit den entsprechenden Koords
  ({double x, double y}) get top => (x: center.x + 0.0, y: center.y - 0.5);
  ({double x, double y}) get topRight => (x: center.x + 0.5, y: center.y - 0.25);
  ({double x, double y}) get bottomRight => (x: center.x + 0.5, y: center.y + 0.25);
  ({double x, double y}) get bottom => (x: center.x + 0.0, y: center.y + 0.5);
  ({double x, double y}) get bottomLeft => (x: center.x - 0.5, y: center.y + 0.25);
  ({double x, double y}) get topLeft => (x: center.x - 0.5, y: center.y - 0.25);

  // Gibt eine Liste mit allen Ecken des Hexagons zurück
  List<Point2D> get corners => [
    top,
    topRight,
    bottomRight,
    bottom,
    bottomLeft,
    topLeft,
  ];

  //Diese Funktion wandelt dann die karthesischen Koordinaten zurück in Axial-Koords
  //Damit kann man das Hexagon wieder eindeutig im HexagonBoard finden
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
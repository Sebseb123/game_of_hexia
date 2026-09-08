///Das HexagonBoard besteht aus Hexagons. Hexagons sind einmal über einen Index adressierbar (der key in _grid), 
///besitzen aber auch eine Koordinate (center). Jedes Hexagon hat 6 Ecken, die wiederum auch über eine Koordinate verfügen
class HexagonBoard {
  final Map<({int x, int y}), Hexagon> _grid = {};

  //Each tile/hexagon has 6 different directions/borders
  final tileDirections = [
       (0,-1),   (1, -1),
    (-1, 0),/* Hexa */ (1, 0),
       (-1, 1),   (0, 1)];

    /// Creates an empty game board. Could be generalized to create any sized hexagon board
    /// Check out: ///Check out https://www.redblobgames.com/grids/hexagons/#map-storage
    /// Remember This Board is one size smaller as on the website
  HexagonBoard() {
    //startX as starting point in the hexagon grid. the first row is (2,0), (3,0), (4,0)
    int startX = 2;
    for(int y = 0; y < 3; y++) {
      for(int x = startX; x < 5; x++) {
        _grid[(x: x, y: y)] = Hexagon(type: HexagonType.empty, x: x, y: y);
      }
      startX--;
    }
    //endX as limit in the grid. the last row is (0,6), (1,6), (2,6)
    int endX = 4;
    for(int y = 3; y < 5; y++) {
      for(int x = 0; x < endX; x++) {
        _grid[(x: x, y: y)] = Hexagon(type: HexagonType.empty, x: x, y: y);
      }
      endX--;
    }
  }

  //Use this to place hexagons randomly on board
  void placeHexagons() {
    //Number of different tiles on gameboard. e.g. there are 3 stone tiles
    List<HexagonType> numberHexTypes = [
    HexagonType.stone, HexagonType.stone, HexagonType.stone,
    HexagonType.wood, HexagonType.wood, HexagonType.wood, HexagonType.wood, 
    HexagonType.cattle, HexagonType.cattle, HexagonType.cattle, HexagonType.cattle,
    HexagonType.fish, HexagonType.fish, HexagonType.fish, HexagonType.fish,
    HexagonType.iron, HexagonType.iron, HexagonType.iron,
    HexagonType.empty];
    
    numberHexTypes.shuffle();

    var i = 0;
      _grid.forEach((_, value) {
        value.type = numberHexTypes[i];
        i++;
      });
  }

  //Returns the (x, y) index of a neighbour given the direction
  //Only works with Hexagons and the tileDirections
  ({int x, int y})? getNeighbour(int x, int y, (int, int) direction) {
    return (x: x + direction.$1, y: y + direction.$2);
  }

  //Returns Size of the Map
  int get length => _grid.length;
  Hexagon? getHexagon(int x, int y) {
    return _grid[(x: x, y: y)];
  }

  //Erzeugt für jedes Hexagon die jeweiligen Knoten. Da keine Dubletten in Sets zugelassen sind,
  //erscheinen die gleichen Knotenpunkte nicht doppelt. Könnte man auch mit einer Hashmap realisieren
  Set<Node> initNodes() {
    Set<Node> nodes = {};
    _grid.forEach((_, hexagon) {
      nodes.add(Node(x: hexagon.top.x , y: hexagon.top.y));
      nodes.add(Node(x: hexagon.topRight.x , y: hexagon.topRight.y));
      nodes.add(Node(x: hexagon.bottomRight.x , y: hexagon.bottomRight.y));
      nodes.add(Node(x: hexagon.bottom.x , y: hexagon.bottom.y));
      nodes.add(Node(x: hexagon.bottomLeft.x , y: hexagon.bottomLeft.y));
      nodes.add(Node(x: hexagon.topLeft.x , y: hexagon.topLeft.y));
    });
    return nodes;
  }

  List<HexagonType> getAdjacentHexagonTypes(Node node) {
    List<HexagonType> getAdjacentHexagonTypes = [];

    return getAdjacentHexagonTypes;
  }

  //Using the same Loop as the Constructor, but here it returns a String
  @override
  String toString() {
    final buffer = StringBuffer();
    int startX = 2;
    for(int y = 0; y < 3; y++) {
      for(int x = startX; x < 5; x++) {
        buffer.write('[${_grid[(x: x, y: y)]?.type.name}]');
      }
      startX--;
      buffer.writeln();
    }
    startX = 4;
    for(int y = 3; y < 5; y++) {
      for(int x = 0; x < startX; x++) {
        buffer.write('[${_grid[(x: x, y: y)]?.type.name}]');
      }
      startX--;
      buffer.writeln();
    }
    return buffer.toString().trimRight();
  }
}

enum HexagonType {
  stone(name: "Stone"),
  wood(name: "Wood"),
  cattle(name: "Cattle"),
  fish(name: "Fish"),
  iron(name: "Iron"),
  empty(name: "Empty");

  final String name;
  const HexagonType({required this.name});
}

///Record to hold a 2D Point
typedef Point2D = ({double x, double y});

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
class Node {
  Node({required this.x, required this.y});
  final double x;
  final double y;


  // Vergleichsoperator damit bei @initNodes() nicht die gleichen Nodes in das Set kommen
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Node && other.x == x && other.y == y;
  }
  //Siehe oben
  @override
  int get hashCode => Object.hash(x, y);
}


//The game tile
class Hexagon {
  Hexagon({required this.type, this._numberDisc, required int x, required int y}) 
    :center = (
      x: x + (y.isEven? 0.0 : 0.5),  // x-Offset: Die Hexagons zweier Reihen sind immer um genau 0.5 verschoben
      y: 0.5 + y * 0.75   //y- Offsett: Hexagon center an der y-Achse ist wie folgt: 0.5, 1.25, 2.0, 2.75, 3.5
    );                    

  HexagonType type;
  int? _numberDisc;   //jedes Hexagon hat ja einen Wert fürs Würfeln zum Ressourcen vergeben
  final Point2D center;

  //Das sind die jeweiligen Ecken des Hexagons mit den entsprechenden Koords
  ({double x, double y}) get top => (x: center.x + 0.0, y: center.y - 0.5);
  ({double x, double y}) get topRight => (x: center.x + 0.5, y: center.y - 0.25);
  ({double x, double y}) get bottomRight => (x: center.x + 0.5, y: center.y + 0.25);
  ({double x, double y}) get bottom => (x: center.x + 0.0, y: center.y + 0.5);
  ({double x, double y}) get bottomLeft => (x: center.x - 0.5, y: center.y + 0.25);
  ({double x, double y}) get topLeft => (x: center.x - 0.5, y: center.y - 0.25);

  @override
  String toString() {
    return type.name;
  }
}


//Das sind diese Chips, die auf die Felder gehen. Je nach Würfelergebnis werden dann Rohstoffe ausgeteilt
const List<int> numberDiscs = [2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12];

enum PlayerType {
  blue, red, yellow, green, none;
}

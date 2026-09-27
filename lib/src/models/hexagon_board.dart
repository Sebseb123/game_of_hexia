///Das HexagonBoard besteht aus Hexagons. Hexagons sind einmal über einen Index bzw AxialKoord. adressierbar (der key in _grid),
///besitzen aber auch eine karthesische Koordinate (center). Jedes Hexagon hat 6 Ecken, die wiederum auch über eine karthesische Koordinate verfügen
class HexagonBoard {
  final int radius;
  final Map<({int x, int y}), Hexagon> _grid =
      {}; // Der Schlüssel ist ein Axial Koordinatenpunkt

  //Each tile/hexagon has 6 different directions/borders
  final tileDirections = [
    (0, -1),
    (1, -1),
    (-1, 0),
    /* Hexa */ (1, 0),
    (-1, 1),
    (0, 1),
  ];

  /// Creates an empty hexagonal game board with the given radius.
  HexagonBoard({required this.radius}) {
    // A complete hexagonal board needs at least one ring around its center.
    if (radius < 1) {
      throw ArgumentError.value(radius, 'radius', 'must be at least 1');
    }

    // Create the upper half, including the widest middle row.
    int startX = radius;
    for (int y = 0; y <= radius; y++) {
      for (int x = startX; x < 2 * radius + 1; x++) {
        _grid[(x: x, y: y)] = Hexagon(type: HexagonType.empty, x: x, y: y);
      }
      startX--;
    }
    // Create the lower half, with one fewer field in each row.
    int endX = radius * 2;
    for (int y = radius + 1; y < 2 * radius + 1; y++) {
      for (int x = 0; x < endX; x++) {
        _grid[(x: x, y: y)] = Hexagon(type: HexagonType.empty, x: x, y: y);
      }
      endX--;
    }
  }

  //Use this to place hexagons randomly on board
  void placeHexagons() {
    const resourceTypes = [
      HexagonType.wood,
      HexagonType.cattle,
      HexagonType.fish,
      HexagonType.stone,
      HexagonType.iron,
    ];
    // Standard board ratio: 4 wood, cattle and fish; 3 stone and iron.
    const resourceWeights = [4, 4, 4, 3, 3];
    const totalResourceWeight = 18;
    // Keep roughly one desert for every standard-sized board section.
    final desertCount = (length / 19).round().clamp(1, length).toInt();
    final resourceTileCount = length - desertCount;
    final tileTypes = <HexagonType>[];

    for (var i = 0; i < desertCount; i++) {
      tileTypes.add(HexagonType.empty);
    }

    var assignedResourceTiles = 0;
    for (var i = 0; i < resourceTypes.length; i++) {
      final count =
          resourceTileCount * resourceWeights[i] ~/ totalResourceWeight;
      assignedResourceTiles += count;

      for (var j = 0; j < count; j++) {
        tileTypes.add(resourceTypes[i]);
      }
    }

    // Integer division can leave a few tiles undistributed.
    final remainingResourceTiles = resourceTileCount - assignedResourceTiles;
    for (var i = 0; i < remainingResourceTiles; i++) {
      tileTypes.add(resourceTypes[i % resourceTypes.length]);
    }

    tileTypes.shuffle();

    var index = 0;
    for (final hexagon in _grid.values) {
      hexagon.type = tileTypes[index];
      index++;
    }
  }

  /// Places number discs in a spiral, starting at the outer top-right corner.
  void placeNumberDiscs() {
    const standardDiscs = [
      5,
      2,
      6,
      3,
      8,
      10,
      9,
      12,
      11,
      4,
      8,
      10,
      9,
      4,
      5,
      6,
      3,
      11,
    ];
    const directions = [
      (x: -1, y: 0),
      (x: -1, y: 1),
      (x: 0, y: 1),
      (x: 1, y: 0),
      (x: 1, y: -1),
      (x: 0, y: -1),
    ];

    for (final hexagon in _grid.values) {
      hexagon.numberDisc = 0;
    }

    var discIndex = 0;
    for (var ring = radius; ring > 0; ring--) {
      var current = (x: radius + ring, y: radius - ring);

      for (var side = 0; side < 6; side++) {
        final dir = directions[side];
        for (var step = 0; step < ring; step++) {
          final hexagon = _grid[current];
          if (hexagon != null && hexagon.type != HexagonType.empty) {
            hexagon.numberDisc =
                standardDiscs[discIndex % standardDiscs.length];
            discIndex++;
          }
          current = (x: current.x + dir.x, y: current.y + dir.y);
        }
      }
    }

    final centerHexagon = _grid[(x: radius, y: radius)];
    if (centerHexagon != null && centerHexagon.type != HexagonType.empty) {
      centerHexagon.numberDisc =
          standardDiscs[discIndex % standardDiscs.length];
    }
  }

  //Returns the (x, y) index of a neighbour given the direction
  //Only works with Hexagons (axial coords) and the tileDirections
  ({int x, int y})? getNeighbour(int x, int y, (int, int) direction) {
    return (x: x + direction.$1, y: y + direction.$2);
  }

  //Returns number of hexagons on the board
  int get length => _grid.length;

  // returns a hexagon at the given axial coordinates or null if no hexagon exists there
  Hexagon? getHexagon(int x, int y) {
    return _grid[(x: x, y: y)];
  }

  //Erzeugt für jedes Hexagon die jeweiligen Knoten. Da keine Dubletten in Sets zugelassen sind,
  //erscheinen die gleichen Knotenpunkte nicht doppelt. Könnte man auch mit einer Hashmap realisieren
  Set<Node> initNodes() {
    Set<Node> nodes = {};
    _grid.forEach((_, hexagon) {
      nodes.add(Node(x: hexagon.top.x, y: hexagon.top.y));
      nodes.add(Node(x: hexagon.topRight.x, y: hexagon.topRight.y));
      nodes.add(Node(x: hexagon.bottomRight.x, y: hexagon.bottomRight.y));
      nodes.add(Node(x: hexagon.bottom.x, y: hexagon.bottom.y));
      nodes.add(Node(x: hexagon.bottomLeft.x, y: hexagon.bottomLeft.y));
      nodes.add(Node(x: hexagon.topLeft.x, y: hexagon.topLeft.y));
    });
    return nodes;
  }

  //Für eine gegebene Ecke werden die angrenzenden Hexagons zurückgegeben
  Set<Hexagon> getAdjacentHexagonsToNode(Node node) {
    Set<Hexagon> adjacentHexagons = {};

    //Siehe @Hexagon. Dort werden die Koordinaten zu den Ecken aus den Hexagon centern berechnet
    //Dies ist einfach die inverse Funktion und gibt die Richtungen für mögliche Hexagon center an
    List<Point2D> directions = [
      (x: node.x + 0.0, y: node.y + 0.5), // top
      (x: node.x - 0.5, y: node.y + 0.25), // topRight
      (x: node.x - 0.5, y: node.y - 0.25), // bottomRight
      (x: node.x + 0.0, y: node.y - 0.5), // bottom
      (x: node.x + 0.5, y: node.y - 0.25), // bottomLeft
      (x: node.x + 0.5, y: node.y + 0.25), // topLeft
    ];

    for (var dir in directions) {
      final axialCoord = Hexagon.cartesianToAxial(dir.x, dir.y);
      final hexagon = _grid[axialCoord];
      if (hexagon != null) {
        adjacentHexagons.add(hexagon);
      }
    }

    return adjacentHexagons;
  }

  //Using the same Loop as the Constructor, but here it returns a String
  @override
  String toString() {
    final buffer = StringBuffer();
    int startX = radius;
    for (int y = 0; y <= radius; y++) {
      for (int x = startX; x < 2 * radius + 1; x++) {
        final hexagon = _grid[(x: x, y: y)]!;
        // Ausgeben der Ziffer, die man für das Ressourcenfeld würfeln muss
        if (hexagon.type == HexagonType.empty) {
          buffer.write('[Desert:0]');
        } else {
          buffer.write('[${hexagon.type.name}:${hexagon.numberDisc}]');
        }
      }
      startX--;
      buffer.writeln();
    }
    int endX = radius * 2;
    for (int y = radius + 1; y < 2 * radius + 1; y++) {
      for (int x = 0; x < endX; x++) {
        // Ausgeben der Ziffer, die man für das Ressourcenfeld würfeln muss
        final hexagon = _grid[(x: x, y: y)]!;
        if (hexagon.type == HexagonType.empty) {
          buffer.write('[Desert:0]');
        } else {
          buffer.write('[${hexagon.type.name}:${hexagon.numberDisc}]');
        }
      }
      endX--;
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

///Record to hold a 2D Point in cartesian
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
  // Set sind diese Methodne bekannt und nutzt sie automatisch
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
  //Hier wird x und y als Axial-Punkt übergeben. Center ist aber eine karthesische Koordiante
  //deswegen wird umgerechnet
  Hexagon({required this.type, required int x, required int y})
    : axial = (x: x, y: y),
      center = (
        x: x + (y.isEven ? 0.0 : 0.5), // x-Offset: Die Hexagons zweier Reihen sind immer um genau 0.5 verschoben
        y: 0.5 + y * 0.75, //y- Offsett: Hexagon center an der y-Achse ist wie folgt: 0.5, 1.25, 2.0, 2.75, 3.5
      );

  final ({int x, int y}) axial;
  HexagonType type;
  int numberDisc =
      0; //jedes Hexagon hat ja einen Wert fürs Würfeln zum Ressourcen vergeben
  final Point2D center; //cartesian coordinates

  //Das sind die jeweiligen Ecken des Hexagons mit den entsprechenden Koords
  ({double x, double y}) get top => (x: center.x + 0.0, y: center.y - 0.5);
  ({double x, double y}) get topRight =>
      (x: center.x + 0.5, y: center.y - 0.25);
  ({double x, double y}) get bottomRight =>
      (x: center.x + 0.5, y: center.y + 0.25);
  ({double x, double y}) get bottom => (x: center.x + 0.0, y: center.y + 0.5);
  ({double x, double y}) get bottomLeft =>
      (x: center.x - 0.5, y: center.y + 0.25);
  ({double x, double y}) get topLeft => (x: center.x - 0.5, y: center.y - 0.25);

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

enum PlayerType { blue, red, yellow, green, none }

///Das HexagonBoard besteht aus Hexagons. Hexagons sind einmal über einen Index bzw AxialKoord. adressierbar (der key in _grid), 
///besitzen aber auch eine karthesische Koordinate (center). Jedes Hexagon hat 6 Ecken, die wiederum auch über eine karthesische Koordinate verfügen
class HexagonBoard {
  final Map<({int x, int y}), Hexagon> _grid = {};   // Der Schlüssel ist ein Axial Koordinatenpunkt

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

  ///Die Chips werden wie folgt verteilt: Wähle eine Ecke auf dem Spielbrett (hier einfach rechts-oben)
  ///und dann im Uhrzeigersinn alphabetisch anordnern (Spirale nach innen)
  ///boardRadius ist die Anzahl der Felder von Mitte bis Rand
  void placeNumberDiscs(int boardRadius) {
  //Das sind diese Chips die man auf die Spielbretter legt
  //1x "2" (B:)
  //2x "3" (D, Q)
  //2x "4" (J, N)
  //2x "5" (A, O)
  //2x "6" (C, P)
  // 7 ist der Bandit
  //2x "8" (E, K)
  //2x "9" (G, M)
  //2x "10" (F, L)
  //2x "11" (I, R)
  //1x "12" (H)
  //      referenceList=   A, B, C, D, E, F, G, H,  I,   J, K, L,  M, N, O, P, Q,  R
  final List<int> discs = [5, 2, 6, 3, 8, 10, 9, 12, 11, 4, 8, 10, 9, 4, 5, 6, 3,  11];


    const List<({int x, int y})> directions = [
    (x: -1, y: 0),  // links
    (x: 0,  y: 1),  // links-runter
    (x: 1,  y: 1),  // rechts-runter
    (x: 1,  y: 0),  // rechts
    (x: 0,  y: -1), // rechts-hoch
    (x: -1, y: -1), // links-hoch
    ];

    int discIndex = 0;
    //Arbeite das Board in Zwiebelschichten ab, beim Standardboard ist radius = 2
    for (int radius = boardRadius; radius > 0; radius --) {
      //Starte rechts-oben, also Standardbrett bei (4,0)
      ({int x, int y}) current = (x: radius * 2, y: 0);

      //Jeder Zwiebelring hat 6 Seiten
      for (int side = 0; side < 6; side++) {
        final dir = directions[side];

        //Hexagon für Hexagon
        for (int step = 0; step < radius; step ++) {
          final hexagon = _grid[current];
          if(hexagon != null && hexagon.type != HexagonType.empty) {
            hexagon.numberDisc = discs[discIndex];
            discIndex++;
          }

          //Update current: Gehe ein Hexagon weiter in der Spiral
          current = (x: current.x + dir.x, y: current.y + dir.y);

        }
      }
    }
  }


  //Returns the (x, y) index of a neighbour given the direction
  //Only works with Hexagons (axial coords) and the tileDirections
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

  //Für eine gegebene Ecke werden die angrenzenden Hexagons zurückgegeben
  Set<Hexagon> getAdjacentHexagonsToNode(Node node) {
    Set<Hexagon> adjacentHexagons = {};
    
    //Siehe @Hexagon. Dort werden die Koordinaten zu den Ecken aus den Hexagon centern berechnet
    //Dies ist einfach die inverse Funktion und gibt die Richtungen für mögliche Hexagon center an
    List<Point2D> directions = [
        (x: node.x + 0.0, y: node.y + 0.5),   // top
        (x: node.x - 0.5, y: node.y + 0.25),  // topRight
        (x: node.x - 0.5, y: node.y - 0.25),  // bottomRight
        (x: node.x + 0.0, y: node.y - 0.5),   // bottom
        (x: node.x + 0.5, y: node.y - 0.25),  // bottomLeft
        (x: node.x + 0.5, y: node.y + 0.25),  // topLeft
      ];

    for(var dir in directions) {
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
    : axial = (x:x , y:y),
    center = (
      x: x + (y.isEven? 0.0 : 0.5),  // x-Offset: Die Hexagons zweier Reihen sind immer um genau 0.5 verschoben
      y: 0.5 + y * 0.75   //y- Offsett: Hexagon center an der y-Achse ist wie folgt: 0.5, 1.25, 2.0, 2.75, 3.5
    );                    

  final ({int x, int y}) axial;
  HexagonType type;
  int numberDisc = 0;   //jedes Hexagon hat ja einen Wert fürs Würfeln zum Ressourcen vergeben
  final Point2D center; //cartesian coordinates


  //Das sind die jeweiligen Ecken des Hexagons mit den entsprechenden Koords
  ({double x, double y}) get top => (x: center.x + 0.0, y: center.y - 0.5);
  ({double x, double y}) get topRight => (x: center.x + 0.5, y: center.y - 0.25);
  ({double x, double y}) get bottomRight => (x: center.x + 0.5, y: center.y + 0.25);
  ({double x, double y}) get bottom => (x: center.x + 0.0, y: center.y + 0.5);
  ({double x, double y}) get bottomLeft => (x: center.x - 0.5, y: center.y + 0.25);
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

enum PlayerType {
  blue, red, yellow, green, none;
}

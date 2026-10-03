import 'package:game_of_hexia/src/models/resource_type.dart';
import 'package:game_of_hexia/src/models/node.dart';
import 'package:game_of_hexia/src/models/hexagon.dart';
import 'package:game_of_hexia/src/models/edge.dart';



///Das HexagonBoard besteht aus Hexagons. Hexagons sind einmal über einen Index bzw AxialKoord. adressierbar (der key in _grid),
///besitzen aber auch eine karthesische Koordinate (center). Jedes Hexagon hat 6 Ecken, die wiederum auch über eine karthesische Koordinate verfügen
class HexagonBoard {
  final int radius;
  final Map<({int x, int y}), Hexagon> _grid = {};   // Der Schlüssel ist ein Axial Koordinatenpunkt
  final Map<Point2D, Node> _nodes = {};
  final Set<Edge> allEdges = {};

  //Each tile/hexagon has 6 different directions/borders
  final tileDirections = [
       (0,-1),   (1, -1),
    (-1, 0),/* Hexa */ (1, 0),
       (-1, 1),   (0, 1)];

  /// Creates an empty hexagonal game board with the given radius.
  HexagonBoard({required this.radius}) {
    // A complete hexagonal board needs at least one ring around its center.
    if (radius < 1) {
      throw ArgumentError.value(radius, 'radius', 'must be at least 1');
    }

    final boardCenterX = radius + (radius.isOdd ? 0.5 : 0.0);
    for (int y = 0; y < 2 * radius + 1; y++) {
      final rowLength = 2 * radius + 1 - (y - radius).abs();
      final rowOffset = y.isEven ? 0.0 : 0.5;
      final startX =
          (boardCenterX - (rowLength - 1) / 2 - rowOffset).round();

      for (int x = startX; x < startX + rowLength; x++) {
        _grid[(x: x, y: y)] = Hexagon(type: ResourceType.empty, x: x, y: y);
      }
    }
    initNodes();
    initEdges();
  }

  //Use this to place hexagons randomly on board
  void placeHexagons() {
    const resourceTypes = [
      ResourceType.wood,
      ResourceType.cattle,
      ResourceType.fish,
      ResourceType.stone,
      ResourceType.iron,
    ];
    // Standard board ratio: 4 wood, cattle and fish; 3 stone and iron.
    const resourceWeights = [4, 4, 4, 3, 3];
    const totalResourceWeight = 18;
    // Keep roughly one desert for every standard-sized board section.
    final desertCount = (length / 19).round().clamp(1, length).toInt();
    final resourceTileCount = length - desertCount;
    final tileTypes = <ResourceType>[];

    for (var i = 0; i < desertCount; i++) {
      tileTypes.add(ResourceType.empty);
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
    const List<int> standardDiscs = [5, 2, 6, 3, 8, 10, 9, 12, 11, 4, 8, 10, 9, 4, 5, 6, 3, 11];

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
      // Startposition rechts oben für den Ring
      var current = (x: radius + ring, y: radius - ring);

      for (var side = 0; side < 6; side++) {
        final dir = directions[side];
        for (var step = 0; step < ring; step++) {
          final hexagon = _grid[current];
          if (hexagon != null && hexagon.type != ResourceType.empty) {
            hexagon.numberDisc = standardDiscs[discIndex % standardDiscs.length];
            discIndex++;
          }
          current = (x: current.x + dir.x, y: current.y + dir.y);
        }
      }
    }

    final centerHexagon = _grid[(x: radius, y: radius)];
    if (centerHexagon != null && centerHexagon.type != ResourceType.empty) {
      centerHexagon.numberDisc = standardDiscs[discIndex % standardDiscs.length];
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

  // returns a hexagon that has the given number on it (the dices rolled its number)
  List<Hexagon> getHexagonWithRolledNumber(int diceValue) {
    return _grid.values
        .where((hexagon) => hexagon.numberDisc == diceValue)
        .toList();
  }

  // returns a Node by its given coordinates
  Node? getNode(double x, double y) {
    return _nodes[(x: x, y: y)];
  }

  // Creates each board node once and keeps it available for ownership and buildings.
  Set<Node> initNodes() {
    _grid.forEach((_, hexagon) {
      _nodes.putIfAbsent(
        hexagon.top,
        () => Node(x: hexagon.top.x, y: hexagon.top.y),
      );
      _nodes.putIfAbsent(
        hexagon.topRight,
        () => Node(x: hexagon.topRight.x, y: hexagon.topRight.y),
      );
      _nodes.putIfAbsent(
        hexagon.bottomRight,
        () => Node(x: hexagon.bottomRight.x, y: hexagon.bottomRight.y),
      );
      _nodes.putIfAbsent(
        hexagon.bottom,
        () => Node(x: hexagon.bottom.x, y: hexagon.bottom.y),
      );
      _nodes.putIfAbsent(
        hexagon.bottomLeft,
        () => Node(x: hexagon.bottomLeft.x, y: hexagon.bottomLeft.y),
      );
      _nodes.putIfAbsent(
        hexagon.topLeft,
        () => Node(x: hexagon.topLeft.x, y: hexagon.topLeft.y),
      );
    });
    return _nodes.values.toSet();
  }


  // füllt die Liste, also das Klassenattribut allEdges mit allen Kanten des boards
  Set<Edge> initEdges() {

    _grid.forEach((key, hexagon){

      for (int i = 0; i < hexagon.corners.length; i++){
        Node? n = _nodes[hexagon.corners[i]];
        Node? m = _nodes[hexagon.corners[(i + 1) % 6]];

        Edge e = Edge(n!, m!);
        allEdges.add(e);
      }

      });
       return allEdges;
    }

  // Gibt die 0- max 3 benachbarten Nodes eines Nodes zurück
  Set<Node> getAdjacentNodesToNode(Node n) {
    Set<Node> adjacentNodes = {};

    allEdges.forEach((edge){

          if (n == edge.n) {
            adjacentNodes.add(edge.m);
          } if (n == edge.m) {
            adjacentNodes.add(edge.n);
          }
      });
      return adjacentNodes;
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
        if (hexagon.type == ResourceType.empty) {
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
        if (hexagon.type == ResourceType.empty) {
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





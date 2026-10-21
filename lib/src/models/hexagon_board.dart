import 'package:game_of_hexia/src/models/edge.dart';
import 'package:game_of_hexia/src/models/hexagon.dart';
import 'package:game_of_hexia/src/models/node.dart';
import 'package:game_of_hexia/src/models/resource_type.dart';
import 'package:game_of_hexia/src/models/robber.dart';
import 'package:game_of_hexia/src/models/harbor.dart';

/// A hexagonal board whose tiles use axial indices and Cartesian geometry.
class HexagonBoard {
  final int radius;

  /// Tiles keyed by their axial coordinates.
  final Map<({int x, int y}), Hexagon> _grid = {};
  final Map<Point2D, Node> _nodes = {};
  final Set<Edge> allEdges = {};
  final Set<Harbor> harbors = {};
  Robber? robber;

  /// Offsets to the six neighboring axial coordinates.
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

    final boardCenterX = radius + (radius.isOdd ? 0.5 : 0.0);
    for (int y = 0; y < 2 * radius + 1; y++) {
      final rowLength = 2 * radius + 1 - (y - radius).abs();
      final rowOffset = y.isEven ? 0.0 : 0.5;
      final startX = (boardCenterX - (rowLength - 1) / 2 - rowOffset).round();

      for (int x = startX; x < startX + rowLength; x++) {
        _grid[(x: x, y: y)] = Hexagon(type: ResourceType.empty, x: x, y: y);
      }
    }
    initNodes();
    initEdges();
    initHarbors();
  }

  /// Randomly assigns resources and places the robber on the first desert.
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
    for (final hex in _grid.values) {
      if (hex.type == ResourceType.empty) {
        robber = Robber(hex);
        break;
      }
    }
  }

  /// Places number discs in a spiral, starting at the outer top-right corner.
  /// Deserts are skipped; larger boards repeat the standard sequence.
  void placeNumberDiscs() {
    const discs = [5, 2, 6, 3, 8, 10, 9, 12, 11, 4, 8, 10, 9, 4, 5, 6, 3, 11];

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
      // Walk each ring clockwise from its top-right tile.
      var current = (x: radius + ring, y: radius - ring);

      for (var side = 0; side < 6; side++) {
        final dir = directions[side];
        for (var step = 0; step < ring; step++) {
          final hexagon = _grid[current];
          if (hexagon != null && hexagon.type != ResourceType.empty) {
            hexagon.numberDisc = discs[discIndex % discs.length];
            discIndex++;
          }
          current = (x: current.x + dir.x, y: current.y + dir.y);
        }
      }
    }

    final centerHexagon = _grid[(x: radius, y: radius)];
    if (centerHexagon != null && centerHexagon.type != ResourceType.empty) {
      centerHexagon.numberDisc = discs[discIndex % discs.length];
    }
  }

  /// Applies an axial [direction] to the tile at ([x], [y]).
  ({int x, int y})? getNeighbour(int x, int y, (int, int) direction) {
    return (x: x + direction.$1, y: y + direction.$2);
  }

  /// Number of tiles on the board.
  int get length => _grid.length;

  /// Returns the tile at the axial coordinate ([x], [y]), if one exists.
  Hexagon? getHexagon(int x, int y) {
    return _grid[(x: x, y: y)];
  }

  /// Returns all tiles whose number disc matches [diceValue].
  List<Hexagon> getHexagonWithRolledNumber(int diceValue) {
    return _grid.values
        .where((hexagon) => hexagon.numberDisc == diceValue)
        .toList();
  }

  /// Returns all board tiles in insertion order.
  List<Hexagon> getHexagons() {
    return _grid.values.toList();
  }

  /// Returns the node at the Cartesian coordinate ([x], [y]), if one exists.
  Node? getNode(double x, double y) {
    return _nodes[(x: x, y: y)];
  }

  /// Creates each shared board node once and returns all nodes.
  Set<Node> initNodes() {
    for (final hexagon in _grid.values) {
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
    }
    return _nodes.values.toSet();
  }

  /// Creates each undirected edge once and returns all board edges.
  Set<Edge> initEdges() {
    for (final hexagon in _grid.values) {
      for (var i = 0; i < hexagon.corners.length; i++) {
        final n = _nodes[hexagon.corners[i]];
        final m = _nodes[hexagon.corners[(i + 1) % 6]];
        allEdges.add(Edge(n!, m!));
      }
    }
    //Sets Flag if Edge is Coastal
    for (Edge edge in allEdges) {
      final hexagonsAtN = getAdjacentHexagonsToNode(edge.n);
      final hexagonsAtM = getAdjacentHexagonsToNode(edge.m);
      final hexagonsAlongEdge = hexagonsAtN.intersection(hexagonsAtM);
      if (hexagonsAlongEdge.length == 1) {
        edge.isCoastalEdge = true;
      }
    }
    return allEdges;
  }

  /// Returns the nodes connected to [n] by a board edge.
  Set<Node> getAdjacentNodesToNode(Node n) {
    final adjacentNodes = <Node>{};

    for (final edge in allEdges) {
      if (n == edge.n) {
        adjacentNodes.add(edge.m);
      }
      if (n == edge.m) {
        adjacentNodes.add(edge.n);
      }
    }
    return adjacentNodes;
  }

  /// Returns the board tiles that share [node].
  Set<Hexagon> getAdjacentHexagonsToNode(Node node) {
    final adjacentHexagons = <Hexagon>{};

    // Inverse corner offsets locate every possible neighboring tile center.
    final directions = <Point2D>[
      (x: node.x + 0.0, y: node.y + 0.5), // top
      (x: node.x - 0.5, y: node.y + 0.25), // topRight
      (x: node.x - 0.5, y: node.y - 0.25), // bottomRight
      (x: node.x + 0.0, y: node.y - 0.5), // bottom
      (x: node.x + 0.5, y: node.y - 0.25), // bottomLeft
      (x: node.x + 0.5, y: node.y + 0.25), // topLeft
    ];

    for (final direction in directions) {
      final axialCoord = Hexagon.cartesianToAxial(direction.x, direction.y);
      final hexagon = _grid[axialCoord];
      if (hexagon != null) {
        adjacentHexagons.add(hexagon);
      }
    }

    return adjacentHexagons;
  }

  /// Formats the board row by row for console diagnostics.
  @override
  String toString() {
    const cellWidth = 12;
    final buffer = StringBuffer();
    for (var y = 0; y <= 2 * radius; y++) {
      final row = _grid.values.where((hexagon) => hexagon.axial.y == y).toList()
        ..sort((a, b) => a.axial.x.compareTo(b.axial.x));

      final indent = (radius - y).abs() * (cellWidth ~/ 2);
      buffer.write(List.filled(indent, ' ').join());

      for (final hexagon in row) {
        final label = hexagon.type == ResourceType.empty
            ? '[Desert:0]'
            : '[${hexagon.type.name}:${hexagon.numberDisc}]';
        buffer.write(label.padRight(cellWidth));
      }

      if (y < 2 * radius) buffer.writeln();
    }
    return buffer.toString().trimRight();
  }

  /// Returns the shortest path length in edges between [start] and [target].
  int getShortestDistance(Node start, Node target) {
    if (start == target) return 0;

    final queue = <Node>[start];
    final distances = <Node, int>{start: 0};
    var queueIndex = 0;

    while (queueIndex < queue.length) {
      final current = queue[queueIndex++];
      final nextDistance = distances[current]! + 1;

      for (final neighbor in getAdjacentNodesToNode(current)) {
        if (distances.containsKey(neighbor)) continue;
        if (neighbor == target) return nextDistance;

        distances[neighbor] = nextDistance;
        queue.add(neighbor);
      }
    }
    return 0;
  }

  ///Places Harbors randomly. Ends up with slightly different number than original game.
  ///In particual only creates 8 harbors for radius 2 instead of 9
  Set<Harbor> initHarbors() {
    final int maxNumberOfGeneralHarbors = (0.46 * (radius * 3 + 3)).round();
    final int maxNumberOfSpecialHarbors = (0.54 * (radius * 3 + 3)).round();

    //place harbors randomly along coastal edges. Needs at least 1 Node between the edges
    harbors.clear(); 
    List<Edge> coastalEdges = [];
    for (final edge in allEdges) {
      if (edge.isCoastalEdge) {
        coastalEdges.add(edge);
      }
    }
    coastalEdges.shuffle();
    int addedHarbors = 0;

    //Place general harbors
    while (addedHarbors < maxNumberOfGeneralHarbors && coastalEdges.isNotEmpty) {
      final candidateEdge = coastalEdges.removeLast(); 
      bool isValid = true;
      for (final harbor in harbors) {
        if (!_isAtLeastOneNodeAway(harbor.edge, candidateEdge)) {
          isValid = false;
          break;
        }
      }
      if (isValid) { 
        harbors.add(Harbor(edge: candidateEdge, tradeType: ResourceType.empty, exchangeRatio:  2));
        addedHarbors++;
      }
    }

    //Place special harbors
    addedHarbors = 0;
    while (addedHarbors < maxNumberOfSpecialHarbors && coastalEdges.isNotEmpty) {
      final candidateEdge = coastalEdges.removeLast(); 
      bool isValid = true;
      for (final harbor in harbors) {
        if (!_isAtLeastOneNodeAway(harbor.edge, candidateEdge)) {
          isValid = false;
          break;
        }
      }
      if (isValid) { 
        final tradeType = ResourceType.values[addedHarbors % 5];
        harbors.add(Harbor(edge: candidateEdge, tradeType: tradeType, exchangeRatio:  3));
        addedHarbors++;
      }
    }
    return harbors;
  }

  bool _isAtLeastOneNodeAway(Edge A, Edge B){
    return getShortestDistance(A.n, B.n) > 1 &&
          getShortestDistance(A.n, B.m) > 1 &&
          getShortestDistance(A.m, B.n) > 1 &&
          getShortestDistance(A.m, B.m) > 1;
  } 
}

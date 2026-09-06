///Tiles are represented by axel coordinates (r, q)
///See https://www.redblobgames.com/grids/hexagons/#conversions-axial
class HexagonBoard {
  final Map<({int r, int q}), Hexagon> _grid = {};

  final directions = [
       (0, -1),   (1, -1),
    (-1, 0),/* Hexa */ (1, 0), 
       (-1, 1),   (0, 1)];

    /// Creates an empty game board. Could be generalized to create any sized hexagon board
  HexagonBoard() {
    //q as starting point in the hexagon grid. the fist row is (0,2), (0,3), (0,4)
    int q = 2;
    for(int r = 0; r < 3; r++) {
      for(int i = q; i < 5; i++) {
        _grid[(r: r, q: i)] = Hexagon.empty;
      }
      q--;
    }

    //q as limit in the grid. the last row is (6,0), (6,1), (6,2)
    q = 4;
    for(int r = 3; r < 5; r++) {
      for(int i = 0; i < q; i++) {
        _grid[(r: r, q: i)] = Hexagon.empty;
      }
      q--;
    }
  }

  //Returns the (r, q) Coords of Neighbour
  ({int r, int q})? getNeighbour(int r, int q, (int, int) direction) {
    return (r: r + direction.$1, q: q + direction.$2);
  }

  //Returns Size of the Map
  int get length => _grid.length;

  @override
  String toString() {
    //this is the same loop as in the constructor. just to see if its working
    final buffer = StringBuffer();
    int q = 2;
    for(int r = 0; r < 3; r++) {
      for(int i = q; i < 5; i++) {
        buffer.write('[ ]');
      }
      q--;
      buffer.writeln();
    }
    q = 4;
    for(int r = 3; r < 5; r++) {
      for(int i = 0; i < q; i++) {
        buffer.write('[ ]');
      }
      q--;
      buffer.writeln();
    }
    return buffer.toString().trimRight();
  }
}

enum Hexagon {
  stone(name: "Stone", number: 3),
  wood(name: "Wood", number: 4),
  cattle(name: "Cattle", number: 4),
  fish(name: "Fish", number: 4),
  iron(name: "Iron", number: 3),
  empty(name: "Empty", number: 1);

  final String name;
  final int number;
  const Hexagon({required this.name, required this.number});
}
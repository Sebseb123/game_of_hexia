///Tiles are represented by axel coordinates (r, q)
///See https://www.redblobgames.com/grids/hexagons/#conversions-axial
class HexagonBoard {
  final Map<({int r, int q}), Hexagon> _grid = {};

  //Each tile/hexagon has 6 different directions/borders
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
        _grid[(r: r, q: i)] = Hexagon(type: HexagonType.empty, owner: PlayerType.none);
      }
      q--;
    }
    //q as limit in the grid. the last row is (6,0), (6,1), (6,2)
    q = 4;
    for(int r = 3; r < 5; r++) {
      for(int i = 0; i < q; i++) {
        _grid[(r: r, q: i)] = Hexagon(type: HexagonType.empty, owner: PlayerType.none);
      }
      q--;
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

  //Returns the (r, q) Coords of Neighbour
  ({int r, int q})? getNeighbour(int r, int q, (int, int) direction) {
    return (r: r + direction.$1, q: q + direction.$2);
  }

  //Returns Size of the Map
  int get length => _grid.length;

  //Using the same Loop as the Constructor, but this time prints
  @override
  String toString() {
    final buffer = StringBuffer();
    int q = 2;
    for(int r = 0; r < 3; r++) {
      for(int i = q; i < 5; i++) {
        buffer.write('[${_grid[(r: r,q: i)]?.type.name}]');
      }
      q--;
      buffer.writeln();
    }
    q = 4;
    for(int r = 3; r < 5; r++) {
      for(int i = 0; i < q; i++) {
        buffer.write('[${_grid[(r: r,q: i)]?.type.name}]');
      }
      q--;
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

//The game tile
class Hexagon {
  Hexagon({required this.type, required this._owner, this._numberDisc});
  HexagonType type;
  PlayerType _owner;
  int? _numberDisc;


}

//Goes on the Hexagons. There is a way to dsitribute them in the game guide. Otherwise could distribute random
const List<int> numberDiscs = [2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12];

enum PlayerType {
  blue, red, yellow, green, none;
}
import 'package:game_of_hexia/src/models/node.dart';
import 'package:game_of_hexia/src/models/player.dart';


class Edge {
  Node n;
  Node m;
  PlayerColor? roadOwner;

  Edge(this.n, this.m) {
    if ( n == m )  throw ArgumentError('An edge needs two different nodes');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Edge &&
        ((other.n == n && other.m == m) || (other.n == m && other.m == n));
  }

  //siehe Methode "bool operator"
  @override
  int get hashCode => Object.hash(n, m) ^ Object.hash(m, n);
}

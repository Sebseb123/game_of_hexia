import 'package:game_of_hexia/src/models/edge.dart';
import 'package:game_of_hexia/src/models/hexagon_board.dart';
import 'package:game_of_hexia/src/models/resource_type.dart';
import 'package:game_of_hexia/src/models/node.dart';

class Harbor {
  final Edge edge;
  final ResourceType tradeType;
  final int exchangeRatio;

  Harbor({required this.edge, required this.tradeType, required this.exchangeRatio}){
    if (!edge.isCoastalEdge) {
      throw ArgumentError.value('Edge must be a coastal edge');
    }
  }

  Node nodeA() {
    return edge.n;
  }
  Node nodeB() {
    return edge.m;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Harbor &&
        other.edge == edge &&
        other.tradeType == tradeType &&
        other.exchangeRatio == exchangeRatio;
  }

  @override
  int get hashCode => Object.hash(edge, tradeType, exchangeRatio);
}

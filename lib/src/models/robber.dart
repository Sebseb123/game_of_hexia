import 'package:game_of_hexia/src/models/hexagon.dart';

/// Tracks the field currently occupied by the robber.
class Robber {
  Hexagon currentPosition;

  Robber(this.currentPosition);
}

import 'package:game_of_hexia/src/logic/dice.dart';
import 'package:game_of_hexia/src/models/hexagon_board.dart';
import 'package:game_of_hexia/src/models/building_type.dart';
import 'package:game_of_hexia/src/models/player.dart';


/// Coordinates game actions between the board, dice and players.
class GameController {
  final HexagonBoard gameBoard;
  final Dices dice;
  final List<Player> players;
  int activePlayerIndex = 0;

  GameController({
    required this.gameBoard,
    required this.dice,
    required this.players,
  });

  /// Rolls once and distributes resources for the resulting total.
  int rollDice() {
    int dice1 = 0;
    int dice2 = 0;
    (int, int) result = dice.rollDices();
    dice1 = result.$1;
    dice2 = result.$2;
    final total = dice1 + dice2;
    distributeResources(total);
    return total;
  }

  /// Returns all resource fields that produce for [diceValue].
  List<Hexagon> getRolledHexagons(int diceValue) {
    return gameBoard.getHexagonWithRolledNumber(diceValue);
  }

  /// Gives each settlement or city next to a producing field its resource.
  void distributeResources(int diceValue) {

    List<Hexagon> rolledHexagons = getRolledHexagons(diceValue);
    // Für jedes Hexagon prüfen, ob eine der Ecken ein Node ist, der im
    // Besitz eines Spielers ist
    for ( final hex in rolledHexagons){
       List<Point2D> hexCorners = hex.corners;

       for ( final corner in hexCorners) {
         final node = gameBoard.getNode(corner.x, corner.y);

         if (node != null) {
           final PlayerColor? owner = node.owner;
           final BuildingType? building = node.building;

           if (owner!=null && building != null) {
             for (final p in players) {
               if (p.color == owner) {
                 p.addResource(resource: hex.type, amount: 1, building: building);
               }
             }
           }
         }
       }
    }
  }

   /// Returns the player whose turn is currently active.
   Player getActivePlayer(){
    return players[activePlayerIndex];
  }

  // setzt aktiven Spieler für die nächste Runde
  void endTurn() {
    activePlayerIndex = (activePlayerIndex + 1) % players.length;
  }


}

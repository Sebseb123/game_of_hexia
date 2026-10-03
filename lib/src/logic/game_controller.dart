import 'package:game_of_hexia/src/logic/dice.dart';
import 'package:game_of_hexia/src/models/hexagon_board.dart';
import 'package:game_of_hexia/src/models/building_type.dart';
import 'package:game_of_hexia/src/models/hexagon.dart';
import 'package:game_of_hexia/src/models/node.dart';
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

  // setzt aktiven Spieler für die nächste Runde, wird später bei
  // am Ende jeder Runde aufgerufen
  void endTurn() {
    activePlayerIndex = (activePlayerIndex + 1) % players.length;
  }

  // setzt/baut eine Siedlung auf einen node. Falls erfolgreich: true, sonst false
  bool placeSettlement(Node node){

    // node existiert nicht oder ist belegt
    if (node.owner != null || node.building != null) {return false;}

    // Abstände zur nächsten Siedlung/Stadt prüfen
    if (possibleToPlaceSettlement(node) == false) return false;
    final activePlayer = getActivePlayer();

    // TODO: Ressourcen des Spielers der bauen will prüfen,
    //  TODO: Existenz von Straßen des Spielers prüfen

    node.owner = activePlayer.color;
    node.building = BuildingType.settlement;
    return true;
  }

   // baut eine Stadt auf einen Knoten, auf dem schon eine Siedlung des sleben
  // Spielers gesetzt sein muss
  bool upgradeSettlementToCity(Node node) {

    // node existiert nicht oder ist keine Siedlung
    if (node.building != BuildingType.settlement) {
      return false;}
    if (possibleToPlaceCity(node) == false) return false;

    final activePlayer = getActivePlayer();
    // Besitzer des Knotens ist anderer Spieler
    if (node.owner != activePlayer.color) return false;
    // TODO: Ressource, Straßen
    node.building = BuildingType.city;
    return true;

  }


  // Prüft Abstandsregeln zum Siedlung/Stadt bauen:
  // beide dürfen nicht direkt neben einer anderen gebauet werden
  bool possibleToPlaceSettlement(Node n ) {

    if (n.owner != null || n.building != null) {return false;}

    Set<Node> adjacentNodes = gameBoard.getAdjacentNodesToNode(n);
    for (final node in adjacentNodes) {
      if (node.owner != null || node.building != null) return false;
    }
     return true;
  }

  // Prüft, ob ein Knoten geeignet dafür ist, eine Stadt zu bauen
  // Prüfung ist nur ein Teil, Ressourcen und Straßen werden in
  // anderen Methoden geprüft
  bool possibleToPlaceCity(Node n){

    Player activePlayer = getActivePlayer();
    Set<Node> adjacentNodes = gameBoard.getAdjacentNodesToNode(n);
    for (final node in adjacentNodes) {
      if (node.owner != null || node.building != null) return false;
    }
    return n.owner == activePlayer.color && n.building == BuildingType.settlement;

  }



  }

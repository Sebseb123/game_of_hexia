import 'package:game_of_hexia/src/models/development_card_type.dart';

/// A shuffled standard deck of 25 development cards.
class DevelopmentCardDeck {
  /// Remaining cards in draw order; the last item is drawn next.
  final List<DevelopmentCardType> cardDeck = [];

  DevelopmentCardDeck() {
    for (int i = 14; i > 0; i--) {
      cardDeck.add(DevelopmentCardType.knight);
    }
    for (int i = 2; i > 0; i--) {
      cardDeck.add(DevelopmentCardType.monopoly);
      cardDeck.add(DevelopmentCardType.roadBuilding);
      cardDeck.add(DevelopmentCardType.yearOfPlenty);
    }
    for (int i = 5; i > 0; i--) {
      cardDeck.add(DevelopmentCardType.victoryPoint);
    }
    cardDeck.shuffle();
  }
}

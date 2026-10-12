/// Development cards available in the standard deck.
enum DevelopmentCardType {
  knight(name: 'Knight'),
  roadBuilding(name: 'Road Building'),
  yearOfPlenty(name: 'Year of Plenty'),
  monopoly(name: 'Monopoly'),
  victoryPoint(name: 'Victory Point');

  final String name;
  const DevelopmentCardType({required this.name});
}

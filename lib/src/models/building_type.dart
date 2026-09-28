
/// Building types that determine how many resources a node produces.
enum BuildingType {
  settlement(name: "Settlement"),
  city(name: "City");

  final String name;
  const BuildingType({required this.name});
}


/// Resources produced by fields; [empty] represents a desert field.
enum ResourceType {
  stone(name: "Stone"),
  wood(name: "Wood"),
  cattle(name: "Cattle"),
  fish(name: "Fish"),
  iron(name: "Iron"),
  empty(name: "Empty");

  final String name;
  const ResourceType({required this.name});

}

class Digimon {
  final String id;
  final String name;
  final String image;
  final List<String> levels;
  final List<String> attributes;
  final List<String> types;
  final String? description;

  Digimon({
    required this.id,
    required this.name,
    required this.image,
    required this.levels,
    required this.attributes,
    required this.types,
    this.description,
  });

  @override
  String toString() {
    return 'Digimon(id: $id, name: $name, levels: $levels, attributes: $attributes, types: $types)';
  }
}

class DigimonResponse {
  final bool success;
  final String? message;
  final Digimon? digimon;

  DigimonResponse({
    required this.success,
    this.message,
    this.digimon,
  });
}
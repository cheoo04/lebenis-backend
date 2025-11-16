class ZoneModel {
  final String id;
  final String name;
  final bool selected;

  ZoneModel({
    required this.id,
    required this.name,
    this.selected = false,
  });

  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    return ZoneModel(
      id: json['id'] as String,
      name: json['name'] as String,
      selected: json['selected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'selected': selected,
      };

  ZoneModel copyWith({bool? selected}) => ZoneModel(
        id: id,
        name: name,
        selected: selected ?? this.selected,
      );
}

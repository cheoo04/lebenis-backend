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
    // Support multiple response shapes: detailed zones or grouped communes
    final id = (json['id'] ?? json['commune'] ?? json['name']) as String;
    final name = (json['zone_name'] ?? json['commune_display'] ?? json['commune'] ?? json['name']) as String;
    return ZoneModel(
      id: id,
      name: name,
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

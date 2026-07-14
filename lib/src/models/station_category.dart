import 'dart:convert';

class StationCategory {
  const StationCategory({required this.id, required this.name});

  final String id;
  final String name;

  factory StationCategory.fromStorage(String value, {required int index}) {
    final trimmed = value.trim();
    if (trimmed.startsWith('{')) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map<String, dynamic>) {
          final name = _readString(decoded['name'], fallback: 'Saved').trim();
          final fallbackId = idFromName(name, index: index);
          final id = _readString(decoded['id'], fallback: fallbackId).trim();
          return StationCategory(
            id: id.isEmpty ? fallbackId : id,
            name: name.isEmpty ? 'Saved' : name,
          );
        }
      } on FormatException {
        // Fall through to the legacy string format.
      }
    }

    final name = trimmed.isEmpty ? 'Saved' : trimmed;
    return StationCategory(
      id: idFromName(name, index: index),
      name: name,
    );
  }

  static StationCategory create(String name, {required int index}) {
    final normalizedName = name.trim().isEmpty ? 'Saved' : name.trim();
    return StationCategory(
      id: idFromName(normalizedName, index: index),
      name: normalizedName,
    );
  }

  static String idFromName(String name, {required int index}) {
    final slug = name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return 'category-$index-${slug.isEmpty ? 'saved' : slug}';
  }

  StationCategory copyWith({String? id, String? name}) {
    return StationCategory(id: id ?? this.id, name: name ?? this.name);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id, 'name': name};
  }

  String toStorage() => jsonEncode(toJson());

  static String _readString(Object? value, {String fallback = ''}) {
    if (value == null) {
      return fallback;
    }
    return value.toString();
  }
}

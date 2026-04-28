import 'dart:convert';

class FavoriteCategory {
  const FavoriteCategory({required this.id, required this.name});

  final String id;
  final String name;

  factory FavoriteCategory.fromStorage(String value, {required int index}) {
    final trimmed = value.trim();
    if (trimmed.startsWith('{')) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map<String, dynamic>) {
          final name = _readString(
            decoded['name'],
            fallback: 'Favorites',
          ).trim();
          final fallbackId = idFromName(name, index: index);
          final id = _readString(decoded['id'], fallback: fallbackId).trim();
          return FavoriteCategory(
            id: id.isEmpty ? fallbackId : id,
            name: name.isEmpty ? 'Favorites' : name,
          );
        }
      } on FormatException {
        // Fall through to the legacy string format.
      }
    }

    final name = trimmed.isEmpty ? 'Favorites' : trimmed;
    return FavoriteCategory(
      id: idFromName(name, index: index),
      name: name,
    );
  }

  static FavoriteCategory create(String name, {required int index}) {
    final normalizedName = name.trim().isEmpty ? 'Favorites' : name.trim();
    return FavoriteCategory(
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
    return 'category-$index-${slug.isEmpty ? 'favorites' : slug}';
  }

  FavoriteCategory copyWith({String? id, String? name}) {
    return FavoriteCategory(id: id ?? this.id, name: name ?? this.name);
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

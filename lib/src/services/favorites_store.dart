import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/radio_station.dart';

abstract class FavoritesStore {
  Future<Map<String, List<RadioStation>>> loadFavorites();
  Future<void> saveFavorites(
    Map<String, List<RadioStation>> stationsByCategory,
  );
}

class SharedPreferencesFavoritesStore implements FavoritesStore {
  SharedPreferencesFavoritesStore(this._preferences);

  static const String _favoritesKey = 'favorite_stations';
  static const String _favoritesByCategoryKey = 'favorite_stations_by_category';

  final SharedPreferences _preferences;

  @override
  Future<Map<String, List<RadioStation>>> loadFavorites() async {
    final rawFavoritesByCategory = _preferences.getString(
      _favoritesByCategoryKey,
    );
    if (rawFavoritesByCategory != null &&
        rawFavoritesByCategory.trim().isNotEmpty) {
      final decoded = jsonDecode(rawFavoritesByCategory);
      if (decoded is Map<String, dynamic>) {
        return decoded.map((key, value) {
          final stations = value is List
              ? value
                    .whereType<String>()
                    .map(RadioStation.fromStorage)
                    .toList(growable: false)
              : const <RadioStation>[];
          return MapEntry(key, stations);
        });
      }
    }

    final rawStations = _preferences.getStringList(_favoritesKey) ?? <String>[];
    return <String, List<RadioStation>>{
      'Favorites': rawStations
          .map(RadioStation.fromStorage)
          .toList(growable: false),
    };
  }

  @override
  Future<void> saveFavorites(
    Map<String, List<RadioStation>> stationsByCategory,
  ) async {
    final serialized = stationsByCategory.map(
      (key, value) => MapEntry(
        key,
        value.map((station) => station.toStorage()).toList(growable: false),
      ),
    );
    await _preferences.setString(
      _favoritesByCategoryKey,
      jsonEncode(serialized),
    );
    await _preferences.remove(_favoritesKey);
  }
}

import 'package:shared_preferences/shared_preferences.dart';

import '../models/radio_station.dart';

abstract class FavoritesStore {
  Future<List<RadioStation>> loadFavorites();
  Future<void> saveFavorites(List<RadioStation> stations);
}

class SharedPreferencesFavoritesStore implements FavoritesStore {
  SharedPreferencesFavoritesStore(this._preferences);

  static const String _favoritesKey = 'favorite_stations';

  final SharedPreferences _preferences;

  @override
  Future<List<RadioStation>> loadFavorites() async {
    final rawStations = _preferences.getStringList(_favoritesKey) ?? <String>[];
    return rawStations.map(RadioStation.fromStorage).toList(growable: false);
  }

  @override
  Future<void> saveFavorites(List<RadioStation> stations) async {
    final values = stations.map((station) => station.toStorage()).toList();
    await _preferences.setStringList(_favoritesKey, values);
  }
}

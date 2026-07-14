import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/radio_station.dart';

abstract class CategoryStationsStore {
  Future<Map<String, List<RadioStation>>> loadStationsByCategory();
  Future<void> saveStationsByCategory(
    Map<String, List<RadioStation>> stationsByCategory,
  );
}

class SharedPreferencesCategoryStationsStore implements CategoryStationsStore {
  SharedPreferencesCategoryStationsStore(this._preferences);

  static const String _stationsByCategoryKey = 'station_category_stations';

  final SharedPreferences _preferences;

  @override
  Future<Map<String, List<RadioStation>>> loadStationsByCategory() async {
    final rawStationsByCategory = _preferences.getString(
      _stationsByCategoryKey,
    );
    if (rawStationsByCategory != null &&
        rawStationsByCategory.trim().isNotEmpty) {
      final decoded = jsonDecode(rawStationsByCategory);
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

    return const <String, List<RadioStation>>{};
  }

  @override
  Future<void> saveStationsByCategory(
    Map<String, List<RadioStation>> stationsByCategory,
  ) async {
    final serialized = stationsByCategory.map(
      (key, value) => MapEntry(
        key,
        value.map((station) => station.toStorage()).toList(growable: false),
      ),
    );
    await _preferences.setString(
      _stationsByCategoryKey,
      jsonEncode(serialized),
    );
  }
}

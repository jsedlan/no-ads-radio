import 'package:shared_preferences/shared_preferences.dart';

import '../models/radio_station.dart';

class AppSettings {
  const AppSettings({
    this.showStationIcon = false,
    this.circleThroughFavorites = true,
    this.countryCodes = const <String>[],
    this.manualStations = const <RadioStation>[],
    this.favoriteCategories = const <String>['Favorites'],
  });

  final bool showStationIcon;
  final bool circleThroughFavorites;
  final List<String> countryCodes;
  final List<RadioStation> manualStations;
  final List<String> favoriteCategories;

  AppSettings copyWith({
    bool? showStationIcon,
    bool? circleThroughFavorites,
    List<String>? countryCodes,
    List<RadioStation>? manualStations,
    List<String>? favoriteCategories,
  }) {
    return AppSettings(
      showStationIcon: showStationIcon ?? this.showStationIcon,
      circleThroughFavorites:
          circleThroughFavorites ?? this.circleThroughFavorites,
      countryCodes: countryCodes ?? this.countryCodes,
      manualStations: manualStations ?? this.manualStations,
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
    );
  }
}

abstract class SettingsStore {
  Future<AppSettings> loadSettings();
  Future<void> saveSettings(AppSettings settings);
}

class SharedPreferencesSettingsStore implements SettingsStore {
  SharedPreferencesSettingsStore(this._preferences);

  static const String _showStationIconKey = 'show_station_icon';
  static const String _circleThroughFavoritesKey = 'circle_through_favorites';
  static const String _countryCodesKey = 'country_codes';
  static const String _manualStationsKey = 'manual_stations';
  static const String _favoriteCategoriesKey = 'favorite_categories';

  final SharedPreferences _preferences;

  @override
  Future<AppSettings> loadSettings() async {
    final favoriteCategories =
        _preferences.getStringList(_favoriteCategoriesKey) ??
        const <String>['Favorites'];
    return AppSettings(
      showStationIcon: _preferences.getBool(_showStationIconKey) ?? false,
      circleThroughFavorites:
          _preferences.getBool(_circleThroughFavoritesKey) ?? true,
      countryCodes: List<String>.unmodifiable(
        _preferences.getStringList(_countryCodesKey) ?? const <String>[],
      ),
      manualStations: List<RadioStation>.unmodifiable(
        (_preferences.getStringList(_manualStationsKey) ?? const <String>[])
            .map(RadioStation.fromStorage),
      ),
      favoriteCategories: List<String>.unmodifiable(
        favoriteCategories.isEmpty
            ? const <String>['Favorites']
            : favoriteCategories,
      ),
    );
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    await _preferences.setBool(_showStationIconKey, settings.showStationIcon);
    await _preferences.setBool(
      _circleThroughFavoritesKey,
      settings.circleThroughFavorites,
    );
    await _preferences.setStringList(_countryCodesKey, settings.countryCodes);
    await _preferences.setStringList(
      _manualStationsKey,
      settings.manualStations.map((station) => station.toStorage()).toList(),
    );
    await _preferences.setStringList(
      _favoriteCategoriesKey,
      settings.favoriteCategories,
    );
  }
}

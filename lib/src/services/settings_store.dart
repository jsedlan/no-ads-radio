import 'package:shared_preferences/shared_preferences.dart';

import '../models/radio_station.dart';

class AppSettings {
  const AppSettings({
    this.showStationIcon = false,
    this.circleThroughFavorites = true,
    this.countryCodes = const <String>[],
    this.manualStations = const <RadioStation>[],
  });

  final bool showStationIcon;
  final bool circleThroughFavorites;
  final List<String> countryCodes;
  final List<RadioStation> manualStations;

  AppSettings copyWith({
    bool? showStationIcon,
    bool? circleThroughFavorites,
    List<String>? countryCodes,
    List<RadioStation>? manualStations,
  }) {
    return AppSettings(
      showStationIcon: showStationIcon ?? this.showStationIcon,
      circleThroughFavorites:
          circleThroughFavorites ?? this.circleThroughFavorites,
      countryCodes: countryCodes ?? this.countryCodes,
      manualStations: manualStations ?? this.manualStations,
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

  final SharedPreferences _preferences;

  @override
  Future<AppSettings> loadSettings() async {
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
  }
}

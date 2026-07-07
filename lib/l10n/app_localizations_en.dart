// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NoAds Radio';

  @override
  String get language => 'Language';

  @override
  String get languageDescription => 'Choose the language used by the app.';

  @override
  String get systemDefault => 'System default';

  @override
  String get english => 'English';

  @override
  String get serbianLatin => 'Serbian (Latin)';

  @override
  String get theme => 'Theme';

  @override
  String get themeDescription => 'Choose how the app should look.';

  @override
  String get dark => 'Dark';

  @override
  String get light => 'Light';

  @override
  String get chooseCountryTitle => 'Choose your station country';

  @override
  String get chooseCountryDescription =>
      'We use this to choose which stations appear first. The suggestion comes from your device locale and may not match your physical location.';

  @override
  String get moreCountriesLater =>
      'You can add more countries later in Settings.';

  @override
  String get selectCountry => 'Select a country';

  @override
  String get saving => 'Saving...';

  @override
  String get continueLabel => 'Continue';

  @override
  String get filter => 'Filter';

  @override
  String get clearFilter => 'Clear filter';

  @override
  String get offline => 'Offline';

  @override
  String get filterStations => 'Filter stations';

  @override
  String get more => 'More';

  @override
  String get debugView => 'Debug view';

  @override
  String get settings => 'Settings';

  @override
  String get noStationsAvailable => 'No stations available right now.';

  @override
  String get clear => 'Clear';

  @override
  String stationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stations',
      one: '1 station',
    );
    return '$_temp0';
  }

  @override
  String filteredStationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filtered stations',
      one: '1 filtered station',
    );
    return '$_temp0';
  }

  @override
  String get categories => 'Categories';

  @override
  String get recentlyPlayed => 'Recently played';

  @override
  String get noRecentlyPlayed => 'No recently played stations.';

  @override
  String get stationCountries => 'Station countries';

  @override
  String get atLeastOneCountry => 'At least one country must remain selected.';

  @override
  String get diasporaCountryNote =>
      'Diaspora stations are automatically included when you select any former Yugoslav country.';

  @override
  String get selectedCountries => 'Selected countries';

  @override
  String get dragToReorder => 'Drag to reorder';

  @override
  String get addCountry => 'Add country';

  @override
  String get done => 'Done';

  @override
  String get searchCountries => 'Search countries';

  @override
  String get searchCountriesHint => 'Serbia or RS';

  @override
  String get noCountriesAvailable => 'No countries available.';

  @override
  String get stations => 'Stations';

  @override
  String noFavoritesInCategory(Object category) {
    return 'No favorites in $category yet. Save stations from Stations to build this category.';
  }

  @override
  String get nowPlaying => 'Now playing';

  @override
  String get back => 'Back';

  @override
  String get nothingPlaying => 'Nothing is playing.';

  @override
  String get previousFavorite => 'Previous favorite';

  @override
  String get pause => 'Pause';

  @override
  String get play => 'Play';

  @override
  String get nextFavorite => 'Next favorite';

  @override
  String get cast => 'Cast';

  @override
  String get castDevices => 'Cast devices';

  @override
  String castingTo(Object device) {
    return 'Casting to $device';
  }

  @override
  String get disconnect => 'Disconnect';

  @override
  String get searchingCastDevices => 'Searching for Cast devices...';

  @override
  String get noCastDevices =>
      'No Cast devices found. Check that both devices are on the same Wi-Fi network.';

  @override
  String get iosCastPermissionHelp =>
      'On iPhone, allow Local Network access in Settings > Privacy & Security > Local Network > NoAds Radio, then try again.';

  @override
  String get searchAgain => 'Search again';

  @override
  String get castConnectionFailed => 'Could not connect to the Cast device.';

  @override
  String get track => 'Track';

  @override
  String get stream => 'Stream';

  @override
  String get genre => 'Genre';

  @override
  String get location => 'Location';

  @override
  String get tags => 'Tags';

  @override
  String get codec => 'Codec';

  @override
  String get bitrate => 'Bitrate';

  @override
  String get sleepTimer => 'Sleep timer';

  @override
  String sleepTimerWithRemaining(Object remaining) {
    return 'Sleep timer: $remaining';
  }

  @override
  String get off => 'Off';

  @override
  String get custom => 'Custom';

  @override
  String get customSleepTimer => 'Custom sleep timer';

  @override
  String get minutes => 'Minutes';

  @override
  String get enterPositiveNumber => 'Enter a number greater than 0.';

  @override
  String get cancel => 'Cancel';

  @override
  String get start => 'Start';

  @override
  String get internetConnectionLost => 'Internet connection lost';

  @override
  String get streamStoppedResponding => 'Stream stopped responding';

  @override
  String get playbackStalled => 'Playback stalled';

  @override
  String get playbackFailed => 'Playback failed';

  @override
  String get bufferingStream => 'Buffering stream...';

  @override
  String get paused => 'Paused';

  @override
  String durationMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String durationHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get lessThanOneMinute => 'less than 1 min';

  @override
  String get manualStations => 'Manual stations';

  @override
  String get noManualStations => 'No manually added stations.';

  @override
  String get batteryUsage => 'Battery usage';

  @override
  String get batteryUsageDescription =>
      'Set NoAds Radio to Unrestricted in Android settings.';

  @override
  String get showStationIcon => 'Show station icon';

  @override
  String get showStationIconDescription =>
      'Display station artwork in lists and the player bar.';

  @override
  String get autoPlayNextFavorite => 'Auto-play next favorite';

  @override
  String get autoPlayNextFavoriteDescription =>
      'When a stream fails, move to the next favorite and wrap to the start.';

  @override
  String get autoPlayNextFavoriteDisabledDescription =>
      'When a stream fails, move to the next favorite and wrap to the start. Add at least two favorites to enable this option.';

  @override
  String get couldNotOpenAndroidSettings =>
      'Could not open Android app settings on this device.';

  @override
  String get noRecentlyPlayedYet => 'No recently played stations yet.';

  @override
  String get categoriesDescription =>
      'Add as many categories as you like. Only the first 2 will be visible as tabs on the bottom.';

  @override
  String get favorites => 'Favorites';

  @override
  String get newCategory => 'New category';

  @override
  String get removeCategory => 'Remove category';

  @override
  String get addCategory => 'Add category';

  @override
  String get add => 'Add';

  @override
  String get deleteAll => 'Delete all';

  @override
  String get deleteStation => 'Delete station';

  @override
  String get deleteAllManualStationsTitle => 'Delete all manual stations?';

  @override
  String get deleteAllManualStationsDescription =>
      'This removes all stations you added manually.';

  @override
  String get addStation => 'Add station';

  @override
  String get stationName => 'Station name';

  @override
  String get stationNameHint => 'My station';

  @override
  String get streamUrl => 'Stream URL';

  @override
  String get enterStationName => 'Enter a station name.';

  @override
  String get enterValidStreamUrl => 'Enter a valid stream URL.';

  @override
  String get activeSource => 'Active source';

  @override
  String get noSourceLoaded => 'No source loaded';

  @override
  String get stationLoadingLog => 'Station loading log';

  @override
  String get noStationLoadingEvents => 'No station loading events recorded.';

  @override
  String playableStationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count playable stations loaded',
      one: '1 playable station loaded',
    );
    return '$_temp0';
  }

  @override
  String get diaspora => 'Diaspora';

  @override
  String get removeFavorite => 'Remove favorite';

  @override
  String get saveFavorite => 'Save favorite';

  @override
  String get unknown => 'Unknown';
}

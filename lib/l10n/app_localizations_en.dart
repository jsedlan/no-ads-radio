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
  String get serbianCyrillic => 'Serbian (Cyrillic)';

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
  String get about => 'About';

  @override
  String get aboutDescription =>
      'NoAds Radio is a simple radio player for listening to live stations without ad-heavy screens or distracting extras.';

  @override
  String get aboutNoAdsTitle => 'No ad clutter';

  @override
  String get aboutNoAdsDescription =>
      'The app focuses on playback and station browsing instead of banners, pop-ups, or tracking-driven recommendations.';

  @override
  String get aboutStationCatalogTitle => 'Live station catalog';

  @override
  String get aboutStationCatalogDescription =>
      'Stations are loaded from the app catalog and can be filtered by country, added to categories, or added manually.';

  @override
  String get aboutPrivacyTitle => 'Privacy-minded';

  @override
  String get aboutPrivacyDescription =>
      'Settings, categories, manual stations, and recently played stations are stored on this device.';

  @override
  String appVersion(Object version) {
    return 'Version $version';
  }

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
  String noStationsInCategory(Object category) {
    return 'No stations in $category yet. Add stations from Stations to build this category.';
  }

  @override
  String get nowPlaying => 'Now playing';

  @override
  String get back => 'Back';

  @override
  String get nothingPlaying => 'Nothing is playing.';

  @override
  String get previousCategoryStation => 'Previous station in category';

  @override
  String get pause => 'Pause';

  @override
  String get play => 'Play';

  @override
  String get nextCategoryStation => 'Next station in category';

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
  String get autoPlayNextCategoryStation => 'Auto-play next station';

  @override
  String get autoPlayNextCategoryStationDescription =>
      'When a stream fails, move to the next station in its category and wrap to the start.';

  @override
  String get autoPlayNextCategoryStationDisabledDescription =>
      'When a stream fails, move to the next station in its category and wrap to the start. Add at least two stations to a category to enable this option.';

  @override
  String get couldNotOpenAndroidSettings =>
      'Could not open Android app settings on this device.';

  @override
  String get noRecentlyPlayedYet => 'No recently played stations yet.';

  @override
  String get categoriesDescription =>
      'Add as many categories as you like. The Categories tab opens the last category you used.';

  @override
  String get savedCategory => 'Saved';

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
  String get diaspora => 'Diaspora';

  @override
  String get removeFromCategory => 'Remove from category';

  @override
  String get addToCategory => 'Add to category';

  @override
  String get unknown => 'Unknown';

  @override
  String get stationTag743d597bbf => 'abc noticias';

  @override
  String get stationTagd22aa9e385 => 'adult contemporary';

  @override
  String get stationTag4eb9485df2 => 'adult hits';

  @override
  String get stationTag757216b974 => 'adult pop';

  @override
  String get stationTagce0bf8ffc6 => 'african hip hop';

  @override
  String get stationTag8a78fd32f3 => 'afropop';

  @override
  String get stationTag816d63e63c => 'alternative';

  @override
  String get stationTag125656fd8e => 'alternative country';

  @override
  String get stationTag5caa40d242 => 'alternative rock';

  @override
  String get stationTag9f8bc859e5 => 'ambient';

  @override
  String get stationTag11a3e059c6 => 'anime';

  @override
  String get stationTag1187c0b5e4 => 'argentina';

  @override
  String get stationTagbc3aa419b3 => 'audiobooks';

  @override
  String get stationTagd7a9347927 => 'augsburg';

  @override
  String get stationTagf0741425e4 => 'avant-garde';

  @override
  String get stationTag365f20c1d5 => 'balade';

  @override
  String get stationTag05f153a6d9 => 'beautiful music';

  @override
  String get stationTag086547e7de => 'big band';

  @override
  String get stationTag2e00f41599 => 'blues';

  @override
  String get stationTagf4e6d8a342 => 'blues rock';

  @override
  String get stationTagb7e0f1cd5d => 'bollywood';

  @override
  String get stationTag0ef0580339 => 'bossa nova';

  @override
  String get stationTag942f10e1d6 => 'buenos aires';

  @override
  String get stationTag11a783a9d6 => 'business news';

  @override
  String get stationTag75fad5e6ba => 'business programs';

  @override
  String get stationTag72af4739cc => 'chanson';

  @override
  String get stationTag3c1836f3a6 => 'charts';

  @override
  String get stationTag4e18273733 => 'chill';

  @override
  String get stationTagab1d69daba => 'chill house';

  @override
  String get stationTag46a59517d4 => 'chillout';

  @override
  String get stationTagc8d73989e5 => 'choral';

  @override
  String get stationTag2314b2e3a4 => 'christian';

  @override
  String get stationTag56d7b69b1b => 'christian music';

  @override
  String get stationTag46e505c983 => 'christmas';

  @override
  String get stationTag290b75188d => 'classic';

  @override
  String get stationTag6af6b14ed4 => 'classic blues';

  @override
  String get stationTag28c76c07d1 => 'classic country';

  @override
  String get stationTagda3dbd8402 => 'classic hits';

  @override
  String get stationTag066705657d => 'classic jazz';

  @override
  String get stationTage09e25c16c => 'classic rock';

  @override
  String get stationTag4a19573b7e => 'classical';

  @override
  String get stationTag43021a2092 => 'classical music';

  @override
  String get stationTag9273bf33ff => 'classics';

  @override
  String get stationTage9933e8a75 => 'club';

  @override
  String get stationTaga8c0c2e0be => 'club dance';

  @override
  String get stationTag8d92575952 => 'club music';

  @override
  String get stationTag3e56e6a43d => 'comedy';

  @override
  String get stationTage6aed0bced => 'community radio';

  @override
  String get stationTag42dc7e4f3f => 'conservative';

  @override
  String get stationTag911e56c69e => 'conspiracies';

  @override
  String get stationTagb68c19108a => 'conspiracy theories';

  @override
  String get stationTag49eafe93ae => 'contemporary';

  @override
  String get stationTagdda0f9acde => 'contemporary christian';

  @override
  String get stationTag13fd6746fe => 'contemporary country';

  @override
  String get stationTag40eb1a9b87 => 'contemporary hits radio';

  @override
  String get stationTagc567a18aa0 => 'contemporary jazz';

  @override
  String get stationTag8e68b3e5af => 'country';

  @override
  String get stationTag141546aac4 => 'country blues';

  @override
  String get stationTagd5a23debab => 'country music';

  @override
  String get stationTag5c685d4499 => 'country pop';

  @override
  String get stationTag83ac283371 => 'country rock';

  @override
  String get stationTag5f58355136 => 'cultural';

  @override
  String get stationTag7820e1d879 => 'cultural news';

  @override
  String get stationTag8f2e7cd784 => 'culture';

  @override
  String get stationTag74b518ed55 => 'dance';

  @override
  String get stationTage8de1377be => 'dancehall';

  @override
  String get stationTagd8362a14e6 => 'deutsch';

  @override
  String get stationTag95c152a176 => 'Dečija';

  @override
  String get stationTag9a1c2a67fc => 'disco';

  @override
  String get stationTag05d80cd9c4 => 'dj mixes';

  @override
  String get stationTag49c149dc66 => 'dj remix';

  @override
  String get stationTag91dbf3c2a7 => 'dj sets';

  @override
  String get stationTagf924b9625d => 'downtempo';

  @override
  String get stationTag63b1298947 => 'drama';

  @override
  String get stationTage69a4f2256 => 'Duhovna';

  @override
  String get stationTag52edaa4e68 => 'easy listening';

  @override
  String get stationTage3164293ed => 'eclectic';

  @override
  String get stationTagb4d21f8747 => 'electro';

  @override
  String get stationTag3797c42f9d => 'electronic';

  @override
  String get stationTag043f28f4b5 => 'electronic dance music';

  @override
  String get stationTag4dc773db68 => 'electronica';

  @override
  String get stationTagc32b941d4e => 'entertainment';

  @override
  String get stationTag8b47d2a821 => 'Etno';

  @override
  String get stationTag30e382c6b8 => 'eurodance';

  @override
  String get stationTag59acab5d0a => 'Evergreen';

  @override
  String get stationTag204994198c => 'evergreens';

  @override
  String get stationTag2216470a6a => 'experimental';

  @override
  String get stationTag2d02ecf89a => 'folk';

  @override
  String get stationTagd2330d0952 => 'free jazz';

  @override
  String get stationTag30ec1e5ee8 => 'funk';

  @override
  String get stationTagdbbbceb206 => 'funky';

  @override
  String get stationTag4c2f65997d => 'garage';

  @override
  String get stationTagdfe2db7497 => 'general';

  @override
  String get stationTag5eaf52a9b8 => 'global radio';

  @override
  String get stationTagcf75b6e07e => 'gospel';

  @override
  String get stationTagb9b7a52438 => 'gospel music';

  @override
  String get stationTag6b477d6b44 => 'gusle';

  @override
  String get stationTag21d286310f => 'gym';

  @override
  String get stationTagdd1b58d84e => 'hard bop';

  @override
  String get stationTag1dad8d9def => 'hard rock';

  @override
  String get stationTaga2a76210fb => 'hard techno';

  @override
  String get stationTag40e6f3039d => 'heavy metal';

  @override
  String get stationTag1ab40b9589 => 'hip hop';

  @override
  String get stationTagd45000b24b => 'hip-hop';

  @override
  String get stationTagac806dd8ce => 'hiphop';

  @override
  String get stationTag80d6b4b236 => 'hitovi';

  @override
  String get stationTagc748c763b9 => 'hits';

  @override
  String get stationTag1b602c45be => 'holiday';

  @override
  String get stationTag5be93480bd => 'house';

  @override
  String get stationTagf6f30f107a => 'humor';

  @override
  String get stationTag5e92ba075a => 'humour';

  @override
  String get stationTagd085829c2c => 'hymns';

  @override
  String get stationTage33fc333d4 => 'indie';

  @override
  String get stationTag93604d928b => 'indie pop';

  @override
  String get stationTag0c7bc23252 => 'indie rock';

  @override
  String get stationTag59bd0a3ff4 => 'info';

  @override
  String get stationTag83dd9d6af4 => 'information';

  @override
  String get stationTag48d513fd88 => 'infotainment';

  @override
  String get stationTag070db54a6f => 'Instrumental';

  @override
  String get stationTag4d0fb475b2 => 'internet';

  @override
  String get stationTag25c4ae7fd8 => 'internet radio';

  @override
  String get stationTag0313752b11 => 'internet-radio';

  @override
  String get stationTagdaf14c7984 => 'italian';

  @override
  String get stationTag337cf35e7a => 'italian pop';

  @override
  String get stationTag7b8af9235d => 'italo';

  @override
  String get stationTag04f65fbe0d => 'italo dance';

  @override
  String get stationTag9dfb478f68 => 'italo disco';

  @override
  String get stationTag71fddd2ecc => 'Izvorna';

  @override
  String get stationTag6abc743bbd => 'jazz';

  @override
  String get stationTag1aee2a66e1 => 'jazzy';

  @override
  String get stationTag5212351459 => 'jpop';

  @override
  String get stationTagb37f602962 => 'Klasična';

  @override
  String get stationTag382a11c991 => 'Krajiška';

  @override
  String get stationTag6504358a41 => 'kultur';

  @override
  String get stationTag9706e2b789 => 'Lagana';

  @override
  String get stationTage2d35ad940 => 'latin';

  @override
  String get stationTagd87f9ff79e => 'latin music';

  @override
  String get stationTag045615950e => 'latin pop';

  @override
  String get stationTag9f2222b7fb => 'latino';

  @override
  String get stationTag1e2f761d51 => 'lifestyle';

  @override
  String get stationTag98aadb3708 => 'live';

  @override
  String get stationTag14039d1152 => 'live sports';

  @override
  String get stationTag939bb46a04 => 'local';

  @override
  String get stationTag43a88022d6 => 'local music';

  @override
  String get stationTag442ac2cf88 => 'local news';

  @override
  String get stationTagf06015be10 => 'local radio';

  @override
  String get stationTagf336da1d34 => 'love songs';

  @override
  String get stationTage3493be66f => 'mainstream';

  @override
  String get stationTag9d983dd224 => 'mainstream jazz';

  @override
  String get stationTag4963bb0591 => 'metal';

  @override
  String get stationTagff8b611a89 => 'mexican music';

  @override
  String get stationTagb0264c19da => 'middle eastern music';

  @override
  String get stationTag5c4821749c => 'minimal';

  @override
  String get stationTag629ead9591 => 'minimal techno';

  @override
  String get stationTag38743fbb44 => 'Mix';

  @override
  String get stationTagb09be85d51 => 'modern';

  @override
  String get stationTagc670bbfd94 => 'modern rock';

  @override
  String get stationTag3a01be1724 => 'music';

  @override
  String get stationTagfe0feb3c23 => 'musical';

  @override
  String get stationTag489d08ab84 => 'muzika za decu';

  @override
  String get stationTag71c1d51400 => 'Narodna';

  @override
  String get stationTag996676018c => 'narodna - etno';

  @override
  String get stationTagba1d431793 => 'national';

  @override
  String get stationTag6d150cec97 => 'new wave';

  @override
  String get stationTag3c6bdcddc9 => 'news';

  @override
  String get stationTag54ac9a2e58 => 'news radio';

  @override
  String get stationTagca29a260a8 => 'news talk';

  @override
  String get stationTag81f7a3d9ae => 'non-commercial';

  @override
  String get stationTaga6b8fe2ef4 => 'non-stop music';

  @override
  String get stationTaga67edc88d9 => 'nostalgia';

  @override
  String get stationTag869f15a237 => 'noticias';

  @override
  String get stationTag5d6687996d => 'oldies';

  @override
  String get stationTag2dbc2fd235 => 'online';

  @override
  String get stationTag6feda84dcc => 'opera';

  @override
  String get stationTag8341873a88 => 'opus';

  @override
  String get stationTag03c8ed27df => 'orchestral';

  @override
  String get stationTag84beb18831 => 'party';

  @override
  String get stationTag3f4667905c => 'party hits';

  @override
  String get stationTagee848a3b5b => 'police';

  @override
  String get stationTagae4fd29aa1 => 'political talk';

  @override
  String get stationTag4c5fd84e89 => 'politics';

  @override
  String get stationTag4f197c99a7 => 'pop';

  @override
  String get stationTag122fb23bc6 => 'pop dance';

  @override
  String get stationTag0be9a78da5 => 'pop latino';

  @override
  String get stationTag9eda0e7aa9 => 'pop music';

  @override
  String get stationTagbb2c038983 => 'pop rock';

  @override
  String get stationTag74c72544e0 => 'pop-rock';

  @override
  String get stationTag136dfa5b33 => 'progressive house';

  @override
  String get stationTaga2f77c10a5 => 'public radio';

  @override
  String get stationTag71d689362a => 'public service';

  @override
  String get stationTag5940e3137d => 'punk';

  @override
  String get stationTagcb0cde801b => 'r&b';

  @override
  String get stationTag6e2a486fe3 => 'r&b/urban';

  @override
  String get stationTag5c4a513dbf => 'r\'n\'b';

  @override
  String get stationTagd432c3525b => 'radio';

  @override
  String get stationTag8390ac37de => 'radio online';

  @override
  String get stationTag1bf1b43494 => 'radiorama';

  @override
  String get stationTag51c4ccfd6b => 'rap';

  @override
  String get stationTag914bdbfd48 => 'rap hiphop rnb';

  @override
  String get stationTag0615591f84 => 'reggae';

  @override
  String get stationTag65013ec4e5 => 'reggaeton';

  @override
  String get stationTag197caeb8b5 => 'regional';

  @override
  String get stationTaga6d888f965 => 'regional radio';

  @override
  String get stationTag63bb094ca4 => 'relax';

  @override
  String get stationTagb912a11ddd => 'relaxation';

  @override
  String get stationTag6e93871ac7 => 'relaxing';

  @override
  String get stationTagbbde763cc0 => 'remix';

  @override
  String get stationTag4c742a2314 => 'retro';

  @override
  String get stationTagf2792fa06d => 'rnb';

  @override
  String get stationTag38464bf083 => 'rock';

  @override
  String get stationTag17c8217f23 => 'rock\'n\'roll';

  @override
  String get stationTag5b9265ef9f => 'rockabilly';

  @override
  String get stationTag346f5986a9 => 'romantic';

  @override
  String get stationTag17d7cc4d9a => 'russian pop';

  @override
  String get stationTagb36ad30593 => 'samba';

  @override
  String get stationTag64fd638390 => 'seasonal';

  @override
  String get stationTagf81ac68eee => 'serbian music';

  @override
  String get stationTag3aa9adbbb4 => 'ska';

  @override
  String get stationTagc3ca5f7873 => 'sleep';

  @override
  String get stationTag6c021501ca => 'slow rock';

  @override
  String get stationTagc0c6d93fe3 => 'soft music';

  @override
  String get stationTagc5c1fe26d5 => 'soft pop';

  @override
  String get stationTag3af8919a33 => 'soft rock';

  @override
  String get stationTag0867322e7c => 'soul';

  @override
  String get stationTag3e4ef17728 => 'sounds of nature';

  @override
  String get stationTagf3690b9c34 => 'speech';

  @override
  String get stationTag8ab6a8a0cf => 'sport';

  @override
  String get stationTag150a8af76a => 'sports';

  @override
  String get stationTag7899b8b3d9 => 'sports news';

  @override
  String get stationTag4c5218bd29 => 'sports talk';

  @override
  String get stationTag0b1ecf7216 => 'Starogradska';

  @override
  String get stationTag723f4e1ce3 => 'swing';

  @override
  String get stationTage55e91b2cc => 'talk';

  @override
  String get stationTag5108191aa3 => 'talk radio';

  @override
  String get stationTage405fa83fe => 'techno';

  @override
  String get stationTag27d50b6f9a => 'top charts';

  @override
  String get stationTag795bbda660 => 'top hits';

  @override
  String get stationTag7f1345c21a => 'trance';

  @override
  String get stationTage6d307367a => 'trap';

  @override
  String get stationTagad3d12ae13 => 'trip hop';

  @override
  String get stationTagba7a82a981 => 'urban';

  @override
  String get stationTag09cdd5dd4b => 'urbano';

  @override
  String get stationTag84942e2fd1 => 'uživo';

  @override
  String get stationTag75b4d7d721 => 'varied';

  @override
  String get stationTag21e7a8ba50 => 'variety';

  @override
  String get stationTage609aae6c8 => 'Vesti';

  @override
  String get stationTag0be9098c7e => 'vintage';

  @override
  String get stationTagbf6e51973d => 'vinyl';

  @override
  String get stationTag91b7e90635 => 'Vlaška';

  @override
  String get stationTag7c211433f0 => 'world';

  @override
  String get stationTag3c405b7c0e => 'world music';

  @override
  String get stationTag7b0ac581fe => 'world news';

  @override
  String get stationTagf9925d1162 => 'youth';

  @override
  String get stationTag9de3eede6a => 'Zabavna';

  @override
  String get stationTaga712aa0f9d => 'аудиокниги';

  @override
  String get stationTagd341e6e288 => 'детям';

  @override
  String get stationTag6e0dc4349c => 'литература';

  @override
  String get stationTagd42e4f9f15 => 'политика';

  @override
  String get stationTag2ca9d5c635 => 'поп';

  @override
  String get stationTagb5cbcd9cbc => 'рок';

  @override
  String get stationTagb5f9fa4f69 => 'этно';
}

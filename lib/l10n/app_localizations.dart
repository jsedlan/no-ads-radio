import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sr'),
    Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'NoAds Radio'**
  String get appTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the language used by the app.'**
  String get languageDescription;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @serbianCyrillic.
  ///
  /// In en, this message translates to:
  /// **'Serbian (Cyrillic)'**
  String get serbianCyrillic;

  /// No description provided for @serbianLatin.
  ///
  /// In en, this message translates to:
  /// **'Serbian (Latin)'**
  String get serbianLatin;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose how the app should look.'**
  String get themeDescription;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @chooseCountryTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your station country'**
  String get chooseCountryTitle;

  /// No description provided for @chooseCountryDescription.
  ///
  /// In en, this message translates to:
  /// **'We use this to choose which stations appear first. The suggestion comes from your device locale and may not match your physical location.'**
  String get chooseCountryDescription;

  /// No description provided for @moreCountriesLater.
  ///
  /// In en, this message translates to:
  /// **'You can add more countries later in Settings.'**
  String get moreCountriesLater;

  /// No description provided for @selectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select a country'**
  String get selectCountry;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @clearFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear filter'**
  String get clearFilter;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @filterStations.
  ///
  /// In en, this message translates to:
  /// **'Filter stations'**
  String get filterStations;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'NoAds Radio is a simple radio player for listening to live stations without ad-heavy screens or distracting extras.'**
  String get aboutDescription;

  /// No description provided for @aboutNoAdsTitle.
  ///
  /// In en, this message translates to:
  /// **'No ad clutter'**
  String get aboutNoAdsTitle;

  /// No description provided for @aboutNoAdsDescription.
  ///
  /// In en, this message translates to:
  /// **'The app focuses on playback and station browsing instead of banners, pop-ups, or tracking-driven recommendations.'**
  String get aboutNoAdsDescription;

  /// No description provided for @aboutStationCatalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Live station catalog'**
  String get aboutStationCatalogTitle;

  /// No description provided for @aboutStationCatalogDescription.
  ///
  /// In en, this message translates to:
  /// **'Stations are loaded from the app catalog and can be filtered by country, saved as favorites, or added manually.'**
  String get aboutStationCatalogDescription;

  /// No description provided for @aboutPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy-minded'**
  String get aboutPrivacyTitle;

  /// No description provided for @aboutPrivacyDescription.
  ///
  /// In en, this message translates to:
  /// **'Settings, favorites, manual stations, and recently played stations are stored on this device.'**
  String get aboutPrivacyDescription;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersion(Object version);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @noStationsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No stations available right now.'**
  String get noStationsAvailable;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @stationCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 station} other{{count} stations}}'**
  String stationCount(int count);

  /// No description provided for @filteredStationCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 filtered station} other{{count} filtered stations}}'**
  String filteredStationCount(int count);

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @recentlyPlayed.
  ///
  /// In en, this message translates to:
  /// **'Recently played'**
  String get recentlyPlayed;

  /// No description provided for @noRecentlyPlayed.
  ///
  /// In en, this message translates to:
  /// **'No recently played stations.'**
  String get noRecentlyPlayed;

  /// No description provided for @stationCountries.
  ///
  /// In en, this message translates to:
  /// **'Station countries'**
  String get stationCountries;

  /// No description provided for @atLeastOneCountry.
  ///
  /// In en, this message translates to:
  /// **'At least one country must remain selected.'**
  String get atLeastOneCountry;

  /// No description provided for @diasporaCountryNote.
  ///
  /// In en, this message translates to:
  /// **'Diaspora stations are automatically included when you select any former Yugoslav country.'**
  String get diasporaCountryNote;

  /// No description provided for @selectedCountries.
  ///
  /// In en, this message translates to:
  /// **'Selected countries'**
  String get selectedCountries;

  /// No description provided for @dragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get dragToReorder;

  /// No description provided for @addCountry.
  ///
  /// In en, this message translates to:
  /// **'Add country'**
  String get addCountry;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @searchCountries.
  ///
  /// In en, this message translates to:
  /// **'Search countries'**
  String get searchCountries;

  /// No description provided for @searchCountriesHint.
  ///
  /// In en, this message translates to:
  /// **'Serbia or RS'**
  String get searchCountriesHint;

  /// No description provided for @noCountriesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No countries available.'**
  String get noCountriesAvailable;

  /// No description provided for @stations.
  ///
  /// In en, this message translates to:
  /// **'Stations'**
  String get stations;

  /// No description provided for @noFavoritesInCategory.
  ///
  /// In en, this message translates to:
  /// **'No favorites in {category} yet. Save stations from Stations to build this category.'**
  String noFavoritesInCategory(Object category);

  /// No description provided for @nowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Now playing'**
  String get nowPlaying;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @nothingPlaying.
  ///
  /// In en, this message translates to:
  /// **'Nothing is playing.'**
  String get nothingPlaying;

  /// No description provided for @previousFavorite.
  ///
  /// In en, this message translates to:
  /// **'Previous favorite'**
  String get previousFavorite;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @nextFavorite.
  ///
  /// In en, this message translates to:
  /// **'Next favorite'**
  String get nextFavorite;

  /// No description provided for @cast.
  ///
  /// In en, this message translates to:
  /// **'Cast'**
  String get cast;

  /// No description provided for @castDevices.
  ///
  /// In en, this message translates to:
  /// **'Cast devices'**
  String get castDevices;

  /// No description provided for @castingTo.
  ///
  /// In en, this message translates to:
  /// **'Casting to {device}'**
  String castingTo(Object device);

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @searchingCastDevices.
  ///
  /// In en, this message translates to:
  /// **'Searching for Cast devices...'**
  String get searchingCastDevices;

  /// No description provided for @noCastDevices.
  ///
  /// In en, this message translates to:
  /// **'No Cast devices found. Check that both devices are on the same Wi-Fi network.'**
  String get noCastDevices;

  /// No description provided for @iosCastPermissionHelp.
  ///
  /// In en, this message translates to:
  /// **'On iPhone, allow Local Network access in Settings > Privacy & Security > Local Network > NoAds Radio, then try again.'**
  String get iosCastPermissionHelp;

  /// No description provided for @searchAgain.
  ///
  /// In en, this message translates to:
  /// **'Search again'**
  String get searchAgain;

  /// No description provided for @castConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the Cast device.'**
  String get castConnectionFailed;

  /// No description provided for @track.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get track;

  /// No description provided for @stream.
  ///
  /// In en, this message translates to:
  /// **'Stream'**
  String get stream;

  /// No description provided for @genre.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get genre;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @codec.
  ///
  /// In en, this message translates to:
  /// **'Codec'**
  String get codec;

  /// No description provided for @bitrate.
  ///
  /// In en, this message translates to:
  /// **'Bitrate'**
  String get bitrate;

  /// No description provided for @sleepTimer.
  ///
  /// In en, this message translates to:
  /// **'Sleep timer'**
  String get sleepTimer;

  /// No description provided for @sleepTimerWithRemaining.
  ///
  /// In en, this message translates to:
  /// **'Sleep timer: {remaining}'**
  String sleepTimerWithRemaining(Object remaining);

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @customSleepTimer.
  ///
  /// In en, this message translates to:
  /// **'Custom sleep timer'**
  String get customSleepTimer;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// No description provided for @enterPositiveNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a number greater than 0.'**
  String get enterPositiveNumber;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @internetConnectionLost.
  ///
  /// In en, this message translates to:
  /// **'Internet connection lost'**
  String get internetConnectionLost;

  /// No description provided for @streamStoppedResponding.
  ///
  /// In en, this message translates to:
  /// **'Stream stopped responding'**
  String get streamStoppedResponding;

  /// No description provided for @playbackStalled.
  ///
  /// In en, this message translates to:
  /// **'Playback stalled'**
  String get playbackStalled;

  /// No description provided for @playbackFailed.
  ///
  /// In en, this message translates to:
  /// **'Playback failed'**
  String get playbackFailed;

  /// No description provided for @bufferingStream.
  ///
  /// In en, this message translates to:
  /// **'Buffering stream...'**
  String get bufferingStream;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute} other{{count} minutes}}'**
  String durationMinutes(int count);

  /// No description provided for @durationHours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour} other{{count} hours}}'**
  String durationHours(int count);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes} min'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @lessThanOneMinute.
  ///
  /// In en, this message translates to:
  /// **'less than 1 min'**
  String get lessThanOneMinute;

  /// No description provided for @manualStations.
  ///
  /// In en, this message translates to:
  /// **'Manual stations'**
  String get manualStations;

  /// No description provided for @noManualStations.
  ///
  /// In en, this message translates to:
  /// **'No manually added stations.'**
  String get noManualStations;

  /// No description provided for @batteryUsage.
  ///
  /// In en, this message translates to:
  /// **'Battery usage'**
  String get batteryUsage;

  /// No description provided for @batteryUsageDescription.
  ///
  /// In en, this message translates to:
  /// **'Set NoAds Radio to Unrestricted in Android settings.'**
  String get batteryUsageDescription;

  /// No description provided for @showStationIcon.
  ///
  /// In en, this message translates to:
  /// **'Show station icon'**
  String get showStationIcon;

  /// No description provided for @showStationIconDescription.
  ///
  /// In en, this message translates to:
  /// **'Display station artwork in lists and the player bar.'**
  String get showStationIconDescription;

  /// No description provided for @autoPlayNextFavorite.
  ///
  /// In en, this message translates to:
  /// **'Auto-play next favorite'**
  String get autoPlayNextFavorite;

  /// No description provided for @autoPlayNextFavoriteDescription.
  ///
  /// In en, this message translates to:
  /// **'When a stream fails, move to the next favorite and wrap to the start.'**
  String get autoPlayNextFavoriteDescription;

  /// No description provided for @autoPlayNextFavoriteDisabledDescription.
  ///
  /// In en, this message translates to:
  /// **'When a stream fails, move to the next favorite and wrap to the start. Add at least two favorites to enable this option.'**
  String get autoPlayNextFavoriteDisabledDescription;

  /// No description provided for @couldNotOpenAndroidSettings.
  ///
  /// In en, this message translates to:
  /// **'Could not open Android app settings on this device.'**
  String get couldNotOpenAndroidSettings;

  /// No description provided for @noRecentlyPlayedYet.
  ///
  /// In en, this message translates to:
  /// **'No recently played stations yet.'**
  String get noRecentlyPlayedYet;

  /// No description provided for @categoriesDescription.
  ///
  /// In en, this message translates to:
  /// **'Add as many categories as you like. Only the first 2 will be visible as tabs on the bottom.'**
  String get categoriesDescription;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @newCategory.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get newCategory;

  /// No description provided for @removeCategory.
  ///
  /// In en, this message translates to:
  /// **'Remove category'**
  String get removeCategory;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategory;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get deleteAll;

  /// No description provided for @deleteStation.
  ///
  /// In en, this message translates to:
  /// **'Delete station'**
  String get deleteStation;

  /// No description provided for @deleteAllManualStationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all manual stations?'**
  String get deleteAllManualStationsTitle;

  /// No description provided for @deleteAllManualStationsDescription.
  ///
  /// In en, this message translates to:
  /// **'This removes all stations you added manually.'**
  String get deleteAllManualStationsDescription;

  /// No description provided for @addStation.
  ///
  /// In en, this message translates to:
  /// **'Add station'**
  String get addStation;

  /// No description provided for @stationName.
  ///
  /// In en, this message translates to:
  /// **'Station name'**
  String get stationName;

  /// No description provided for @stationNameHint.
  ///
  /// In en, this message translates to:
  /// **'My station'**
  String get stationNameHint;

  /// No description provided for @streamUrl.
  ///
  /// In en, this message translates to:
  /// **'Stream URL'**
  String get streamUrl;

  /// No description provided for @enterStationName.
  ///
  /// In en, this message translates to:
  /// **'Enter a station name.'**
  String get enterStationName;

  /// No description provided for @enterValidStreamUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid stream URL.'**
  String get enterValidStreamUrl;

  /// No description provided for @diaspora.
  ///
  /// In en, this message translates to:
  /// **'Diaspora'**
  String get diaspora;

  /// No description provided for @removeFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove favorite'**
  String get removeFavorite;

  /// No description provided for @saveFavorite.
  ///
  /// In en, this message translates to:
  /// **'Save favorite'**
  String get saveFavorite;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @stationTag743d597bbf.
  ///
  /// In en, this message translates to:
  /// **'abc noticias'**
  String get stationTag743d597bbf;

  /// No description provided for @stationTagd22aa9e385.
  ///
  /// In en, this message translates to:
  /// **'adult contemporary'**
  String get stationTagd22aa9e385;

  /// No description provided for @stationTag4eb9485df2.
  ///
  /// In en, this message translates to:
  /// **'adult hits'**
  String get stationTag4eb9485df2;

  /// No description provided for @stationTag757216b974.
  ///
  /// In en, this message translates to:
  /// **'adult pop'**
  String get stationTag757216b974;

  /// No description provided for @stationTagce0bf8ffc6.
  ///
  /// In en, this message translates to:
  /// **'african hip hop'**
  String get stationTagce0bf8ffc6;

  /// No description provided for @stationTag8a78fd32f3.
  ///
  /// In en, this message translates to:
  /// **'afropop'**
  String get stationTag8a78fd32f3;

  /// No description provided for @stationTag816d63e63c.
  ///
  /// In en, this message translates to:
  /// **'alternative'**
  String get stationTag816d63e63c;

  /// No description provided for @stationTag125656fd8e.
  ///
  /// In en, this message translates to:
  /// **'alternative country'**
  String get stationTag125656fd8e;

  /// No description provided for @stationTag5caa40d242.
  ///
  /// In en, this message translates to:
  /// **'alternative rock'**
  String get stationTag5caa40d242;

  /// No description provided for @stationTag9f8bc859e5.
  ///
  /// In en, this message translates to:
  /// **'ambient'**
  String get stationTag9f8bc859e5;

  /// No description provided for @stationTag11a3e059c6.
  ///
  /// In en, this message translates to:
  /// **'anime'**
  String get stationTag11a3e059c6;

  /// No description provided for @stationTag1187c0b5e4.
  ///
  /// In en, this message translates to:
  /// **'argentina'**
  String get stationTag1187c0b5e4;

  /// No description provided for @stationTagbc3aa419b3.
  ///
  /// In en, this message translates to:
  /// **'audiobooks'**
  String get stationTagbc3aa419b3;

  /// No description provided for @stationTagd7a9347927.
  ///
  /// In en, this message translates to:
  /// **'augsburg'**
  String get stationTagd7a9347927;

  /// No description provided for @stationTagf0741425e4.
  ///
  /// In en, this message translates to:
  /// **'avant-garde'**
  String get stationTagf0741425e4;

  /// No description provided for @stationTag365f20c1d5.
  ///
  /// In en, this message translates to:
  /// **'balade'**
  String get stationTag365f20c1d5;

  /// No description provided for @stationTag05f153a6d9.
  ///
  /// In en, this message translates to:
  /// **'beautiful music'**
  String get stationTag05f153a6d9;

  /// No description provided for @stationTag086547e7de.
  ///
  /// In en, this message translates to:
  /// **'big band'**
  String get stationTag086547e7de;

  /// No description provided for @stationTag2e00f41599.
  ///
  /// In en, this message translates to:
  /// **'blues'**
  String get stationTag2e00f41599;

  /// No description provided for @stationTagf4e6d8a342.
  ///
  /// In en, this message translates to:
  /// **'blues rock'**
  String get stationTagf4e6d8a342;

  /// No description provided for @stationTagb7e0f1cd5d.
  ///
  /// In en, this message translates to:
  /// **'bollywood'**
  String get stationTagb7e0f1cd5d;

  /// No description provided for @stationTag0ef0580339.
  ///
  /// In en, this message translates to:
  /// **'bossa nova'**
  String get stationTag0ef0580339;

  /// No description provided for @stationTag942f10e1d6.
  ///
  /// In en, this message translates to:
  /// **'buenos aires'**
  String get stationTag942f10e1d6;

  /// No description provided for @stationTag11a783a9d6.
  ///
  /// In en, this message translates to:
  /// **'business news'**
  String get stationTag11a783a9d6;

  /// No description provided for @stationTag75fad5e6ba.
  ///
  /// In en, this message translates to:
  /// **'business programs'**
  String get stationTag75fad5e6ba;

  /// No description provided for @stationTag72af4739cc.
  ///
  /// In en, this message translates to:
  /// **'chanson'**
  String get stationTag72af4739cc;

  /// No description provided for @stationTag3c1836f3a6.
  ///
  /// In en, this message translates to:
  /// **'charts'**
  String get stationTag3c1836f3a6;

  /// No description provided for @stationTag4e18273733.
  ///
  /// In en, this message translates to:
  /// **'chill'**
  String get stationTag4e18273733;

  /// No description provided for @stationTagab1d69daba.
  ///
  /// In en, this message translates to:
  /// **'chill house'**
  String get stationTagab1d69daba;

  /// No description provided for @stationTag46a59517d4.
  ///
  /// In en, this message translates to:
  /// **'chillout'**
  String get stationTag46a59517d4;

  /// No description provided for @stationTagc8d73989e5.
  ///
  /// In en, this message translates to:
  /// **'choral'**
  String get stationTagc8d73989e5;

  /// No description provided for @stationTag2314b2e3a4.
  ///
  /// In en, this message translates to:
  /// **'christian'**
  String get stationTag2314b2e3a4;

  /// No description provided for @stationTag56d7b69b1b.
  ///
  /// In en, this message translates to:
  /// **'christian music'**
  String get stationTag56d7b69b1b;

  /// No description provided for @stationTag46e505c983.
  ///
  /// In en, this message translates to:
  /// **'christmas'**
  String get stationTag46e505c983;

  /// No description provided for @stationTag290b75188d.
  ///
  /// In en, this message translates to:
  /// **'classic'**
  String get stationTag290b75188d;

  /// No description provided for @stationTag6af6b14ed4.
  ///
  /// In en, this message translates to:
  /// **'classic blues'**
  String get stationTag6af6b14ed4;

  /// No description provided for @stationTag28c76c07d1.
  ///
  /// In en, this message translates to:
  /// **'classic country'**
  String get stationTag28c76c07d1;

  /// No description provided for @stationTagda3dbd8402.
  ///
  /// In en, this message translates to:
  /// **'classic hits'**
  String get stationTagda3dbd8402;

  /// No description provided for @stationTag066705657d.
  ///
  /// In en, this message translates to:
  /// **'classic jazz'**
  String get stationTag066705657d;

  /// No description provided for @stationTage09e25c16c.
  ///
  /// In en, this message translates to:
  /// **'classic rock'**
  String get stationTage09e25c16c;

  /// No description provided for @stationTag4a19573b7e.
  ///
  /// In en, this message translates to:
  /// **'classical'**
  String get stationTag4a19573b7e;

  /// No description provided for @stationTag43021a2092.
  ///
  /// In en, this message translates to:
  /// **'classical music'**
  String get stationTag43021a2092;

  /// No description provided for @stationTag9273bf33ff.
  ///
  /// In en, this message translates to:
  /// **'classics'**
  String get stationTag9273bf33ff;

  /// No description provided for @stationTage9933e8a75.
  ///
  /// In en, this message translates to:
  /// **'club'**
  String get stationTage9933e8a75;

  /// No description provided for @stationTaga8c0c2e0be.
  ///
  /// In en, this message translates to:
  /// **'club dance'**
  String get stationTaga8c0c2e0be;

  /// No description provided for @stationTag8d92575952.
  ///
  /// In en, this message translates to:
  /// **'club music'**
  String get stationTag8d92575952;

  /// No description provided for @stationTag3e56e6a43d.
  ///
  /// In en, this message translates to:
  /// **'comedy'**
  String get stationTag3e56e6a43d;

  /// No description provided for @stationTage6aed0bced.
  ///
  /// In en, this message translates to:
  /// **'community radio'**
  String get stationTage6aed0bced;

  /// No description provided for @stationTag42dc7e4f3f.
  ///
  /// In en, this message translates to:
  /// **'conservative'**
  String get stationTag42dc7e4f3f;

  /// No description provided for @stationTag911e56c69e.
  ///
  /// In en, this message translates to:
  /// **'conspiracies'**
  String get stationTag911e56c69e;

  /// No description provided for @stationTagb68c19108a.
  ///
  /// In en, this message translates to:
  /// **'conspiracy theories'**
  String get stationTagb68c19108a;

  /// No description provided for @stationTag49eafe93ae.
  ///
  /// In en, this message translates to:
  /// **'contemporary'**
  String get stationTag49eafe93ae;

  /// No description provided for @stationTagdda0f9acde.
  ///
  /// In en, this message translates to:
  /// **'contemporary christian'**
  String get stationTagdda0f9acde;

  /// No description provided for @stationTag13fd6746fe.
  ///
  /// In en, this message translates to:
  /// **'contemporary country'**
  String get stationTag13fd6746fe;

  /// No description provided for @stationTag40eb1a9b87.
  ///
  /// In en, this message translates to:
  /// **'contemporary hits radio'**
  String get stationTag40eb1a9b87;

  /// No description provided for @stationTagc567a18aa0.
  ///
  /// In en, this message translates to:
  /// **'contemporary jazz'**
  String get stationTagc567a18aa0;

  /// No description provided for @stationTag8e68b3e5af.
  ///
  /// In en, this message translates to:
  /// **'country'**
  String get stationTag8e68b3e5af;

  /// No description provided for @stationTag141546aac4.
  ///
  /// In en, this message translates to:
  /// **'country blues'**
  String get stationTag141546aac4;

  /// No description provided for @stationTagd5a23debab.
  ///
  /// In en, this message translates to:
  /// **'country music'**
  String get stationTagd5a23debab;

  /// No description provided for @stationTag5c685d4499.
  ///
  /// In en, this message translates to:
  /// **'country pop'**
  String get stationTag5c685d4499;

  /// No description provided for @stationTag83ac283371.
  ///
  /// In en, this message translates to:
  /// **'country rock'**
  String get stationTag83ac283371;

  /// No description provided for @stationTag5f58355136.
  ///
  /// In en, this message translates to:
  /// **'cultural'**
  String get stationTag5f58355136;

  /// No description provided for @stationTag7820e1d879.
  ///
  /// In en, this message translates to:
  /// **'cultural news'**
  String get stationTag7820e1d879;

  /// No description provided for @stationTag8f2e7cd784.
  ///
  /// In en, this message translates to:
  /// **'culture'**
  String get stationTag8f2e7cd784;

  /// No description provided for @stationTag74b518ed55.
  ///
  /// In en, this message translates to:
  /// **'dance'**
  String get stationTag74b518ed55;

  /// No description provided for @stationTage8de1377be.
  ///
  /// In en, this message translates to:
  /// **'dancehall'**
  String get stationTage8de1377be;

  /// No description provided for @stationTagd8362a14e6.
  ///
  /// In en, this message translates to:
  /// **'deutsch'**
  String get stationTagd8362a14e6;

  /// No description provided for @stationTag95c152a176.
  ///
  /// In en, this message translates to:
  /// **'Dečija'**
  String get stationTag95c152a176;

  /// No description provided for @stationTag9a1c2a67fc.
  ///
  /// In en, this message translates to:
  /// **'disco'**
  String get stationTag9a1c2a67fc;

  /// No description provided for @stationTag05d80cd9c4.
  ///
  /// In en, this message translates to:
  /// **'dj mixes'**
  String get stationTag05d80cd9c4;

  /// No description provided for @stationTag49c149dc66.
  ///
  /// In en, this message translates to:
  /// **'dj remix'**
  String get stationTag49c149dc66;

  /// No description provided for @stationTag91dbf3c2a7.
  ///
  /// In en, this message translates to:
  /// **'dj sets'**
  String get stationTag91dbf3c2a7;

  /// No description provided for @stationTagf924b9625d.
  ///
  /// In en, this message translates to:
  /// **'downtempo'**
  String get stationTagf924b9625d;

  /// No description provided for @stationTag63b1298947.
  ///
  /// In en, this message translates to:
  /// **'drama'**
  String get stationTag63b1298947;

  /// No description provided for @stationTage69a4f2256.
  ///
  /// In en, this message translates to:
  /// **'Duhovna'**
  String get stationTage69a4f2256;

  /// No description provided for @stationTag52edaa4e68.
  ///
  /// In en, this message translates to:
  /// **'easy listening'**
  String get stationTag52edaa4e68;

  /// No description provided for @stationTage3164293ed.
  ///
  /// In en, this message translates to:
  /// **'eclectic'**
  String get stationTage3164293ed;

  /// No description provided for @stationTagb4d21f8747.
  ///
  /// In en, this message translates to:
  /// **'electro'**
  String get stationTagb4d21f8747;

  /// No description provided for @stationTag3797c42f9d.
  ///
  /// In en, this message translates to:
  /// **'electronic'**
  String get stationTag3797c42f9d;

  /// No description provided for @stationTag043f28f4b5.
  ///
  /// In en, this message translates to:
  /// **'electronic dance music'**
  String get stationTag043f28f4b5;

  /// No description provided for @stationTag4dc773db68.
  ///
  /// In en, this message translates to:
  /// **'electronica'**
  String get stationTag4dc773db68;

  /// No description provided for @stationTagc32b941d4e.
  ///
  /// In en, this message translates to:
  /// **'entertainment'**
  String get stationTagc32b941d4e;

  /// No description provided for @stationTag8b47d2a821.
  ///
  /// In en, this message translates to:
  /// **'Etno'**
  String get stationTag8b47d2a821;

  /// No description provided for @stationTag30e382c6b8.
  ///
  /// In en, this message translates to:
  /// **'eurodance'**
  String get stationTag30e382c6b8;

  /// No description provided for @stationTag59acab5d0a.
  ///
  /// In en, this message translates to:
  /// **'Evergreen'**
  String get stationTag59acab5d0a;

  /// No description provided for @stationTag204994198c.
  ///
  /// In en, this message translates to:
  /// **'evergreens'**
  String get stationTag204994198c;

  /// No description provided for @stationTag2216470a6a.
  ///
  /// In en, this message translates to:
  /// **'experimental'**
  String get stationTag2216470a6a;

  /// No description provided for @stationTag2d02ecf89a.
  ///
  /// In en, this message translates to:
  /// **'folk'**
  String get stationTag2d02ecf89a;

  /// No description provided for @stationTagd2330d0952.
  ///
  /// In en, this message translates to:
  /// **'free jazz'**
  String get stationTagd2330d0952;

  /// No description provided for @stationTag30ec1e5ee8.
  ///
  /// In en, this message translates to:
  /// **'funk'**
  String get stationTag30ec1e5ee8;

  /// No description provided for @stationTagdbbbceb206.
  ///
  /// In en, this message translates to:
  /// **'funky'**
  String get stationTagdbbbceb206;

  /// No description provided for @stationTag4c2f65997d.
  ///
  /// In en, this message translates to:
  /// **'garage'**
  String get stationTag4c2f65997d;

  /// No description provided for @stationTagdfe2db7497.
  ///
  /// In en, this message translates to:
  /// **'general'**
  String get stationTagdfe2db7497;

  /// No description provided for @stationTag5eaf52a9b8.
  ///
  /// In en, this message translates to:
  /// **'global radio'**
  String get stationTag5eaf52a9b8;

  /// No description provided for @stationTagcf75b6e07e.
  ///
  /// In en, this message translates to:
  /// **'gospel'**
  String get stationTagcf75b6e07e;

  /// No description provided for @stationTagb9b7a52438.
  ///
  /// In en, this message translates to:
  /// **'gospel music'**
  String get stationTagb9b7a52438;

  /// No description provided for @stationTag6b477d6b44.
  ///
  /// In en, this message translates to:
  /// **'gusle'**
  String get stationTag6b477d6b44;

  /// No description provided for @stationTag21d286310f.
  ///
  /// In en, this message translates to:
  /// **'gym'**
  String get stationTag21d286310f;

  /// No description provided for @stationTagdd1b58d84e.
  ///
  /// In en, this message translates to:
  /// **'hard bop'**
  String get stationTagdd1b58d84e;

  /// No description provided for @stationTag1dad8d9def.
  ///
  /// In en, this message translates to:
  /// **'hard rock'**
  String get stationTag1dad8d9def;

  /// No description provided for @stationTaga2a76210fb.
  ///
  /// In en, this message translates to:
  /// **'hard techno'**
  String get stationTaga2a76210fb;

  /// No description provided for @stationTag40e6f3039d.
  ///
  /// In en, this message translates to:
  /// **'heavy metal'**
  String get stationTag40e6f3039d;

  /// No description provided for @stationTag1ab40b9589.
  ///
  /// In en, this message translates to:
  /// **'hip hop'**
  String get stationTag1ab40b9589;

  /// No description provided for @stationTagd45000b24b.
  ///
  /// In en, this message translates to:
  /// **'hip-hop'**
  String get stationTagd45000b24b;

  /// No description provided for @stationTagac806dd8ce.
  ///
  /// In en, this message translates to:
  /// **'hiphop'**
  String get stationTagac806dd8ce;

  /// No description provided for @stationTag80d6b4b236.
  ///
  /// In en, this message translates to:
  /// **'hitovi'**
  String get stationTag80d6b4b236;

  /// No description provided for @stationTagc748c763b9.
  ///
  /// In en, this message translates to:
  /// **'hits'**
  String get stationTagc748c763b9;

  /// No description provided for @stationTag1b602c45be.
  ///
  /// In en, this message translates to:
  /// **'holiday'**
  String get stationTag1b602c45be;

  /// No description provided for @stationTag5be93480bd.
  ///
  /// In en, this message translates to:
  /// **'house'**
  String get stationTag5be93480bd;

  /// No description provided for @stationTagf6f30f107a.
  ///
  /// In en, this message translates to:
  /// **'humor'**
  String get stationTagf6f30f107a;

  /// No description provided for @stationTag5e92ba075a.
  ///
  /// In en, this message translates to:
  /// **'humour'**
  String get stationTag5e92ba075a;

  /// No description provided for @stationTagd085829c2c.
  ///
  /// In en, this message translates to:
  /// **'hymns'**
  String get stationTagd085829c2c;

  /// No description provided for @stationTage33fc333d4.
  ///
  /// In en, this message translates to:
  /// **'indie'**
  String get stationTage33fc333d4;

  /// No description provided for @stationTag93604d928b.
  ///
  /// In en, this message translates to:
  /// **'indie pop'**
  String get stationTag93604d928b;

  /// No description provided for @stationTag0c7bc23252.
  ///
  /// In en, this message translates to:
  /// **'indie rock'**
  String get stationTag0c7bc23252;

  /// No description provided for @stationTag59bd0a3ff4.
  ///
  /// In en, this message translates to:
  /// **'info'**
  String get stationTag59bd0a3ff4;

  /// No description provided for @stationTag83dd9d6af4.
  ///
  /// In en, this message translates to:
  /// **'information'**
  String get stationTag83dd9d6af4;

  /// No description provided for @stationTag48d513fd88.
  ///
  /// In en, this message translates to:
  /// **'infotainment'**
  String get stationTag48d513fd88;

  /// No description provided for @stationTag070db54a6f.
  ///
  /// In en, this message translates to:
  /// **'Instrumental'**
  String get stationTag070db54a6f;

  /// No description provided for @stationTag4d0fb475b2.
  ///
  /// In en, this message translates to:
  /// **'internet'**
  String get stationTag4d0fb475b2;

  /// No description provided for @stationTag25c4ae7fd8.
  ///
  /// In en, this message translates to:
  /// **'internet radio'**
  String get stationTag25c4ae7fd8;

  /// No description provided for @stationTag0313752b11.
  ///
  /// In en, this message translates to:
  /// **'internet-radio'**
  String get stationTag0313752b11;

  /// No description provided for @stationTagdaf14c7984.
  ///
  /// In en, this message translates to:
  /// **'italian'**
  String get stationTagdaf14c7984;

  /// No description provided for @stationTag337cf35e7a.
  ///
  /// In en, this message translates to:
  /// **'italian pop'**
  String get stationTag337cf35e7a;

  /// No description provided for @stationTag7b8af9235d.
  ///
  /// In en, this message translates to:
  /// **'italo'**
  String get stationTag7b8af9235d;

  /// No description provided for @stationTag04f65fbe0d.
  ///
  /// In en, this message translates to:
  /// **'italo dance'**
  String get stationTag04f65fbe0d;

  /// No description provided for @stationTag9dfb478f68.
  ///
  /// In en, this message translates to:
  /// **'italo disco'**
  String get stationTag9dfb478f68;

  /// No description provided for @stationTag71fddd2ecc.
  ///
  /// In en, this message translates to:
  /// **'Izvorna'**
  String get stationTag71fddd2ecc;

  /// No description provided for @stationTag6abc743bbd.
  ///
  /// In en, this message translates to:
  /// **'jazz'**
  String get stationTag6abc743bbd;

  /// No description provided for @stationTag1aee2a66e1.
  ///
  /// In en, this message translates to:
  /// **'jazzy'**
  String get stationTag1aee2a66e1;

  /// No description provided for @stationTag5212351459.
  ///
  /// In en, this message translates to:
  /// **'jpop'**
  String get stationTag5212351459;

  /// No description provided for @stationTagb37f602962.
  ///
  /// In en, this message translates to:
  /// **'Klasična'**
  String get stationTagb37f602962;

  /// No description provided for @stationTag382a11c991.
  ///
  /// In en, this message translates to:
  /// **'Krajiška'**
  String get stationTag382a11c991;

  /// No description provided for @stationTag6504358a41.
  ///
  /// In en, this message translates to:
  /// **'kultur'**
  String get stationTag6504358a41;

  /// No description provided for @stationTag9706e2b789.
  ///
  /// In en, this message translates to:
  /// **'Lagana'**
  String get stationTag9706e2b789;

  /// No description provided for @stationTage2d35ad940.
  ///
  /// In en, this message translates to:
  /// **'latin'**
  String get stationTage2d35ad940;

  /// No description provided for @stationTagd87f9ff79e.
  ///
  /// In en, this message translates to:
  /// **'latin music'**
  String get stationTagd87f9ff79e;

  /// No description provided for @stationTag045615950e.
  ///
  /// In en, this message translates to:
  /// **'latin pop'**
  String get stationTag045615950e;

  /// No description provided for @stationTag9f2222b7fb.
  ///
  /// In en, this message translates to:
  /// **'latino'**
  String get stationTag9f2222b7fb;

  /// No description provided for @stationTag1e2f761d51.
  ///
  /// In en, this message translates to:
  /// **'lifestyle'**
  String get stationTag1e2f761d51;

  /// No description provided for @stationTag98aadb3708.
  ///
  /// In en, this message translates to:
  /// **'live'**
  String get stationTag98aadb3708;

  /// No description provided for @stationTag14039d1152.
  ///
  /// In en, this message translates to:
  /// **'live sports'**
  String get stationTag14039d1152;

  /// No description provided for @stationTag939bb46a04.
  ///
  /// In en, this message translates to:
  /// **'local'**
  String get stationTag939bb46a04;

  /// No description provided for @stationTag43a88022d6.
  ///
  /// In en, this message translates to:
  /// **'local music'**
  String get stationTag43a88022d6;

  /// No description provided for @stationTag442ac2cf88.
  ///
  /// In en, this message translates to:
  /// **'local news'**
  String get stationTag442ac2cf88;

  /// No description provided for @stationTagf06015be10.
  ///
  /// In en, this message translates to:
  /// **'local radio'**
  String get stationTagf06015be10;

  /// No description provided for @stationTagf336da1d34.
  ///
  /// In en, this message translates to:
  /// **'love songs'**
  String get stationTagf336da1d34;

  /// No description provided for @stationTage3493be66f.
  ///
  /// In en, this message translates to:
  /// **'mainstream'**
  String get stationTage3493be66f;

  /// No description provided for @stationTag9d983dd224.
  ///
  /// In en, this message translates to:
  /// **'mainstream jazz'**
  String get stationTag9d983dd224;

  /// No description provided for @stationTag4963bb0591.
  ///
  /// In en, this message translates to:
  /// **'metal'**
  String get stationTag4963bb0591;

  /// No description provided for @stationTagff8b611a89.
  ///
  /// In en, this message translates to:
  /// **'mexican music'**
  String get stationTagff8b611a89;

  /// No description provided for @stationTagb0264c19da.
  ///
  /// In en, this message translates to:
  /// **'middle eastern music'**
  String get stationTagb0264c19da;

  /// No description provided for @stationTag5c4821749c.
  ///
  /// In en, this message translates to:
  /// **'minimal'**
  String get stationTag5c4821749c;

  /// No description provided for @stationTag629ead9591.
  ///
  /// In en, this message translates to:
  /// **'minimal techno'**
  String get stationTag629ead9591;

  /// No description provided for @stationTag38743fbb44.
  ///
  /// In en, this message translates to:
  /// **'Mix'**
  String get stationTag38743fbb44;

  /// No description provided for @stationTagb09be85d51.
  ///
  /// In en, this message translates to:
  /// **'modern'**
  String get stationTagb09be85d51;

  /// No description provided for @stationTagc670bbfd94.
  ///
  /// In en, this message translates to:
  /// **'modern rock'**
  String get stationTagc670bbfd94;

  /// No description provided for @stationTag3a01be1724.
  ///
  /// In en, this message translates to:
  /// **'music'**
  String get stationTag3a01be1724;

  /// No description provided for @stationTagfe0feb3c23.
  ///
  /// In en, this message translates to:
  /// **'musical'**
  String get stationTagfe0feb3c23;

  /// No description provided for @stationTag489d08ab84.
  ///
  /// In en, this message translates to:
  /// **'muzika za decu'**
  String get stationTag489d08ab84;

  /// No description provided for @stationTag71c1d51400.
  ///
  /// In en, this message translates to:
  /// **'Narodna'**
  String get stationTag71c1d51400;

  /// No description provided for @stationTag996676018c.
  ///
  /// In en, this message translates to:
  /// **'narodna - etno'**
  String get stationTag996676018c;

  /// No description provided for @stationTagba1d431793.
  ///
  /// In en, this message translates to:
  /// **'national'**
  String get stationTagba1d431793;

  /// No description provided for @stationTag6d150cec97.
  ///
  /// In en, this message translates to:
  /// **'new wave'**
  String get stationTag6d150cec97;

  /// No description provided for @stationTag3c6bdcddc9.
  ///
  /// In en, this message translates to:
  /// **'news'**
  String get stationTag3c6bdcddc9;

  /// No description provided for @stationTag54ac9a2e58.
  ///
  /// In en, this message translates to:
  /// **'news radio'**
  String get stationTag54ac9a2e58;

  /// No description provided for @stationTagca29a260a8.
  ///
  /// In en, this message translates to:
  /// **'news talk'**
  String get stationTagca29a260a8;

  /// No description provided for @stationTag81f7a3d9ae.
  ///
  /// In en, this message translates to:
  /// **'non-commercial'**
  String get stationTag81f7a3d9ae;

  /// No description provided for @stationTaga6b8fe2ef4.
  ///
  /// In en, this message translates to:
  /// **'non-stop music'**
  String get stationTaga6b8fe2ef4;

  /// No description provided for @stationTaga67edc88d9.
  ///
  /// In en, this message translates to:
  /// **'nostalgia'**
  String get stationTaga67edc88d9;

  /// No description provided for @stationTag869f15a237.
  ///
  /// In en, this message translates to:
  /// **'noticias'**
  String get stationTag869f15a237;

  /// No description provided for @stationTag5d6687996d.
  ///
  /// In en, this message translates to:
  /// **'oldies'**
  String get stationTag5d6687996d;

  /// No description provided for @stationTag2dbc2fd235.
  ///
  /// In en, this message translates to:
  /// **'online'**
  String get stationTag2dbc2fd235;

  /// No description provided for @stationTag6feda84dcc.
  ///
  /// In en, this message translates to:
  /// **'opera'**
  String get stationTag6feda84dcc;

  /// No description provided for @stationTag8341873a88.
  ///
  /// In en, this message translates to:
  /// **'opus'**
  String get stationTag8341873a88;

  /// No description provided for @stationTag03c8ed27df.
  ///
  /// In en, this message translates to:
  /// **'orchestral'**
  String get stationTag03c8ed27df;

  /// No description provided for @stationTag84beb18831.
  ///
  /// In en, this message translates to:
  /// **'party'**
  String get stationTag84beb18831;

  /// No description provided for @stationTag3f4667905c.
  ///
  /// In en, this message translates to:
  /// **'party hits'**
  String get stationTag3f4667905c;

  /// No description provided for @stationTagee848a3b5b.
  ///
  /// In en, this message translates to:
  /// **'police'**
  String get stationTagee848a3b5b;

  /// No description provided for @stationTagae4fd29aa1.
  ///
  /// In en, this message translates to:
  /// **'political talk'**
  String get stationTagae4fd29aa1;

  /// No description provided for @stationTag4c5fd84e89.
  ///
  /// In en, this message translates to:
  /// **'politics'**
  String get stationTag4c5fd84e89;

  /// No description provided for @stationTag4f197c99a7.
  ///
  /// In en, this message translates to:
  /// **'pop'**
  String get stationTag4f197c99a7;

  /// No description provided for @stationTag122fb23bc6.
  ///
  /// In en, this message translates to:
  /// **'pop dance'**
  String get stationTag122fb23bc6;

  /// No description provided for @stationTag0be9a78da5.
  ///
  /// In en, this message translates to:
  /// **'pop latino'**
  String get stationTag0be9a78da5;

  /// No description provided for @stationTag9eda0e7aa9.
  ///
  /// In en, this message translates to:
  /// **'pop music'**
  String get stationTag9eda0e7aa9;

  /// No description provided for @stationTagbb2c038983.
  ///
  /// In en, this message translates to:
  /// **'pop rock'**
  String get stationTagbb2c038983;

  /// No description provided for @stationTag74c72544e0.
  ///
  /// In en, this message translates to:
  /// **'pop-rock'**
  String get stationTag74c72544e0;

  /// No description provided for @stationTag136dfa5b33.
  ///
  /// In en, this message translates to:
  /// **'progressive house'**
  String get stationTag136dfa5b33;

  /// No description provided for @stationTaga2f77c10a5.
  ///
  /// In en, this message translates to:
  /// **'public radio'**
  String get stationTaga2f77c10a5;

  /// No description provided for @stationTag71d689362a.
  ///
  /// In en, this message translates to:
  /// **'public service'**
  String get stationTag71d689362a;

  /// No description provided for @stationTag5940e3137d.
  ///
  /// In en, this message translates to:
  /// **'punk'**
  String get stationTag5940e3137d;

  /// No description provided for @stationTagcb0cde801b.
  ///
  /// In en, this message translates to:
  /// **'r&b'**
  String get stationTagcb0cde801b;

  /// No description provided for @stationTag6e2a486fe3.
  ///
  /// In en, this message translates to:
  /// **'r&b/urban'**
  String get stationTag6e2a486fe3;

  /// No description provided for @stationTag5c4a513dbf.
  ///
  /// In en, this message translates to:
  /// **'r\'n\'b'**
  String get stationTag5c4a513dbf;

  /// No description provided for @stationTagd432c3525b.
  ///
  /// In en, this message translates to:
  /// **'radio'**
  String get stationTagd432c3525b;

  /// No description provided for @stationTag8390ac37de.
  ///
  /// In en, this message translates to:
  /// **'radio online'**
  String get stationTag8390ac37de;

  /// No description provided for @stationTag1bf1b43494.
  ///
  /// In en, this message translates to:
  /// **'radiorama'**
  String get stationTag1bf1b43494;

  /// No description provided for @stationTag51c4ccfd6b.
  ///
  /// In en, this message translates to:
  /// **'rap'**
  String get stationTag51c4ccfd6b;

  /// No description provided for @stationTag914bdbfd48.
  ///
  /// In en, this message translates to:
  /// **'rap hiphop rnb'**
  String get stationTag914bdbfd48;

  /// No description provided for @stationTag0615591f84.
  ///
  /// In en, this message translates to:
  /// **'reggae'**
  String get stationTag0615591f84;

  /// No description provided for @stationTag65013ec4e5.
  ///
  /// In en, this message translates to:
  /// **'reggaeton'**
  String get stationTag65013ec4e5;

  /// No description provided for @stationTag197caeb8b5.
  ///
  /// In en, this message translates to:
  /// **'regional'**
  String get stationTag197caeb8b5;

  /// No description provided for @stationTaga6d888f965.
  ///
  /// In en, this message translates to:
  /// **'regional radio'**
  String get stationTaga6d888f965;

  /// No description provided for @stationTag63bb094ca4.
  ///
  /// In en, this message translates to:
  /// **'relax'**
  String get stationTag63bb094ca4;

  /// No description provided for @stationTagb912a11ddd.
  ///
  /// In en, this message translates to:
  /// **'relaxation'**
  String get stationTagb912a11ddd;

  /// No description provided for @stationTag6e93871ac7.
  ///
  /// In en, this message translates to:
  /// **'relaxing'**
  String get stationTag6e93871ac7;

  /// No description provided for @stationTagbbde763cc0.
  ///
  /// In en, this message translates to:
  /// **'remix'**
  String get stationTagbbde763cc0;

  /// No description provided for @stationTag4c742a2314.
  ///
  /// In en, this message translates to:
  /// **'retro'**
  String get stationTag4c742a2314;

  /// No description provided for @stationTagf2792fa06d.
  ///
  /// In en, this message translates to:
  /// **'rnb'**
  String get stationTagf2792fa06d;

  /// No description provided for @stationTag38464bf083.
  ///
  /// In en, this message translates to:
  /// **'rock'**
  String get stationTag38464bf083;

  /// No description provided for @stationTag17c8217f23.
  ///
  /// In en, this message translates to:
  /// **'rock\'n\'roll'**
  String get stationTag17c8217f23;

  /// No description provided for @stationTag5b9265ef9f.
  ///
  /// In en, this message translates to:
  /// **'rockabilly'**
  String get stationTag5b9265ef9f;

  /// No description provided for @stationTag346f5986a9.
  ///
  /// In en, this message translates to:
  /// **'romantic'**
  String get stationTag346f5986a9;

  /// No description provided for @stationTag17d7cc4d9a.
  ///
  /// In en, this message translates to:
  /// **'russian pop'**
  String get stationTag17d7cc4d9a;

  /// No description provided for @stationTagb36ad30593.
  ///
  /// In en, this message translates to:
  /// **'samba'**
  String get stationTagb36ad30593;

  /// No description provided for @stationTag64fd638390.
  ///
  /// In en, this message translates to:
  /// **'seasonal'**
  String get stationTag64fd638390;

  /// No description provided for @stationTagf81ac68eee.
  ///
  /// In en, this message translates to:
  /// **'serbian music'**
  String get stationTagf81ac68eee;

  /// No description provided for @stationTag3aa9adbbb4.
  ///
  /// In en, this message translates to:
  /// **'ska'**
  String get stationTag3aa9adbbb4;

  /// No description provided for @stationTagc3ca5f7873.
  ///
  /// In en, this message translates to:
  /// **'sleep'**
  String get stationTagc3ca5f7873;

  /// No description provided for @stationTag6c021501ca.
  ///
  /// In en, this message translates to:
  /// **'slow rock'**
  String get stationTag6c021501ca;

  /// No description provided for @stationTagc0c6d93fe3.
  ///
  /// In en, this message translates to:
  /// **'soft music'**
  String get stationTagc0c6d93fe3;

  /// No description provided for @stationTagc5c1fe26d5.
  ///
  /// In en, this message translates to:
  /// **'soft pop'**
  String get stationTagc5c1fe26d5;

  /// No description provided for @stationTag3af8919a33.
  ///
  /// In en, this message translates to:
  /// **'soft rock'**
  String get stationTag3af8919a33;

  /// No description provided for @stationTag0867322e7c.
  ///
  /// In en, this message translates to:
  /// **'soul'**
  String get stationTag0867322e7c;

  /// No description provided for @stationTag3e4ef17728.
  ///
  /// In en, this message translates to:
  /// **'sounds of nature'**
  String get stationTag3e4ef17728;

  /// No description provided for @stationTagf3690b9c34.
  ///
  /// In en, this message translates to:
  /// **'speech'**
  String get stationTagf3690b9c34;

  /// No description provided for @stationTag8ab6a8a0cf.
  ///
  /// In en, this message translates to:
  /// **'sport'**
  String get stationTag8ab6a8a0cf;

  /// No description provided for @stationTag150a8af76a.
  ///
  /// In en, this message translates to:
  /// **'sports'**
  String get stationTag150a8af76a;

  /// No description provided for @stationTag7899b8b3d9.
  ///
  /// In en, this message translates to:
  /// **'sports news'**
  String get stationTag7899b8b3d9;

  /// No description provided for @stationTag4c5218bd29.
  ///
  /// In en, this message translates to:
  /// **'sports talk'**
  String get stationTag4c5218bd29;

  /// No description provided for @stationTag0b1ecf7216.
  ///
  /// In en, this message translates to:
  /// **'Starogradska'**
  String get stationTag0b1ecf7216;

  /// No description provided for @stationTag723f4e1ce3.
  ///
  /// In en, this message translates to:
  /// **'swing'**
  String get stationTag723f4e1ce3;

  /// No description provided for @stationTage55e91b2cc.
  ///
  /// In en, this message translates to:
  /// **'talk'**
  String get stationTage55e91b2cc;

  /// No description provided for @stationTag5108191aa3.
  ///
  /// In en, this message translates to:
  /// **'talk radio'**
  String get stationTag5108191aa3;

  /// No description provided for @stationTage405fa83fe.
  ///
  /// In en, this message translates to:
  /// **'techno'**
  String get stationTage405fa83fe;

  /// No description provided for @stationTag27d50b6f9a.
  ///
  /// In en, this message translates to:
  /// **'top charts'**
  String get stationTag27d50b6f9a;

  /// No description provided for @stationTag795bbda660.
  ///
  /// In en, this message translates to:
  /// **'top hits'**
  String get stationTag795bbda660;

  /// No description provided for @stationTag7f1345c21a.
  ///
  /// In en, this message translates to:
  /// **'trance'**
  String get stationTag7f1345c21a;

  /// No description provided for @stationTage6d307367a.
  ///
  /// In en, this message translates to:
  /// **'trap'**
  String get stationTage6d307367a;

  /// No description provided for @stationTagad3d12ae13.
  ///
  /// In en, this message translates to:
  /// **'trip hop'**
  String get stationTagad3d12ae13;

  /// No description provided for @stationTagba7a82a981.
  ///
  /// In en, this message translates to:
  /// **'urban'**
  String get stationTagba7a82a981;

  /// No description provided for @stationTag09cdd5dd4b.
  ///
  /// In en, this message translates to:
  /// **'urbano'**
  String get stationTag09cdd5dd4b;

  /// No description provided for @stationTag84942e2fd1.
  ///
  /// In en, this message translates to:
  /// **'uživo'**
  String get stationTag84942e2fd1;

  /// No description provided for @stationTag75b4d7d721.
  ///
  /// In en, this message translates to:
  /// **'varied'**
  String get stationTag75b4d7d721;

  /// No description provided for @stationTag21e7a8ba50.
  ///
  /// In en, this message translates to:
  /// **'variety'**
  String get stationTag21e7a8ba50;

  /// No description provided for @stationTage609aae6c8.
  ///
  /// In en, this message translates to:
  /// **'Vesti'**
  String get stationTage609aae6c8;

  /// No description provided for @stationTag0be9098c7e.
  ///
  /// In en, this message translates to:
  /// **'vintage'**
  String get stationTag0be9098c7e;

  /// No description provided for @stationTagbf6e51973d.
  ///
  /// In en, this message translates to:
  /// **'vinyl'**
  String get stationTagbf6e51973d;

  /// No description provided for @stationTag91b7e90635.
  ///
  /// In en, this message translates to:
  /// **'Vlaška'**
  String get stationTag91b7e90635;

  /// No description provided for @stationTag7c211433f0.
  ///
  /// In en, this message translates to:
  /// **'world'**
  String get stationTag7c211433f0;

  /// No description provided for @stationTag3c405b7c0e.
  ///
  /// In en, this message translates to:
  /// **'world music'**
  String get stationTag3c405b7c0e;

  /// No description provided for @stationTag7b0ac581fe.
  ///
  /// In en, this message translates to:
  /// **'world news'**
  String get stationTag7b0ac581fe;

  /// No description provided for @stationTagf9925d1162.
  ///
  /// In en, this message translates to:
  /// **'youth'**
  String get stationTagf9925d1162;

  /// No description provided for @stationTag9de3eede6a.
  ///
  /// In en, this message translates to:
  /// **'Zabavna'**
  String get stationTag9de3eede6a;

  /// No description provided for @stationTaga712aa0f9d.
  ///
  /// In en, this message translates to:
  /// **'аудиокниги'**
  String get stationTaga712aa0f9d;

  /// No description provided for @stationTagd341e6e288.
  ///
  /// In en, this message translates to:
  /// **'детям'**
  String get stationTagd341e6e288;

  /// No description provided for @stationTag6e0dc4349c.
  ///
  /// In en, this message translates to:
  /// **'литература'**
  String get stationTag6e0dc4349c;

  /// No description provided for @stationTagd42e4f9f15.
  ///
  /// In en, this message translates to:
  /// **'политика'**
  String get stationTagd42e4f9f15;

  /// No description provided for @stationTag2ca9d5c635.
  ///
  /// In en, this message translates to:
  /// **'поп'**
  String get stationTag2ca9d5c635;

  /// No description provided for @stationTagb5cbcd9cbc.
  ///
  /// In en, this message translates to:
  /// **'рок'**
  String get stationTagb5cbcd9cbc;

  /// No description provided for @stationTagb5f9fa4f69.
  ///
  /// In en, this message translates to:
  /// **'этно'**
  String get stationTagb5f9fa4f69;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'sr':
      {
        switch (locale.scriptCode) {
          case 'Latn':
            return AppLocalizationsSrLatn();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sr':
      return AppLocalizationsSr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

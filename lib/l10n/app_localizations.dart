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

  /// No description provided for @debugView.
  ///
  /// In en, this message translates to:
  /// **'Debug view'**
  String get debugView;

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

  /// No description provided for @activeSource.
  ///
  /// In en, this message translates to:
  /// **'Active source'**
  String get activeSource;

  /// No description provided for @noSourceLoaded.
  ///
  /// In en, this message translates to:
  /// **'No source loaded'**
  String get noSourceLoaded;

  /// No description provided for @stationLoadingLog.
  ///
  /// In en, this message translates to:
  /// **'Station loading log'**
  String get stationLoadingLog;

  /// No description provided for @noStationLoadingEvents.
  ///
  /// In en, this message translates to:
  /// **'No station loading events recorded.'**
  String get noStationLoadingEvents;

  /// No description provided for @playableStationCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 playable station loaded} other{{count} playable stations loaded}}'**
  String playableStationCount(int count);

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

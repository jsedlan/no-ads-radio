// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Serbian (`sr`).
class AppLocalizationsSr extends AppLocalizations {
  AppLocalizationsSr([String locale = 'sr']) : super(locale);

  @override
  String get appTitle => 'NoAds Radio';

  @override
  String get language => 'Jezik';

  @override
  String get languageDescription => 'Izaberite jezik aplikacije.';

  @override
  String get systemDefault => 'Jezik sistema';

  @override
  String get english => 'Engleski';

  @override
  String get serbianLatin => 'Srpski (latinica)';

  @override
  String get theme => 'Tema';

  @override
  String get themeDescription => 'Izaberite izgled aplikacije.';

  @override
  String get dark => 'Tamna';

  @override
  String get light => 'Svetla';

  @override
  String get chooseCountryTitle => 'Izaberite zemlju radio stanica';

  @override
  String get chooseCountryDescription =>
      'Ovaj izbor određuje koje stanice se prikazuju prve. Predlog dolazi iz podešavanja jezika uređaja i možda ne odgovara vašoj fizičkoj lokaciji.';

  @override
  String get moreCountriesLater =>
      'Kasnije možete dodati još zemalja u Podešavanjima.';

  @override
  String get selectCountry => 'Izaberite zemlju';

  @override
  String get saving => 'Čuvanje...';

  @override
  String get continueLabel => 'Nastavi';

  @override
  String get filter => 'Filtriraj';

  @override
  String get clearFilter => 'Obriši filter';

  @override
  String get offline => 'Van mreže';

  @override
  String get filterStations => 'Filtriraj stanice';

  @override
  String get more => 'Više';

  @override
  String get debugView => 'Dijagnostika';

  @override
  String get settings => 'Podešavanja';

  @override
  String get noStationsAvailable => 'Trenutno nema dostupnih stanica.';

  @override
  String get clear => 'Obriši';

  @override
  String stationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stanica',
      few: '$count stanice',
      one: '$count stanica',
      zero: 'Nema stanica',
    );
    return '$_temp0';
  }

  @override
  String filteredStationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filtriranih stanica',
      few: '$count filtrirane stanice',
      one: '$count filtrirana stanica',
      zero: 'Nema filtriranih stanica',
    );
    return '$_temp0';
  }

  @override
  String get categories => 'Kategorije';

  @override
  String get recentlyPlayed => 'Nedavno slušano';

  @override
  String get noRecentlyPlayed => 'Nema nedavno slušanih stanica.';

  @override
  String get stationCountries => 'Zemlje radio stanica';

  @override
  String get atLeastOneCountry => 'Najmanje jedna zemlja mora ostati izabrana.';

  @override
  String get diasporaCountryNote =>
      'Stanice iz dijaspore se automatski uključuju kada izaberete bilo koju zemlju bivše Jugoslavije.';

  @override
  String get selectedCountries => 'Izabrane zemlje';

  @override
  String get dragToReorder => 'Prevucite za promenu redosleda';

  @override
  String get addCountry => 'Dodaj zemlju';

  @override
  String get done => 'Gotovo';

  @override
  String get searchCountries => 'Pretraži zemlje';

  @override
  String get searchCountriesHint => 'Srbija ili RS';

  @override
  String get noCountriesAvailable => 'Nema dostupnih zemalja.';

  @override
  String get stations => 'Stanice';

  @override
  String noFavoritesInCategory(Object category) {
    return 'Još nema omiljenih stanica u kategoriji $category. Sačuvajte stanice sa kartice Stanice.';
  }

  @override
  String get nowPlaying => 'Slušate';

  @override
  String get back => 'Nazad';

  @override
  String get nothingPlaying => 'Ništa se ne reprodukuje.';

  @override
  String get previousFavorite => 'Prethodna omiljena';

  @override
  String get pause => 'Pauziraj';

  @override
  String get play => 'Pusti';

  @override
  String get nextFavorite => 'Sledeća omiljena';

  @override
  String get cast => 'Prebaci reprodukciju';

  @override
  String get castDevices => 'Cast uređaji';

  @override
  String castingTo(Object device) {
    return 'Reprodukcija na uređaju $device';
  }

  @override
  String get disconnect => 'Prekini vezu';

  @override
  String get searchingCastDevices => 'Traženje Cast uređaja...';

  @override
  String get noCastDevices =>
      'Nije pronađen nijedan Cast uređaj. Proverite da li su oba uređaja na istoj Wi-Fi mreži.';

  @override
  String get iosCastPermissionHelp =>
      'Na iPhone uređaju dozvolite pristup lokalnoj mreži u Podešavanja > Privatnost i bezbednost > Lokalna mreža > NoAds Radio, pa pokušajte ponovo.';

  @override
  String get searchAgain => 'Traži ponovo';

  @override
  String get castConnectionFailed =>
      'Povezivanje sa Cast uređajem nije uspelo.';

  @override
  String get track => 'Pesma';

  @override
  String get stream => 'Strim';

  @override
  String get genre => 'Žanr';

  @override
  String get location => 'Lokacija';

  @override
  String get tags => 'Oznake';

  @override
  String get codec => 'Kodek';

  @override
  String get bitrate => 'Brzina protoka';

  @override
  String get sleepTimer => 'Tajmer za spavanje';

  @override
  String sleepTimerWithRemaining(Object remaining) {
    return 'Tajmer za spavanje: $remaining';
  }

  @override
  String get off => 'Isključeno';

  @override
  String get custom => 'Prilagođeno';

  @override
  String get customSleepTimer => 'Prilagođeni tajmer za spavanje';

  @override
  String get minutes => 'Minuti';

  @override
  String get enterPositiveNumber => 'Unesite broj veći od 0.';

  @override
  String get cancel => 'Otkaži';

  @override
  String get start => 'Pokreni';

  @override
  String get internetConnectionLost => 'Internet veza je prekinuta';

  @override
  String get streamStoppedResponding => 'Strim je prestao da odgovara';

  @override
  String get playbackStalled => 'Reprodukcija je zastala';

  @override
  String get playbackFailed => 'Reprodukcija nije uspela';

  @override
  String get bufferingStream => 'Učitavanje strima...';

  @override
  String get paused => 'Pauzirano';

  @override
  String durationMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minuta',
      few: '$count minuta',
      one: '$count minut',
    );
    return '$_temp0';
  }

  @override
  String durationHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sati',
      few: '$count sata',
      one: '$count sat',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours č $minutes min';
  }

  @override
  String get lessThanOneMinute => 'manje od 1 min';

  @override
  String get manualStations => 'Ručno dodate stanice';

  @override
  String get noManualStations => 'Nema ručno dodatih stanica.';

  @override
  String get batteryUsage => 'Potrošnja baterije';

  @override
  String get batteryUsageDescription =>
      'Podesite NoAds Radio na Neograničeno u Android podešavanjima.';

  @override
  String get showStationIcon => 'Prikaži ikonu stanice';

  @override
  String get showStationIconDescription =>
      'Prikaži sliku stanice u listama i traci plejera.';

  @override
  String get autoPlayNextFavorite => 'Automatski pusti sledeću omiljenu';

  @override
  String get autoPlayNextFavoriteDescription =>
      'Kada strim otkaže, pređi na sledeću omiljenu stanicu i nastavi od početka liste.';

  @override
  String get autoPlayNextFavoriteDisabledDescription =>
      'Kada strim otkaže, pređi na sledeću omiljenu stanicu i nastavi od početka liste. Dodajte najmanje dve omiljene stanice da biste uključili ovu opciju.';

  @override
  String get couldNotOpenAndroidSettings =>
      'Nije moguće otvoriti Android podešavanja aplikacije na ovom uređaju.';

  @override
  String get noRecentlyPlayedYet => 'Još nema nedavno slušanih stanica.';

  @override
  String get categoriesDescription =>
      'Dodajte koliko god kategorija želite. Samo prve 2 će biti vidljive kao kartice pri dnu.';

  @override
  String get favorites => 'Omiljene';

  @override
  String get newCategory => 'Nova kategorija';

  @override
  String get removeCategory => 'Ukloni kategoriju';

  @override
  String get addCategory => 'Dodaj kategoriju';

  @override
  String get add => 'Dodaj';

  @override
  String get deleteAll => 'Obriši sve';

  @override
  String get deleteStation => 'Obriši stanicu';

  @override
  String get deleteAllManualStationsTitle =>
      'Obrisati sve ručno dodate stanice?';

  @override
  String get deleteAllManualStationsDescription =>
      'Ovim se uklanjaju sve stanice koje ste ručno dodali.';

  @override
  String get addStation => 'Dodaj stanicu';

  @override
  String get stationName => 'Naziv stanice';

  @override
  String get stationNameHint => 'Moja stanica';

  @override
  String get streamUrl => 'URL strima';

  @override
  String get enterStationName => 'Unesite naziv stanice.';

  @override
  String get enterValidStreamUrl => 'Unesite važeći URL strima.';

  @override
  String get activeSource => 'Aktivni izvor';

  @override
  String get noSourceLoaded => 'Nijedan izvor nije učitan';

  @override
  String get stationLoadingLog => 'Dnevnik učitavanja stanica';

  @override
  String get noStationLoadingEvents =>
      'Nema zabeleženih događaja učitavanja stanica.';

  @override
  String get duplicateStations => 'Duplirane stanice';

  @override
  String duplicateStationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sakriveno je $count dupliranih stanica iz kartice Stanice',
      few: 'Sakrivene su $count duplirane stanice iz kartice Stanice',
      one: 'Sakrivena je $count duplirana stanica iz kartice Stanice',
      zero: 'Nema sakrivenih dupliranih stanica',
    );
    return '$_temp0';
  }

  @override
  String get duplicateStationByUuid => 'Duplirani UUID';

  @override
  String get duplicateStationByNameLocation => 'Duplirani naziv i lokacija';

  @override
  String duplicateStationOriginal(Object station) {
    return 'Original: $station';
  }

  @override
  String playableStationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Učitano je $count stanica',
      few: 'Učitane su $count stanice',
      one: 'Učitana je $count stanica',
    );
    return '$_temp0';
  }

  @override
  String get diaspora => 'Dijaspora';

  @override
  String get removeFavorite => 'Ukloni iz omiljenih';

  @override
  String get saveFavorite => 'Sačuvaj u omiljene';

  @override
  String get unknown => 'Nepoznato';
}

/// The translations for Serbian, using the Latin script (`sr_Latn`).
class AppLocalizationsSrLatn extends AppLocalizationsSr {
  AppLocalizationsSrLatn() : super('sr_Latn');

  @override
  String get appTitle => 'NoAds Radio';

  @override
  String get language => 'Jezik';

  @override
  String get languageDescription => 'Izaberite jezik aplikacije.';

  @override
  String get systemDefault => 'Jezik sistema';

  @override
  String get english => 'Engleski';

  @override
  String get serbianLatin => 'Srpski (latinica)';

  @override
  String get theme => 'Tema';

  @override
  String get themeDescription => 'Izaberite izgled aplikacije.';

  @override
  String get dark => 'Tamna';

  @override
  String get light => 'Svetla';

  @override
  String get chooseCountryTitle => 'Izaberite zemlju radio stanica';

  @override
  String get chooseCountryDescription =>
      'Ovaj izbor određuje koje stanice se prikazuju prve. Predlog dolazi iz podešavanja jezika uređaja i možda ne odgovara vašoj fizičkoj lokaciji.';

  @override
  String get moreCountriesLater =>
      'Kasnije možete dodati još zemalja u Podešavanjima.';

  @override
  String get selectCountry => 'Izaberite zemlju';

  @override
  String get saving => 'Čuvanje...';

  @override
  String get continueLabel => 'Nastavi';

  @override
  String get filter => 'Filtriraj';

  @override
  String get clearFilter => 'Obriši filter';

  @override
  String get offline => 'Van mreže';

  @override
  String get filterStations => 'Filtriraj stanice';

  @override
  String get more => 'Više';

  @override
  String get debugView => 'Dijagnostika';

  @override
  String get settings => 'Podešavanja';

  @override
  String get noStationsAvailable => 'Trenutno nema dostupnih stanica.';

  @override
  String get clear => 'Obriši';

  @override
  String stationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stanica',
      few: '$count stanice',
      one: '$count stanica',
      zero: 'Nema stanica',
    );
    return '$_temp0';
  }

  @override
  String filteredStationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filtriranih stanica',
      few: '$count filtrirane stanice',
      one: '$count filtrirana stanica',
      zero: 'Nema filtriranih stanica',
    );
    return '$_temp0';
  }

  @override
  String get categories => 'Kategorije';

  @override
  String get recentlyPlayed => 'Nedavno slušano';

  @override
  String get noRecentlyPlayed => 'Nema nedavno slušanih stanica.';

  @override
  String get stationCountries => 'Zemlje radio stanica';

  @override
  String get atLeastOneCountry => 'Najmanje jedna zemlja mora ostati izabrana.';

  @override
  String get diasporaCountryNote =>
      'Stanice iz dijaspore se automatski uključuju kada izaberete bilo koju zemlju bivše Jugoslavije.';

  @override
  String get selectedCountries => 'Izabrane zemlje';

  @override
  String get dragToReorder => 'Prevucite za promenu redosleda';

  @override
  String get addCountry => 'Dodaj zemlju';

  @override
  String get done => 'Gotovo';

  @override
  String get searchCountries => 'Pretraži zemlje';

  @override
  String get searchCountriesHint => 'Srbija ili RS';

  @override
  String get noCountriesAvailable => 'Nema dostupnih zemalja.';

  @override
  String get stations => 'Stanice';

  @override
  String noFavoritesInCategory(Object category) {
    return 'Još nema omiljenih stanica u kategoriji $category. Sačuvajte stanice sa kartice Stanice.';
  }

  @override
  String get nowPlaying => 'Slušate';

  @override
  String get back => 'Nazad';

  @override
  String get nothingPlaying => 'Ništa se ne reprodukuje.';

  @override
  String get previousFavorite => 'Prethodna omiljena';

  @override
  String get pause => 'Pauziraj';

  @override
  String get play => 'Pusti';

  @override
  String get nextFavorite => 'Sledeća omiljena';

  @override
  String get cast => 'Prebaci reprodukciju';

  @override
  String get castDevices => 'Cast uređaji';

  @override
  String castingTo(Object device) {
    return 'Reprodukcija na uređaju $device';
  }

  @override
  String get disconnect => 'Prekini vezu';

  @override
  String get searchingCastDevices => 'Traženje Cast uređaja...';

  @override
  String get noCastDevices =>
      'Nije pronađen nijedan Cast uređaj. Proverite da li su oba uređaja na istoj Wi-Fi mreži.';

  @override
  String get iosCastPermissionHelp =>
      'Na iPhone uređaju dozvolite pristup lokalnoj mreži u Podešavanja > Privatnost i bezbednost > Lokalna mreža > NoAds Radio, pa pokušajte ponovo.';

  @override
  String get searchAgain => 'Traži ponovo';

  @override
  String get castConnectionFailed =>
      'Povezivanje sa Cast uređajem nije uspelo.';

  @override
  String get track => 'Pesma';

  @override
  String get stream => 'Strim';

  @override
  String get genre => 'Žanr';

  @override
  String get location => 'Lokacija';

  @override
  String get tags => 'Oznake';

  @override
  String get codec => 'Kodek';

  @override
  String get bitrate => 'Brzina protoka';

  @override
  String get sleepTimer => 'Tajmer za spavanje';

  @override
  String sleepTimerWithRemaining(Object remaining) {
    return 'Tajmer za spavanje: $remaining';
  }

  @override
  String get off => 'Isključeno';

  @override
  String get custom => 'Prilagođeno';

  @override
  String get customSleepTimer => 'Prilagođeni tajmer za spavanje';

  @override
  String get minutes => 'Minuti';

  @override
  String get enterPositiveNumber => 'Unesite broj veći od 0.';

  @override
  String get cancel => 'Otkaži';

  @override
  String get start => 'Pokreni';

  @override
  String get internetConnectionLost => 'Internet veza je prekinuta';

  @override
  String get streamStoppedResponding => 'Strim je prestao da odgovara';

  @override
  String get playbackStalled => 'Reprodukcija je zastala';

  @override
  String get playbackFailed => 'Reprodukcija nije uspela';

  @override
  String get bufferingStream => 'Učitavanje strima...';

  @override
  String get paused => 'Pauzirano';

  @override
  String durationMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minuta',
      few: '$count minuta',
      one: '$count minut',
    );
    return '$_temp0';
  }

  @override
  String durationHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sati',
      few: '$count sata',
      one: '$count sat',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours č $minutes min';
  }

  @override
  String get lessThanOneMinute => 'manje od 1 min';

  @override
  String get manualStations => 'Ručno dodate stanice';

  @override
  String get noManualStations => 'Nema ručno dodatih stanica.';

  @override
  String get batteryUsage => 'Potrošnja baterije';

  @override
  String get batteryUsageDescription =>
      'Podesite NoAds Radio na Neograničeno u Android podešavanjima.';

  @override
  String get showStationIcon => 'Prikaži ikonu stanice';

  @override
  String get showStationIconDescription =>
      'Prikaži sliku stanice u listama i traci plejera.';

  @override
  String get autoPlayNextFavorite => 'Automatski pusti sledeću omiljenu';

  @override
  String get autoPlayNextFavoriteDescription =>
      'Kada strim otkaže, pređi na sledeću omiljenu stanicu i nastavi od početka liste.';

  @override
  String get autoPlayNextFavoriteDisabledDescription =>
      'Kada strim otkaže, pređi na sledeću omiljenu stanicu i nastavi od početka liste. Dodajte najmanje dve omiljene stanice da biste uključili ovu opciju.';

  @override
  String get couldNotOpenAndroidSettings =>
      'Nije moguće otvoriti Android podešavanja aplikacije na ovom uređaju.';

  @override
  String get noRecentlyPlayedYet => 'Još nema nedavno slušanih stanica.';

  @override
  String get categoriesDescription =>
      'Dodajte koliko god kategorija želite. Samo prve 2 će biti vidljive kao kartice pri dnu.';

  @override
  String get favorites => 'Omiljene';

  @override
  String get newCategory => 'Nova kategorija';

  @override
  String get removeCategory => 'Ukloni kategoriju';

  @override
  String get addCategory => 'Dodaj kategoriju';

  @override
  String get add => 'Dodaj';

  @override
  String get deleteAll => 'Obriši sve';

  @override
  String get deleteStation => 'Obriši stanicu';

  @override
  String get deleteAllManualStationsTitle =>
      'Obrisati sve ručno dodate stanice?';

  @override
  String get deleteAllManualStationsDescription =>
      'Ovim se uklanjaju sve stanice koje ste ručno dodali.';

  @override
  String get addStation => 'Dodaj stanicu';

  @override
  String get stationName => 'Naziv stanice';

  @override
  String get stationNameHint => 'Moja stanica';

  @override
  String get streamUrl => 'URL strima';

  @override
  String get enterStationName => 'Unesite naziv stanice.';

  @override
  String get enterValidStreamUrl => 'Unesite važeći URL strima.';

  @override
  String get activeSource => 'Aktivni izvor';

  @override
  String get noSourceLoaded => 'Nijedan izvor nije učitan';

  @override
  String get stationLoadingLog => 'Dnevnik učitavanja stanica';

  @override
  String get noStationLoadingEvents =>
      'Nema zabeleženih događaja učitavanja stanica.';

  @override
  String get duplicateStations => 'Duplirane stanice';

  @override
  String duplicateStationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sakriveno je $count dupliranih stanica iz kartice Stanice',
      few: 'Sakrivene su $count duplirane stanice iz kartice Stanice',
      one: 'Sakrivena je $count duplirana stanica iz kartice Stanice',
      zero: 'Nema sakrivenih dupliranih stanica',
    );
    return '$_temp0';
  }

  @override
  String get duplicateStationByUuid => 'Duplirani UUID';

  @override
  String get duplicateStationByNameLocation => 'Duplirani naziv i lokacija';

  @override
  String duplicateStationOriginal(Object station) {
    return 'Original: $station';
  }

  @override
  String playableStationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Učitano je $count stanica',
      few: 'Učitane su $count stanice',
      one: 'Učitana je $count stanica',
    );
    return '$_temp0';
  }

  @override
  String get diaspora => 'Dijaspora';

  @override
  String get removeFavorite => 'Ukloni iz omiljenih';

  @override
  String get saveFavorite => 'Sačuvaj u omiljene';

  @override
  String get unknown => 'Nepoznato';
}

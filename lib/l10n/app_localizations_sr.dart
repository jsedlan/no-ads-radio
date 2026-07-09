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
  String get language => 'Језик';

  @override
  String get languageDescription => 'Изаберите језик апликације.';

  @override
  String get systemDefault => 'Језик система';

  @override
  String get english => 'Енглески';

  @override
  String get serbianCyrillic => 'Српски (ћирилица)';

  @override
  String get serbianLatin => 'Српски (латиница)';

  @override
  String get theme => 'Тема';

  @override
  String get themeDescription => 'Изаберите изглед апликације.';

  @override
  String get dark => 'Тамна';

  @override
  String get light => 'Светла';

  @override
  String get chooseCountryTitle => 'Изаберите земљу радио станица';

  @override
  String get chooseCountryDescription =>
      'Овај избор одређује које станице се приказују прве. Предлог долази из подешавања језика уређаја и можда не одговара вашој физичкој локацији.';

  @override
  String get moreCountriesLater =>
      'Касније можете додати још земаља у Подешавањима.';

  @override
  String get selectCountry => 'Изаберите земљу';

  @override
  String get saving => 'Чување...';

  @override
  String get continueLabel => 'Настави';

  @override
  String get filter => 'Филтрирај';

  @override
  String get clearFilter => 'Обриши филтер';

  @override
  String get offline => 'Ван мреже';

  @override
  String get filterStations => 'Филтрирај станице';

  @override
  String get more => 'Више';

  @override
  String get debugView => 'Дијагностика';

  @override
  String get about => 'О апликацији';

  @override
  String get aboutDescription =>
      'NoAds Radio је једноставан радио плејер за слушање станица уживо без екрана претрпаних рекламама и сувишних додатака.';

  @override
  String get aboutNoAdsTitle => 'Без рекламног нереда';

  @override
  String get aboutNoAdsDescription =>
      'Апликација је усмерена на репродукцију и преглед станица, без банера, искачућих прозора и препорука заснованих на праћењу.';

  @override
  String get aboutStationCatalogTitle => 'Каталог станица уживо';

  @override
  String get aboutStationCatalogDescription =>
      'Станице се учитавају из каталога апликације и могу да се филтрирају по земљи, чувају као омиљене или додају ручно.';

  @override
  String get aboutPrivacyTitle => 'Уз пажњу према приватности';

  @override
  String get aboutPrivacyDescription =>
      'Подешавања, омиљене станице, ручно додате станице и недавно слушане станице чувају се на овом уређају.';

  @override
  String appVersion(Object version) {
    return 'Верзија $version';
  }

  @override
  String get settings => 'Подешавања';

  @override
  String get noStationsAvailable => 'Тренутно нема доступних станица.';

  @override
  String get clear => 'Обриши';

  @override
  String stationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count станица',
      few: '$count станице',
      one: '$count станица',
      zero: 'Нема станица',
    );
    return '$_temp0';
  }

  @override
  String filteredStationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count филтрираних станица',
      few: '$count филтриране станице',
      one: '$count филтрирана станица',
      zero: 'Нема филтрираних станица',
    );
    return '$_temp0';
  }

  @override
  String get categories => 'Категорије';

  @override
  String get recentlyPlayed => 'Недавно слушано';

  @override
  String get noRecentlyPlayed => 'Нема недавно слушаних станица.';

  @override
  String get stationCountries => 'Земље радио станица';

  @override
  String get atLeastOneCountry => 'Најмање једна земља мора остати изабрана.';

  @override
  String get diasporaCountryNote =>
      'Станице из дијаспоре се аутоматски укључују када изаберете било коју земљу бивше Југославије.';

  @override
  String get selectedCountries => 'Изабране земље';

  @override
  String get dragToReorder => 'Превуците за промену редоследа';

  @override
  String get addCountry => 'Додај земљу';

  @override
  String get done => 'Готово';

  @override
  String get searchCountries => 'Претражи земље';

  @override
  String get searchCountriesHint => 'Србија или RS';

  @override
  String get noCountriesAvailable => 'Нема доступних земаља.';

  @override
  String get stations => 'Станице';

  @override
  String noFavoritesInCategory(Object category) {
    return 'Још нема омиљених станица у категорији $category. Сачувајте станице са картице Станице.';
  }

  @override
  String get nowPlaying => 'Слушате';

  @override
  String get back => 'Назад';

  @override
  String get nothingPlaying => 'Ништа се не репродукује.';

  @override
  String get previousFavorite => 'Претходна омиљена';

  @override
  String get pause => 'Паузирај';

  @override
  String get play => 'Пусти';

  @override
  String get nextFavorite => 'Следећа омиљена';

  @override
  String get cast => 'Пребаци репродукцију';

  @override
  String get castDevices => 'Cast уређаји';

  @override
  String castingTo(Object device) {
    return 'Репродукција на уређају $device';
  }

  @override
  String get disconnect => 'Прекини везу';

  @override
  String get searchingCastDevices => 'Тражење Cast уређаја...';

  @override
  String get noCastDevices =>
      'Није пронађен ниједан Cast уређај. Проверите да ли су оба уређаја на истој Wi-Fi мрежи.';

  @override
  String get iosCastPermissionHelp =>
      'На iPhone уређају дозволите приступ локалној мрежи у Подешавања > Приватност и безбедност > Локална мрежа > NoAds Radio, па покушајте поново.';

  @override
  String get searchAgain => 'Тражи поново';

  @override
  String get castConnectionFailed => 'Повезивање са Cast уређајем није успело.';

  @override
  String get track => 'Песма';

  @override
  String get stream => 'Стрим';

  @override
  String get genre => 'Жанр';

  @override
  String get location => 'Локација';

  @override
  String get tags => 'Ознаке';

  @override
  String get codec => 'Кодек';

  @override
  String get bitrate => 'Брзина протока';

  @override
  String get sleepTimer => 'Тајмер за спавање';

  @override
  String sleepTimerWithRemaining(Object remaining) {
    return 'Тајмер за спавање: $remaining';
  }

  @override
  String get off => 'Искључено';

  @override
  String get custom => 'Прилагођено';

  @override
  String get customSleepTimer => 'Прилагођени тајмер за спавање';

  @override
  String get minutes => 'Минути';

  @override
  String get enterPositiveNumber => 'Унесите број већи од 0.';

  @override
  String get cancel => 'Откажи';

  @override
  String get start => 'Покрени';

  @override
  String get internetConnectionLost => 'Интернет веза је прекинута';

  @override
  String get streamStoppedResponding => 'Стрим је престао да одговара';

  @override
  String get playbackStalled => 'Репродукција је застала';

  @override
  String get playbackFailed => 'Репродукција није успела';

  @override
  String get bufferingStream => 'Учитавање стрима...';

  @override
  String get paused => 'Паузирано';

  @override
  String durationMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count минута',
      few: '$count минута',
      one: '$count минут',
    );
    return '$_temp0';
  }

  @override
  String durationHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сати',
      few: '$count сата',
      one: '$count сат',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours ч $minutes мин';
  }

  @override
  String get lessThanOneMinute => 'мање од 1 мин';

  @override
  String get manualStations => 'Ручно додате станице';

  @override
  String get noManualStations => 'Нема ручно додатих станица.';

  @override
  String get batteryUsage => 'Потрошња батерије';

  @override
  String get batteryUsageDescription =>
      'Подесите NoAds Radio на Неограничено у Android подешавањима.';

  @override
  String get showStationIcon => 'Прикажи икону станице';

  @override
  String get showStationIconDescription =>
      'Прикажи слику станице у листама и траци плејера.';

  @override
  String get autoPlayNextFavorite => 'Аутоматски пусти следећу омиљену';

  @override
  String get autoPlayNextFavoriteDescription =>
      'Када стрим откаже, пређи на следећу омиљену станицу и настави од почетка листе.';

  @override
  String get autoPlayNextFavoriteDisabledDescription =>
      'Када стрим откаже, пређи на следећу омиљену станицу и настави од почетка листе. Додајте најмање две омиљене станице да бисте укључили ову опцију.';

  @override
  String get couldNotOpenAndroidSettings =>
      'Није могуће отворити Android подешавања апликације на овом уређају.';

  @override
  String get noRecentlyPlayedYet => 'Још нема недавно слушаних станица.';

  @override
  String get categoriesDescription =>
      'Додајте колико год категорија желите. Само прве 2 ће бити видљиве као картице при дну.';

  @override
  String get favorites => 'Омиљене';

  @override
  String get newCategory => 'Нова категорија';

  @override
  String get removeCategory => 'Уклони категорију';

  @override
  String get addCategory => 'Додај категорију';

  @override
  String get add => 'Додај';

  @override
  String get deleteAll => 'Обриши све';

  @override
  String get deleteStation => 'Обриши станицу';

  @override
  String get deleteAllManualStationsTitle =>
      'Обрисати све ручно додате станице?';

  @override
  String get deleteAllManualStationsDescription =>
      'Овим се уклањају све станице које сте ручно додали.';

  @override
  String get addStation => 'Додај станицу';

  @override
  String get stationName => 'Назив станице';

  @override
  String get stationNameHint => 'Моја станица';

  @override
  String get streamUrl => 'URL стрима';

  @override
  String get enterStationName => 'Унесите назив станице.';

  @override
  String get enterValidStreamUrl => 'Унесите важећи URL стрима.';

  @override
  String get activeSource => 'Активни извор';

  @override
  String get noSourceLoaded => 'Ниједан извор није учитан';

  @override
  String get stationLoadingLog => 'Дневник учитавања станица';

  @override
  String get noStationLoadingEvents =>
      'Нема забележених догађаја учитавања станица.';

  @override
  String get duplicateStations => 'Дуплиране станице';

  @override
  String duplicateStationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Сакривено је $count дуплираних станица из картице Станице',
      few: 'Сакривене су $count дуплиране станице из картице Станице',
      one: 'Сакривена је $count дуплирана станица из картице Станице',
      zero: 'Нема сакривених дуплираних станица',
    );
    return '$_temp0';
  }

  @override
  String get duplicateStationByUuid => 'Дуплирани UUID';

  @override
  String get duplicateStationByNameLocation => 'Дуплирани назив и локација';

  @override
  String duplicateStationOriginal(Object station) {
    return 'Оригинал: $station';
  }

  @override
  String playableStationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Учитано је $count станица',
      few: 'Учитане су $count станице',
      one: 'Учитана је $count станица',
    );
    return '$_temp0';
  }

  @override
  String get diaspora => 'Дијаспора';

  @override
  String get removeFavorite => 'Уклони из омиљених';

  @override
  String get saveFavorite => 'Сачувај у омиљене';

  @override
  String get unknown => 'Непознато';

  @override
  String get stationTag743d597bbf => 'ABC вести';

  @override
  String get stationTagd22aa9e385 => 'савремена музика за одрасле';

  @override
  String get stationTag4eb9485df2 => 'хитови за одрасле';

  @override
  String get stationTag757216b974 => 'поп за одрасле';

  @override
  String get stationTagce0bf8ffc6 => 'афрички хип-хоп';

  @override
  String get stationTag8a78fd32f3 => 'афропоп';

  @override
  String get stationTag816d63e63c => 'алтернативна';

  @override
  String get stationTag125656fd8e => 'алтернативни кантри';

  @override
  String get stationTag5caa40d242 => 'алтернативни рок';

  @override
  String get stationTag9f8bc859e5 => 'амбијентална';

  @override
  String get stationTag11a3e059c6 => 'аниме';

  @override
  String get stationTag1187c0b5e4 => 'аргентина';

  @override
  String get stationTagbc3aa419b3 => 'аудио књиге';

  @override
  String get stationTagd7a9347927 => 'аугсбург';

  @override
  String get stationTagf0741425e4 => 'авангарда';

  @override
  String get stationTag365f20c1d5 => 'баладе';

  @override
  String get stationTag05f153a6d9 => 'лепа музика';

  @override
  String get stationTag086547e7de => 'биг бенд';

  @override
  String get stationTag2e00f41599 => 'блуз';

  @override
  String get stationTagf4e6d8a342 => 'блуз рок';

  @override
  String get stationTagb7e0f1cd5d => 'боливуд';

  @override
  String get stationTag0ef0580339 => 'боса нова';

  @override
  String get stationTag942f10e1d6 => 'буенос аирес';

  @override
  String get stationTag11a783a9d6 => 'пословне вести';

  @override
  String get stationTag75fad5e6ba => 'пословни програми';

  @override
  String get stationTag72af4739cc => 'шансона';

  @override
  String get stationTag3c1836f3a6 => 'топ-листе';

  @override
  String get stationTag4e18273733 => 'опуштајућа';

  @override
  String get stationTagab1d69daba => 'опуштајући хаус';

  @override
  String get stationTag46a59517d4 => 'опуштање';

  @override
  String get stationTagc8d73989e5 => 'хорска';

  @override
  String get stationTag2314b2e3a4 => 'хришћанска';

  @override
  String get stationTag56d7b69b1b => 'хришћанска музика';

  @override
  String get stationTag46e505c983 => 'божићна';

  @override
  String get stationTag290b75188d => 'класика';

  @override
  String get stationTag6af6b14ed4 => 'класични блуз';

  @override
  String get stationTag28c76c07d1 => 'класични кантри';

  @override
  String get stationTagda3dbd8402 => 'класични хитови';

  @override
  String get stationTag066705657d => 'класични џез';

  @override
  String get stationTage09e25c16c => 'класични рок';

  @override
  String get stationTag4a19573b7e => 'класична';

  @override
  String get stationTag43021a2092 => 'класична музика';

  @override
  String get stationTag9273bf33ff => 'класици';

  @override
  String get stationTage9933e8a75 => 'клуб';

  @override
  String get stationTaga8c0c2e0be => 'клупски денс';

  @override
  String get stationTag8d92575952 => 'клупска музика';

  @override
  String get stationTag3e56e6a43d => 'комедија';

  @override
  String get stationTage6aed0bced => 'радио заједнице';

  @override
  String get stationTag42dc7e4f3f => 'конзервативно';

  @override
  String get stationTag911e56c69e => 'завере';

  @override
  String get stationTagb68c19108a => 'теорије завере';

  @override
  String get stationTag49eafe93ae => 'савремена';

  @override
  String get stationTagdda0f9acde => 'савремена хришћанска';

  @override
  String get stationTag13fd6746fe => 'савремени кантри';

  @override
  String get stationTag40eb1a9b87 => 'савремени хит радио';

  @override
  String get stationTagc567a18aa0 => 'савремени џез';

  @override
  String get stationTag8e68b3e5af => 'кантри';

  @override
  String get stationTag141546aac4 => 'кантри блуз';

  @override
  String get stationTagd5a23debab => 'кантри музика';

  @override
  String get stationTag5c685d4499 => 'кантри поп';

  @override
  String get stationTag83ac283371 => 'кантри рок';

  @override
  String get stationTag5f58355136 => 'културно';

  @override
  String get stationTag7820e1d879 => 'културне вести';

  @override
  String get stationTag8f2e7cd784 => 'култура';

  @override
  String get stationTag74b518ed55 => 'денс';

  @override
  String get stationTage8de1377be => 'денсхол';

  @override
  String get stationTagd8362a14e6 => 'немачки';

  @override
  String get stationTag95c152a176 => 'дечија';

  @override
  String get stationTag9a1c2a67fc => 'диско';

  @override
  String get stationTag05d80cd9c4 => 'DJ миксеви';

  @override
  String get stationTag49c149dc66 => 'DJ ремикс';

  @override
  String get stationTag91dbf3c2a7 => 'DJ сетови';

  @override
  String get stationTagf924b9625d => 'спорији темпо';

  @override
  String get stationTag63b1298947 => 'драма';

  @override
  String get stationTage69a4f2256 => 'духовна';

  @override
  String get stationTag52edaa4e68 => 'лагано слушање';

  @override
  String get stationTage3164293ed => 'еклектична';

  @override
  String get stationTagb4d21f8747 => 'електро';

  @override
  String get stationTag3797c42f9d => 'електронска';

  @override
  String get stationTag043f28f4b5 => 'електронска денс музика';

  @override
  String get stationTag4dc773db68 => 'електроника';

  @override
  String get stationTagc32b941d4e => 'забава';

  @override
  String get stationTag8b47d2a821 => 'етно';

  @override
  String get stationTag30e382c6b8 => 'еуроденс';

  @override
  String get stationTag59acab5d0a => 'евергрин';

  @override
  String get stationTag204994198c => 'евергрини';

  @override
  String get stationTag2216470a6a => 'експериментална';

  @override
  String get stationTag2d02ecf89a => 'народна';

  @override
  String get stationTagd2330d0952 => 'слободни џез';

  @override
  String get stationTag30ec1e5ee8 => 'фанк';

  @override
  String get stationTagdbbbceb206 => 'фанки';

  @override
  String get stationTag4c2f65997d => 'гараж';

  @override
  String get stationTagdfe2db7497 => 'опште';

  @override
  String get stationTag5eaf52a9b8 => 'глобал радио';

  @override
  String get stationTagcf75b6e07e => 'госпел';

  @override
  String get stationTagb9b7a52438 => 'госпел музика';

  @override
  String get stationTag6b477d6b44 => 'гусле';

  @override
  String get stationTag21d286310f => 'теретана';

  @override
  String get stationTagdd1b58d84e => 'хард боп';

  @override
  String get stationTag1dad8d9def => 'хард рок';

  @override
  String get stationTaga2a76210fb => 'хард техно';

  @override
  String get stationTag40e6f3039d => 'хеви метал';

  @override
  String get stationTag1ab40b9589 => 'хип-хоп';

  @override
  String get stationTagd45000b24b => 'хип-хоп';

  @override
  String get stationTagac806dd8ce => 'хип-хоп';

  @override
  String get stationTag80d6b4b236 => 'хитови';

  @override
  String get stationTagc748c763b9 => 'хитови';

  @override
  String get stationTag1b602c45be => 'празнична';

  @override
  String get stationTag5be93480bd => 'хаус';

  @override
  String get stationTagf6f30f107a => 'хумор';

  @override
  String get stationTag5e92ba075a => 'хумор';

  @override
  String get stationTagd085829c2c => 'химне';

  @override
  String get stationTage33fc333d4 => 'инди';

  @override
  String get stationTag93604d928b => 'инди поп';

  @override
  String get stationTag0c7bc23252 => 'инди рок';

  @override
  String get stationTag59bd0a3ff4 => 'информације';

  @override
  String get stationTag83dd9d6af4 => 'информације';

  @override
  String get stationTag48d513fd88 => 'инфотаинмент';

  @override
  String get stationTag070db54a6f => 'инструментална';

  @override
  String get stationTag4d0fb475b2 => 'интернет';

  @override
  String get stationTag25c4ae7fd8 => 'интернет радио';

  @override
  String get stationTag0313752b11 => 'интернет-радио';

  @override
  String get stationTagdaf14c7984 => 'италијанска';

  @override
  String get stationTag337cf35e7a => 'италијански поп';

  @override
  String get stationTag7b8af9235d => 'итало';

  @override
  String get stationTag04f65fbe0d => 'итало денс';

  @override
  String get stationTag9dfb478f68 => 'итало диско';

  @override
  String get stationTag71fddd2ecc => 'изворна';

  @override
  String get stationTag6abc743bbd => 'џез';

  @override
  String get stationTag1aee2a66e1 => 'џез';

  @override
  String get stationTag5212351459 => 'Ј-поп';

  @override
  String get stationTagb37f602962 => 'класична';

  @override
  String get stationTag382a11c991 => 'крајишка';

  @override
  String get stationTag6504358a41 => 'култура';

  @override
  String get stationTag9706e2b789 => 'лагана';

  @override
  String get stationTage2d35ad940 => 'латино';

  @override
  String get stationTagd87f9ff79e => 'латино музика';

  @override
  String get stationTag045615950e => 'латино поп';

  @override
  String get stationTag9f2222b7fb => 'латино';

  @override
  String get stationTag1e2f761d51 => 'животни стил';

  @override
  String get stationTag98aadb3708 => 'уживо';

  @override
  String get stationTag14039d1152 => 'спорт уживо';

  @override
  String get stationTag939bb46a04 => 'локално';

  @override
  String get stationTag43a88022d6 => 'локална музика';

  @override
  String get stationTag442ac2cf88 => 'локалне вести';

  @override
  String get stationTagf06015be10 => 'локални радио';

  @override
  String get stationTagf336da1d34 => 'љубавне песме';

  @override
  String get stationTage3493be66f => 'мејнстрим';

  @override
  String get stationTag9d983dd224 => 'мејнстрим џез';

  @override
  String get stationTag4963bb0591 => 'метал';

  @override
  String get stationTagff8b611a89 => 'мексичка музика';

  @override
  String get stationTagb0264c19da => 'блискоисточна музика';

  @override
  String get stationTag5c4821749c => 'минимал';

  @override
  String get stationTag629ead9591 => 'минимал техно';

  @override
  String get stationTag38743fbb44 => 'микс';

  @override
  String get stationTagb09be85d51 => 'модерна';

  @override
  String get stationTagc670bbfd94 => 'модерни рок';

  @override
  String get stationTag3a01be1724 => 'музика';

  @override
  String get stationTagfe0feb3c23 => 'мјузикл';

  @override
  String get stationTag489d08ab84 => 'музика за децу';

  @override
  String get stationTag71c1d51400 => 'народна';

  @override
  String get stationTag996676018c => 'народна - етно';

  @override
  String get stationTagba1d431793 => 'национално';

  @override
  String get stationTag6d150cec97 => 'нови талас';

  @override
  String get stationTag3c6bdcddc9 => 'вести';

  @override
  String get stationTag54ac9a2e58 => 'радио вести';

  @override
  String get stationTagca29a260a8 => 'вести и разговор';

  @override
  String get stationTag81f7a3d9ae => 'некомерцијално';

  @override
  String get stationTaga6b8fe2ef4 => 'музика без прекида';

  @override
  String get stationTaga67edc88d9 => 'носталгија';

  @override
  String get stationTag869f15a237 => 'вести';

  @override
  String get stationTag5d6687996d => 'стари хитови';

  @override
  String get stationTag2dbc2fd235 => 'онлајн';

  @override
  String get stationTag6feda84dcc => 'опера';

  @override
  String get stationTag8341873a88 => 'опус';

  @override
  String get stationTag03c8ed27df => 'оркестарска';

  @override
  String get stationTag84beb18831 => 'журка';

  @override
  String get stationTag3f4667905c => 'хитови за журку';

  @override
  String get stationTagee848a3b5b => 'полиција';

  @override
  String get stationTagae4fd29aa1 => 'политички разговор';

  @override
  String get stationTag4c5fd84e89 => 'политика';

  @override
  String get stationTag4f197c99a7 => 'поп';

  @override
  String get stationTag122fb23bc6 => 'поп денс';

  @override
  String get stationTag0be9a78da5 => 'поп латино';

  @override
  String get stationTag9eda0e7aa9 => 'поп музика';

  @override
  String get stationTagbb2c038983 => 'поп рок';

  @override
  String get stationTag74c72544e0 => 'поп рок';

  @override
  String get stationTag136dfa5b33 => 'прогресивни хаус';

  @override
  String get stationTaga2f77c10a5 => 'јавни радио';

  @override
  String get stationTag71d689362a => 'јавни сервис';

  @override
  String get stationTag5940e3137d => 'панк';

  @override
  String get stationTagcb0cde801b => 'R&B';

  @override
  String get stationTag6e2a486fe3 => 'р&б/урбан';

  @override
  String get stationTag5c4a513dbf => 'R&B';

  @override
  String get stationTagd432c3525b => 'радио';

  @override
  String get stationTag8390ac37de => 'радио онлине';

  @override
  String get stationTag1bf1b43494 => 'радиорама';

  @override
  String get stationTag51c4ccfd6b => 'реп';

  @override
  String get stationTag914bdbfd48 => 'рап хипхоп рнб';

  @override
  String get stationTag0615591f84 => 'реге';

  @override
  String get stationTag65013ec4e5 => 'регетон';

  @override
  String get stationTag197caeb8b5 => 'регионално';

  @override
  String get stationTaga6d888f965 => 'регионални радио';

  @override
  String get stationTag63bb094ca4 => 'опуштање';

  @override
  String get stationTagb912a11ddd => 'опуштање';

  @override
  String get stationTag6e93871ac7 => 'опуштајуће';

  @override
  String get stationTagbbde763cc0 => 'ремикс';

  @override
  String get stationTag4c742a2314 => 'ретро';

  @override
  String get stationTagf2792fa06d => 'R&B';

  @override
  String get stationTag38464bf083 => 'рок';

  @override
  String get stationTag17c8217f23 => 'рокенрол';

  @override
  String get stationTag5b9265ef9f => 'рокабили';

  @override
  String get stationTag346f5986a9 => 'романтична';

  @override
  String get stationTag17d7cc4d9a => 'руски поп';

  @override
  String get stationTagb36ad30593 => 'самба';

  @override
  String get stationTag64fd638390 => 'сезонска';

  @override
  String get stationTagf81ac68eee => 'српска музика';

  @override
  String get stationTag3aa9adbbb4 => 'ска';

  @override
  String get stationTagc3ca5f7873 => 'спавање';

  @override
  String get stationTag6c021501ca => 'спори рок';

  @override
  String get stationTagc0c6d93fe3 => 'лагана музика';

  @override
  String get stationTagc5c1fe26d5 => 'лагани поп';

  @override
  String get stationTag3af8919a33 => 'лагани рок';

  @override
  String get stationTag0867322e7c => 'соул';

  @override
  String get stationTag3e4ef17728 => 'звуци природе';

  @override
  String get stationTagf3690b9c34 => 'говорни програм';

  @override
  String get stationTag8ab6a8a0cf => 'спорт';

  @override
  String get stationTag150a8af76a => 'спорт';

  @override
  String get stationTag7899b8b3d9 => 'спортске вести';

  @override
  String get stationTag4c5218bd29 => 'спортски разговор';

  @override
  String get stationTag0b1ecf7216 => 'староградска';

  @override
  String get stationTag723f4e1ce3 => 'свинг';

  @override
  String get stationTage55e91b2cc => 'разговор';

  @override
  String get stationTag5108191aa3 => 'говорни радио';

  @override
  String get stationTage405fa83fe => 'техно';

  @override
  String get stationTag27d50b6f9a => 'топ-листе';

  @override
  String get stationTag795bbda660 => 'топ хитови';

  @override
  String get stationTag7f1345c21a => 'тренс';

  @override
  String get stationTage6d307367a => 'треп';

  @override
  String get stationTagad3d12ae13 => 'трип хоп';

  @override
  String get stationTagba7a82a981 => 'урбано';

  @override
  String get stationTag09cdd5dd4b => 'урбано';

  @override
  String get stationTag84942e2fd1 => 'уживо';

  @override
  String get stationTag75b4d7d721 => 'разноврсно';

  @override
  String get stationTag21e7a8ba50 => 'разноврсно';

  @override
  String get stationTage609aae6c8 => 'вести';

  @override
  String get stationTag0be9098c7e => 'винтиџ';

  @override
  String get stationTagbf6e51973d => 'винил';

  @override
  String get stationTag91b7e90635 => 'влашка';

  @override
  String get stationTag7c211433f0 => 'свет';

  @override
  String get stationTag3c405b7c0e => 'музика света';

  @override
  String get stationTag7b0ac581fe => 'светске вести';

  @override
  String get stationTagf9925d1162 => 'млади';

  @override
  String get stationTag9de3eede6a => 'забавна';

  @override
  String get stationTaga712aa0f9d => 'аудио књиге';

  @override
  String get stationTagd341e6e288 => 'за децу';

  @override
  String get stationTag6e0dc4349c => 'литература';

  @override
  String get stationTagd42e4f9f15 => 'политика';

  @override
  String get stationTag2ca9d5c635 => 'поп';

  @override
  String get stationTagb5cbcd9cbc => 'рок';

  @override
  String get stationTagb5f9fa4f69 => 'етно';
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
  String get serbianCyrillic => 'Srpski (ćirilica)';

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
  String get about => 'O aplikaciji';

  @override
  String get aboutDescription =>
      'NoAds Radio je jednostavan radio plejer za slušanje stanica uživo bez ekrana pretrpanih reklamama i suvišnih dodataka.';

  @override
  String get aboutNoAdsTitle => 'Bez reklamnog nereda';

  @override
  String get aboutNoAdsDescription =>
      'Aplikacija je usmerena na reprodukciju i pregled stanica, bez banera, iskačućih prozora i preporuka zasnovanih na praćenju.';

  @override
  String get aboutStationCatalogTitle => 'Katalog stanica uživo';

  @override
  String get aboutStationCatalogDescription =>
      'Stanice se učitavaju iz kataloga aplikacije i mogu da se filtriraju po zemlji, čuvaju kao omiljene ili dodaju ručno.';

  @override
  String get aboutPrivacyTitle => 'Uz pažnju prema privatnosti';

  @override
  String get aboutPrivacyDescription =>
      'Podešavanja, omiljene stanice, ručno dodate stanice i nedavno slušane stanice čuvaju se na ovom uređaju.';

  @override
  String appVersion(Object version) {
    return 'Verzija $version';
  }

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

  @override
  String get stationTag743d597bbf => 'ABC vesti';

  @override
  String get stationTagd22aa9e385 => 'savremena muzika za odrasle';

  @override
  String get stationTag4eb9485df2 => 'hitovi za odrasle';

  @override
  String get stationTag757216b974 => 'pop za odrasle';

  @override
  String get stationTagce0bf8ffc6 => 'afrički hip-hop';

  @override
  String get stationTag8a78fd32f3 => 'afropop';

  @override
  String get stationTag816d63e63c => 'alternativna';

  @override
  String get stationTag125656fd8e => 'alternativni kantri';

  @override
  String get stationTag5caa40d242 => 'alternativni rok';

  @override
  String get stationTag9f8bc859e5 => 'ambijentalna';

  @override
  String get stationTag11a3e059c6 => 'anime';

  @override
  String get stationTag1187c0b5e4 => 'argentina';

  @override
  String get stationTagbc3aa419b3 => 'audio knjige';

  @override
  String get stationTagd7a9347927 => 'augsburg';

  @override
  String get stationTagf0741425e4 => 'avangarda';

  @override
  String get stationTag365f20c1d5 => 'balade';

  @override
  String get stationTag05f153a6d9 => 'lepa muzika';

  @override
  String get stationTag086547e7de => 'big bend';

  @override
  String get stationTag2e00f41599 => 'bluz';

  @override
  String get stationTagf4e6d8a342 => 'bluz rok';

  @override
  String get stationTagb7e0f1cd5d => 'bolivud';

  @override
  String get stationTag0ef0580339 => 'bosa nova';

  @override
  String get stationTag942f10e1d6 => 'buenos aires';

  @override
  String get stationTag11a783a9d6 => 'poslovne vesti';

  @override
  String get stationTag75fad5e6ba => 'poslovni programi';

  @override
  String get stationTag72af4739cc => 'šansona';

  @override
  String get stationTag3c1836f3a6 => 'top-liste';

  @override
  String get stationTag4e18273733 => 'opuštajuća';

  @override
  String get stationTagab1d69daba => 'opuštajući haus';

  @override
  String get stationTag46a59517d4 => 'opuštanje';

  @override
  String get stationTagc8d73989e5 => 'horska';

  @override
  String get stationTag2314b2e3a4 => 'hrišćanska';

  @override
  String get stationTag56d7b69b1b => 'hrišćanska muzika';

  @override
  String get stationTag46e505c983 => 'božićna';

  @override
  String get stationTag290b75188d => 'klasika';

  @override
  String get stationTag6af6b14ed4 => 'klasični bluz';

  @override
  String get stationTag28c76c07d1 => 'klasični kantri';

  @override
  String get stationTagda3dbd8402 => 'klasični hitovi';

  @override
  String get stationTag066705657d => 'klasični džez';

  @override
  String get stationTage09e25c16c => 'klasični rok';

  @override
  String get stationTag4a19573b7e => 'klasična';

  @override
  String get stationTag43021a2092 => 'klasična muzika';

  @override
  String get stationTag9273bf33ff => 'klasici';

  @override
  String get stationTage9933e8a75 => 'klub';

  @override
  String get stationTaga8c0c2e0be => 'klupski dens';

  @override
  String get stationTag8d92575952 => 'klupska muzika';

  @override
  String get stationTag3e56e6a43d => 'komedija';

  @override
  String get stationTage6aed0bced => 'radio zajednice';

  @override
  String get stationTag42dc7e4f3f => 'konzervativno';

  @override
  String get stationTag911e56c69e => 'zavere';

  @override
  String get stationTagb68c19108a => 'teorije zavere';

  @override
  String get stationTag49eafe93ae => 'savremena';

  @override
  String get stationTagdda0f9acde => 'savremena hrišćanska';

  @override
  String get stationTag13fd6746fe => 'savremeni kantri';

  @override
  String get stationTag40eb1a9b87 => 'savremeni hit radio';

  @override
  String get stationTagc567a18aa0 => 'savremeni džez';

  @override
  String get stationTag8e68b3e5af => 'kantri';

  @override
  String get stationTag141546aac4 => 'kantri bluz';

  @override
  String get stationTagd5a23debab => 'kantri muzika';

  @override
  String get stationTag5c685d4499 => 'kantri pop';

  @override
  String get stationTag83ac283371 => 'kantri rok';

  @override
  String get stationTag5f58355136 => 'kulturno';

  @override
  String get stationTag7820e1d879 => 'kulturne vesti';

  @override
  String get stationTag8f2e7cd784 => 'kultura';

  @override
  String get stationTag74b518ed55 => 'dens';

  @override
  String get stationTage8de1377be => 'denshol';

  @override
  String get stationTagd8362a14e6 => 'nemački';

  @override
  String get stationTag95c152a176 => 'dečija';

  @override
  String get stationTag9a1c2a67fc => 'disko';

  @override
  String get stationTag05d80cd9c4 => 'DJ miksevi';

  @override
  String get stationTag49c149dc66 => 'DJ remiks';

  @override
  String get stationTag91dbf3c2a7 => 'DJ setovi';

  @override
  String get stationTagf924b9625d => 'sporiji tempo';

  @override
  String get stationTag63b1298947 => 'drama';

  @override
  String get stationTage69a4f2256 => 'duhovna';

  @override
  String get stationTag52edaa4e68 => 'lagano slušanje';

  @override
  String get stationTage3164293ed => 'eklektična';

  @override
  String get stationTagb4d21f8747 => 'elektro';

  @override
  String get stationTag3797c42f9d => 'elektronska';

  @override
  String get stationTag043f28f4b5 => 'elektronska dens muzika';

  @override
  String get stationTag4dc773db68 => 'elektronika';

  @override
  String get stationTagc32b941d4e => 'zabava';

  @override
  String get stationTag8b47d2a821 => 'etno';

  @override
  String get stationTag30e382c6b8 => 'eurodens';

  @override
  String get stationTag59acab5d0a => 'evergrin';

  @override
  String get stationTag204994198c => 'evergrini';

  @override
  String get stationTag2216470a6a => 'eksperimentalna';

  @override
  String get stationTag2d02ecf89a => 'narodna';

  @override
  String get stationTagd2330d0952 => 'slobodni džez';

  @override
  String get stationTag30ec1e5ee8 => 'fank';

  @override
  String get stationTagdbbbceb206 => 'fanki';

  @override
  String get stationTag4c2f65997d => 'garaž';

  @override
  String get stationTagdfe2db7497 => 'opšte';

  @override
  String get stationTag5eaf52a9b8 => 'global radio';

  @override
  String get stationTagcf75b6e07e => 'gospel';

  @override
  String get stationTagb9b7a52438 => 'gospel muzika';

  @override
  String get stationTag6b477d6b44 => 'gusle';

  @override
  String get stationTag21d286310f => 'teretana';

  @override
  String get stationTagdd1b58d84e => 'hard bop';

  @override
  String get stationTag1dad8d9def => 'hard rok';

  @override
  String get stationTaga2a76210fb => 'hard tehno';

  @override
  String get stationTag40e6f3039d => 'hevi metal';

  @override
  String get stationTag1ab40b9589 => 'hip-hop';

  @override
  String get stationTagd45000b24b => 'hip-hop';

  @override
  String get stationTagac806dd8ce => 'hip-hop';

  @override
  String get stationTag80d6b4b236 => 'hitovi';

  @override
  String get stationTagc748c763b9 => 'hitovi';

  @override
  String get stationTag1b602c45be => 'praznična';

  @override
  String get stationTag5be93480bd => 'haus';

  @override
  String get stationTagf6f30f107a => 'humor';

  @override
  String get stationTag5e92ba075a => 'humor';

  @override
  String get stationTagd085829c2c => 'himne';

  @override
  String get stationTage33fc333d4 => 'indi';

  @override
  String get stationTag93604d928b => 'indi pop';

  @override
  String get stationTag0c7bc23252 => 'indi rok';

  @override
  String get stationTag59bd0a3ff4 => 'informacije';

  @override
  String get stationTag83dd9d6af4 => 'informacije';

  @override
  String get stationTag48d513fd88 => 'infotainment';

  @override
  String get stationTag070db54a6f => 'instrumentalna';

  @override
  String get stationTag4d0fb475b2 => 'internet';

  @override
  String get stationTag25c4ae7fd8 => 'internet radio';

  @override
  String get stationTag0313752b11 => 'internet-radio';

  @override
  String get stationTagdaf14c7984 => 'italijanska';

  @override
  String get stationTag337cf35e7a => 'italijanski pop';

  @override
  String get stationTag7b8af9235d => 'italo';

  @override
  String get stationTag04f65fbe0d => 'italo dens';

  @override
  String get stationTag9dfb478f68 => 'italo disko';

  @override
  String get stationTag71fddd2ecc => 'izvorna';

  @override
  String get stationTag6abc743bbd => 'džez';

  @override
  String get stationTag1aee2a66e1 => 'džez';

  @override
  String get stationTag5212351459 => 'J-pop';

  @override
  String get stationTagb37f602962 => 'klasična';

  @override
  String get stationTag382a11c991 => 'krajiška';

  @override
  String get stationTag6504358a41 => 'kultura';

  @override
  String get stationTag9706e2b789 => 'lagana';

  @override
  String get stationTage2d35ad940 => 'latino';

  @override
  String get stationTagd87f9ff79e => 'latino muzika';

  @override
  String get stationTag045615950e => 'latino pop';

  @override
  String get stationTag9f2222b7fb => 'latino';

  @override
  String get stationTag1e2f761d51 => 'životni stil';

  @override
  String get stationTag98aadb3708 => 'uživo';

  @override
  String get stationTag14039d1152 => 'sport uživo';

  @override
  String get stationTag939bb46a04 => 'lokalno';

  @override
  String get stationTag43a88022d6 => 'lokalna muzika';

  @override
  String get stationTag442ac2cf88 => 'lokalne vesti';

  @override
  String get stationTagf06015be10 => 'lokalni radio';

  @override
  String get stationTagf336da1d34 => 'ljubavne pesme';

  @override
  String get stationTage3493be66f => 'mejnstrim';

  @override
  String get stationTag9d983dd224 => 'mejnstrim džez';

  @override
  String get stationTag4963bb0591 => 'metal';

  @override
  String get stationTagff8b611a89 => 'meksička muzika';

  @override
  String get stationTagb0264c19da => 'bliskoistočna muzika';

  @override
  String get stationTag5c4821749c => 'minimal';

  @override
  String get stationTag629ead9591 => 'minimal tehno';

  @override
  String get stationTag38743fbb44 => 'miks';

  @override
  String get stationTagb09be85d51 => 'moderna';

  @override
  String get stationTagc670bbfd94 => 'moderni rok';

  @override
  String get stationTag3a01be1724 => 'muzika';

  @override
  String get stationTagfe0feb3c23 => 'mjuzikl';

  @override
  String get stationTag489d08ab84 => 'muzika za decu';

  @override
  String get stationTag71c1d51400 => 'narodna';

  @override
  String get stationTag996676018c => 'narodna - etno';

  @override
  String get stationTagba1d431793 => 'nacionalno';

  @override
  String get stationTag6d150cec97 => 'novi talas';

  @override
  String get stationTag3c6bdcddc9 => 'vesti';

  @override
  String get stationTag54ac9a2e58 => 'radio vesti';

  @override
  String get stationTagca29a260a8 => 'vesti i razgovor';

  @override
  String get stationTag81f7a3d9ae => 'nekomercijalno';

  @override
  String get stationTaga6b8fe2ef4 => 'muzika bez prekida';

  @override
  String get stationTaga67edc88d9 => 'nostalgija';

  @override
  String get stationTag869f15a237 => 'vesti';

  @override
  String get stationTag5d6687996d => 'stari hitovi';

  @override
  String get stationTag2dbc2fd235 => 'onlajn';

  @override
  String get stationTag6feda84dcc => 'opera';

  @override
  String get stationTag8341873a88 => 'opus';

  @override
  String get stationTag03c8ed27df => 'orkestarska';

  @override
  String get stationTag84beb18831 => 'žurka';

  @override
  String get stationTag3f4667905c => 'hitovi za žurku';

  @override
  String get stationTagee848a3b5b => 'policija';

  @override
  String get stationTagae4fd29aa1 => 'politički razgovor';

  @override
  String get stationTag4c5fd84e89 => 'politika';

  @override
  String get stationTag4f197c99a7 => 'pop';

  @override
  String get stationTag122fb23bc6 => 'pop dens';

  @override
  String get stationTag0be9a78da5 => 'pop latino';

  @override
  String get stationTag9eda0e7aa9 => 'pop muzika';

  @override
  String get stationTagbb2c038983 => 'pop rok';

  @override
  String get stationTag74c72544e0 => 'pop rok';

  @override
  String get stationTag136dfa5b33 => 'progresivni haus';

  @override
  String get stationTaga2f77c10a5 => 'javni radio';

  @override
  String get stationTag71d689362a => 'javni servis';

  @override
  String get stationTag5940e3137d => 'pank';

  @override
  String get stationTagcb0cde801b => 'R&B';

  @override
  String get stationTag6e2a486fe3 => 'r&b/urban';

  @override
  String get stationTag5c4a513dbf => 'R&B';

  @override
  String get stationTagd432c3525b => 'radio';

  @override
  String get stationTag8390ac37de => 'radio online';

  @override
  String get stationTag1bf1b43494 => 'radiorama';

  @override
  String get stationTag51c4ccfd6b => 'rep';

  @override
  String get stationTag914bdbfd48 => 'rap hiphop rnb';

  @override
  String get stationTag0615591f84 => 'rege';

  @override
  String get stationTag65013ec4e5 => 'regeton';

  @override
  String get stationTag197caeb8b5 => 'regionalno';

  @override
  String get stationTaga6d888f965 => 'regionalni radio';

  @override
  String get stationTag63bb094ca4 => 'opuštanje';

  @override
  String get stationTagb912a11ddd => 'opuštanje';

  @override
  String get stationTag6e93871ac7 => 'opuštajuće';

  @override
  String get stationTagbbde763cc0 => 'remiks';

  @override
  String get stationTag4c742a2314 => 'retro';

  @override
  String get stationTagf2792fa06d => 'R&B';

  @override
  String get stationTag38464bf083 => 'rok';

  @override
  String get stationTag17c8217f23 => 'rokenrol';

  @override
  String get stationTag5b9265ef9f => 'rokabili';

  @override
  String get stationTag346f5986a9 => 'romantična';

  @override
  String get stationTag17d7cc4d9a => 'ruski pop';

  @override
  String get stationTagb36ad30593 => 'samba';

  @override
  String get stationTag64fd638390 => 'sezonska';

  @override
  String get stationTagf81ac68eee => 'srpska muzika';

  @override
  String get stationTag3aa9adbbb4 => 'ska';

  @override
  String get stationTagc3ca5f7873 => 'spavanje';

  @override
  String get stationTag6c021501ca => 'spori rok';

  @override
  String get stationTagc0c6d93fe3 => 'lagana muzika';

  @override
  String get stationTagc5c1fe26d5 => 'lagani pop';

  @override
  String get stationTag3af8919a33 => 'lagani rok';

  @override
  String get stationTag0867322e7c => 'soul';

  @override
  String get stationTag3e4ef17728 => 'zvuci prirode';

  @override
  String get stationTagf3690b9c34 => 'govorni program';

  @override
  String get stationTag8ab6a8a0cf => 'sport';

  @override
  String get stationTag150a8af76a => 'sport';

  @override
  String get stationTag7899b8b3d9 => 'sportske vesti';

  @override
  String get stationTag4c5218bd29 => 'sportski razgovor';

  @override
  String get stationTag0b1ecf7216 => 'starogradska';

  @override
  String get stationTag723f4e1ce3 => 'sving';

  @override
  String get stationTage55e91b2cc => 'razgovor';

  @override
  String get stationTag5108191aa3 => 'govorni radio';

  @override
  String get stationTage405fa83fe => 'tehno';

  @override
  String get stationTag27d50b6f9a => 'top-liste';

  @override
  String get stationTag795bbda660 => 'top hitovi';

  @override
  String get stationTag7f1345c21a => 'trens';

  @override
  String get stationTage6d307367a => 'trep';

  @override
  String get stationTagad3d12ae13 => 'trip hop';

  @override
  String get stationTagba7a82a981 => 'urbano';

  @override
  String get stationTag09cdd5dd4b => 'urbano';

  @override
  String get stationTag84942e2fd1 => 'uživo';

  @override
  String get stationTag75b4d7d721 => 'raznovrsno';

  @override
  String get stationTag21e7a8ba50 => 'raznovrsno';

  @override
  String get stationTage609aae6c8 => 'vesti';

  @override
  String get stationTag0be9098c7e => 'vintidž';

  @override
  String get stationTagbf6e51973d => 'vinil';

  @override
  String get stationTag91b7e90635 => 'vlaška';

  @override
  String get stationTag7c211433f0 => 'svet';

  @override
  String get stationTag3c405b7c0e => 'muzika sveta';

  @override
  String get stationTag7b0ac581fe => 'svetske vesti';

  @override
  String get stationTagf9925d1162 => 'mladi';

  @override
  String get stationTag9de3eede6a => 'zabavna';

  @override
  String get stationTaga712aa0f9d => 'audio knjige';

  @override
  String get stationTagd341e6e288 => 'za decu';

  @override
  String get stationTag6e0dc4349c => 'literatura';

  @override
  String get stationTagd42e4f9f15 => 'politika';

  @override
  String get stationTag2ca9d5c635 => 'pop';

  @override
  String get stationTagb5cbcd9cbc => 'rok';

  @override
  String get stationTagb5f9fa4f69 => 'etno';
}

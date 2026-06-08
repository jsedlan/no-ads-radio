import 'dart:convert';

class RadioStation {
  static const Set<String> diasporaCountryCodes = <String>{
    'RS',
    'HR',
    'SI',
    'ME',
    'BA',
    'MK',
  };

  const RadioStation({
    required this.stationUuid,
    required this.name,
    required this.url,
    required this.urlResolved,
    required this.homepage,
    required this.favicon,
    required this.tags,
    required this.country,
    required this.countryCode,
    required this.state,
    required this.language,
    required this.codec,
    required this.bitrate,
    required this.votes,
    required this.clickCount,
    required this.clickTrend,
    required this.lastCheckOk,
    required this.hls,
    this.isScraped = false,
    this.rawSource = const <String, dynamic>{},
  });

  final String stationUuid;
  final String name;
  final String url;
  final String urlResolved;
  final String homepage;
  final String favicon;
  final String tags;
  final String country;
  final String countryCode;
  final String state;
  final String language;
  final String codec;
  final int bitrate;
  final int votes;
  final int clickCount;
  final int clickTrend;
  final bool lastCheckOk;
  final bool hls;
  final bool isScraped;
  final Map<String, dynamic> rawSource;

  factory RadioStation.fromJson(Map<String, dynamic> json) {
    final country = _readString(json['country']);
    return RadioStation(
      stationUuid: _readString(json['stationuuid']),
      name: _readString(json['name'], fallback: 'Unknown station'),
      url: _readString(json['url']),
      urlResolved: _readString(json['url_resolved']),
      homepage: _readString(json['homepage']),
      favicon: _readString(json['favicon']),
      tags: _readString(json['tags']),
      country: country,
      countryCode: _readCountryCode(json['countrycode'], country: country),
      state: _readString(json['state']),
      language: _readString(json['language']),
      codec: _readString(json['codec']),
      bitrate: _readInt(json['bitrate']),
      votes: _readInt(json['votes']),
      clickCount: _readInt(json['clickcount']),
      clickTrend: _readInt(json['clicktrend']),
      lastCheckOk: _readBool(json['lastcheckok']),
      hls: _readBool(json['hls']),
      isScraped: _readBool(json['is_scraped']),
      rawSource:
          _readMap(json['raw_source']) ?? Map<String, dynamic>.from(json),
    );
  }

  factory RadioStation.fromScraperJson(Map<String, dynamic> json) {
    final source = _readString(json['source'], fallback: 'scraped');
    final id = _readString(json['id']);
    final country = _readString(json['country']);

    return RadioStation(
      stationUuid: 'scraped-$source-$id',
      name: _readString(json['name'], fallback: 'Unknown station'),
      url: _readString(json['stream_url']),
      urlResolved: _readString(json['stream_url']),
      homepage: _readString(
        json['website'],
        fallback: _readString(json['page_url']),
      ),
      favicon: _readString(json['image_url']),
      tags:
          (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .join(',') ??
          '',
      country: country,
      countryCode: _scraperCountryCode(country),
      state: _readString(json['city']),
      language: '',
      codec: _readString(json['stream_type']),
      bitrate: 0,
      votes: 0,
      clickCount: 0,
      clickTrend: 0,
      lastCheckOk: true,
      hls: false,
      isScraped: true,
      rawSource: Map<String, dynamic>.from(json),
    );
  }

  factory RadioStation.fromStorage(String value) {
    return RadioStation.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }

  String get displayName =>
      name.trim().isEmpty ? 'Untitled station' : name.trim();

  String get displayLocation {
    final parts = [
      if (state.trim().isNotEmpty) state.trim(),
      if (country.trim().isNotEmpty)
        country.trim()
      else if (countryCode.isNotEmpty)
        countryCode,
    ];
    return parts.join(' • ');
  }

  String get displayTags => tags
      .split(',')
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .take(3)
      .join(' • ');

  String get displayLanguage => language
      .split(',')
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .take(2)
      .join(' • ');

  bool get hasArtwork => favicon.trim().isNotEmpty;

  bool get isDiaspora => country.trim().toLowerCase() == 'dijaspora';

  bool isDiasporaForCountryCode(String value) {
    return isDiaspora &&
        diasporaCountryCodes.contains(value.trim().toUpperCase());
  }

  String get identityKey {
    final uuid = stationUuid.trim();
    if (uuid.isNotEmpty) {
      return uuid;
    }

    final streamUrl = bestStreamUrl;
    if (streamUrl.isNotEmpty) {
      return 'stream:$streamUrl';
    }

    return 'station:${displayName.toLowerCase()}|'
        '${displayLocation.toLowerCase()}';
  }

  String get bestStreamUrl {
    if (urlResolved.trim().isNotEmpty) {
      return urlResolved.trim();
    }
    return url.trim();
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'stationuuid': stationUuid,
      'name': name,
      'url': url,
      'url_resolved': urlResolved,
      'homepage': homepage,
      'favicon': favicon,
      'tags': tags,
      'country': country,
      'countrycode': countryCode,
      'state': state,
      'language': language,
      'codec': codec,
      'bitrate': bitrate,
      'votes': votes,
      'clickcount': clickCount,
      'clicktrend': clickTrend,
      'lastcheckok': lastCheckOk ? 1 : 0,
      'hls': hls ? 1 : 0,
      'is_scraped': isScraped ? 1 : 0,
      'raw_source': rawSource,
    };
  }

  String toStorage() => jsonEncode(toJson());

  static String _readString(Object? value, {String fallback = ''}) {
    if (value == null) {
      return fallback;
    }
    return value.toString();
  }

  static String _readCountryCode(Object? value, {required String country}) {
    final countryCode = _readString(value).trim().toUpperCase();
    if (countryCode.isNotEmpty) {
      return countryCode;
    }
    return _scraperCountryCode(country);
  }

  static int _readInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _readBool(Object? value) {
    if (value is bool) {
      return value;
    }
    return value == 1 || value == '1' || value == 'true';
  }

  static Map<String, dynamic>? _readMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.from(value);
    }
    if (value is Map) {
      return value.map(
        (key, entryValue) => MapEntry(key.toString(), entryValue),
      );
    }
    return null;
  }

  static String _scraperCountryCode(String country) {
    switch (country.trim().toLowerCase()) {
      case 'bih':
      case 'bosna i hercegovina':
        return 'BA';
      case 'serbia':
      case 'srbija':
        return 'RS';
      case 'hrvatska':
        return 'HR';
      case 'crna gora':
        return 'ME';
      case 'makedonija':
      case 'severna makedonija':
      case 'north macedonia':
        return 'MK';
      case 'slovenija':
        return 'SI';
      case 'austria':
      case 'austrija':
        return 'AT';
      case 'nemačka':
      case 'njemacka':
      case 'germany':
        return 'DE';
      case 'švajcarska':
      case 'switzerland':
        return 'CH';
      default:
        return '';
    }
  }
}

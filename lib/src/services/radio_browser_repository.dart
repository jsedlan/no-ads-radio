import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../models/radio_station.dart';
import '../models/search_query.dart';
import 'station_repository.dart';

class RadioBrowserRepository implements StationRepository {
  RadioBrowserRepository({http.Client? client, List<String>? seedServers})
    : _client = client ?? http.Client(),
      _seedServers = List<String>.from(
        seedServers ??
            const <String>[
              'de1.api.radio-browser.info',
              'nl1.api.radio-browser.info',
              'fi1.api.radio-browser.info',
            ],
      );

  static const String userAgent = 'no-ads-radio/1.0';

  final http.Client _client;
  final List<String> _seedServers;
  final Random _random = Random();

  List<String>? _cachedServers;

  @override
  Future<List<RadioStation>> fetchTopClicked({int limit = 12}) async {
    return _loadStations(
      '/json/stations/topclick/$limit',
      queryParameters: const <String, String>{'hidebroken': 'true'},
    );
  }

  @override
  Future<List<RadioStation>> fetchTopVoted({int limit = 12}) async {
    return _loadStations(
      '/json/stations/topvote/$limit',
      queryParameters: const <String, String>{'hidebroken': 'true'},
    );
  }

  @override
  Future<List<RadioStation>> fetchRecentlyClicked({int limit = 12}) async {
    return _loadStations(
      '/json/stations/lastclick/$limit',
      queryParameters: const <String, String>{'hidebroken': 'true'},
    );
  }

  @override
  Future<List<RadioStation>> searchStations(
    StationSearchQuery query, {
    int limit = 30,
  }) async {
    final parameters = <String, String>{
      'hidebroken': 'true',
      'limit': '$limit',
      'order': query.ordering.apiValue,
      'reverse': 'true',
    };

    if (query.name.trim().isNotEmpty) {
      parameters['name'] = query.name.trim();
    }
    if (query.countryCode.trim().isNotEmpty) {
      parameters['countrycode'] = query.countryCode.trim().toUpperCase();
    }
    if (query.language.trim().isNotEmpty) {
      parameters['language'] = query.language.trim();
    }
    if (query.tag.trim().isNotEmpty) {
      parameters['tag'] = query.tag.trim();
    }

    return _loadStations('/json/stations/search', queryParameters: parameters);
  }

  @override
  Future<String> resolveStreamUrl(String stationUuid) async {
    final result = await _loadObject('/json/url/$stationUuid');
    final streamUrl = result['url']?.toString().trim() ?? '';
    if (streamUrl.isEmpty) {
      throw const RadioBrowserException(
        'The station did not return a playable stream URL.',
      );
    }
    return streamUrl;
  }

  Future<List<RadioStation>> _loadStations(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final payload = await _loadArray(path, queryParameters: queryParameters);
    return payload
        .map((item) => RadioStation.fromJson(item as Map<String, dynamic>))
        .where((station) => station.bestStreamUrl.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<dynamic>> _loadArray(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final payload = await _performRequest(
      path,
      queryParameters: queryParameters,
    );
    if (payload is List<dynamic>) {
      return payload;
    }
    throw const RadioBrowserException('Unexpected API response.');
  }

  Future<Map<String, dynamic>> _loadObject(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final payload = await _performRequest(
      path,
      queryParameters: queryParameters,
    );
    if (payload is Map<String, dynamic>) {
      return payload;
    }
    throw const RadioBrowserException('Unexpected API response.');
  }

  Future<dynamic> _performRequest(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final servers = await _serverRotation();
    Object? lastError;

    for (final server in servers) {
      final uri = Uri.https(server, path, queryParameters);
      try {
        final response = await _client.get(
          uri,
          headers: const <String, String>{
            'User-Agent': userAgent,
            'Accept': 'application/json',
          },
        );

        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw RadioBrowserException(
            'Radio Browser returned ${response.statusCode}.',
          );
        }

        return jsonDecode(response.body);
      } catch (error) {
        lastError = error;
      }
    }

    throw RadioBrowserException(
      'Unable to reach a Radio Browser mirror.',
      cause: lastError,
    );
  }

  Future<List<String>> _serverRotation() async {
    if (_cachedServers == null || _cachedServers!.isEmpty) {
      _cachedServers = List<String>.from(_seedServers);
      _shuffle(_cachedServers!);
      await _refreshMirrors();
    } else {
      _shuffle(_cachedServers!);
    }

    return List<String>.from(_cachedServers!);
  }

  Future<void> _refreshMirrors() async {
    for (final server in List<String>.from(_seedServers)) {
      final uri = Uri.https(server, '/json/servers');
      try {
        final response = await _client.get(
          uri,
          headers: const <String, String>{
            'User-Agent': userAgent,
            'Accept': 'application/json',
          },
        );

        if (response.statusCode < 200 || response.statusCode >= 300) {
          continue;
        }

        final payload = jsonDecode(response.body);
        if (payload is! List<dynamic>) {
          continue;
        }

        final discovered = payload
            .map((item) => item as Map<String, dynamic>)
            .map((item) => item['name']?.toString() ?? '')
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList(growable: true);

        if (discovered.isNotEmpty) {
          discovered.addAll(_seedServers);
          _cachedServers = discovered.toSet().toList(growable: true);
          _shuffle(_cachedServers!);
          return;
        }
      } catch (_) {
        continue;
      }
    }
  }

  void _shuffle(List<String> values) {
    values.shuffle(_random);
  }
}

class RadioBrowserException implements Exception {
  const RadioBrowserException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:no_ads_radio/src/models/radio_station.dart';

const List<String> _seedServers = <String>[
  'de1.api.radio-browser.info',
  'nl1.api.radio-browser.info',
  'fi1.api.radio-browser.info',
];

const String _defaultOutputPath = 'assets/station_catalog_fallback.json';

Future<void> main(List<String> args) async {
  final options = _parseArgs(args);
  if (options.showHelp) {
    _printUsage();
    return;
  }

  final client = http.Client();
  try {
    final radioBrowserStations = await _fetchRadioBrowserStations(
      client: client,
      perFeedLimit: options.perFeedLimit,
    );
    final localStations = await _loadLocalStations();
    final merged = _mergeStations(<RadioStation>[
      ...radioBrowserStations,
      ...localStations,
    ]);

    final outputFile = File(options.outputPath);
    await outputFile.parent.create(recursive: true);
    const encoder = JsonEncoder.withIndent('  ');
    final payload = merged
        .map((station) => station.toJson())
        .toList(growable: false);
    await outputFile.writeAsString('${encoder.convert(payload)}\n');

    stdout.writeln(
      'Wrote ${merged.length} stations to ${outputFile.path} '
      '(Radio Browser: ${radioBrowserStations.length}, local: ${localStations.length}).',
    );
  } finally {
    client.close();
  }
}

Future<List<RadioStation>> _fetchRadioBrowserStations({
  required http.Client client,
  required int perFeedLimit,
}) async {
  final feeds = <String>[
    '/json/stations/topclick/$perFeedLimit',
    '/json/stations/topvote/$perFeedLimit',
    '/json/stations/lastclick/$perFeedLimit',
  ];

  final stations = <RadioStation>[];
  final servers = <String>[..._seedServers];
  Object? lastError;

  for (final path in feeds) {
    var loaded = false;
    for (final server in servers) {
      try {
        final uri = Uri.https(server, path, const <String, String>{
          'hidebroken': 'true',
        });
        final response = await client.get(
          uri,
          headers: const <String, String>{
            'User-Agent': 'no-ads-radio/1.0',
            'Accept': 'application/json',
          },
        );
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw HttpException('Radio Browser returned ${response.statusCode}.');
        }
        final payload = jsonDecode(response.body);
        if (payload is! List<dynamic>) {
          throw const FormatException('Unexpected Radio Browser payload.');
        }
        stations.addAll(
          payload
              .map(
                (item) => RadioStation.fromJson(item as Map<String, dynamic>),
              )
              .where((station) => station.bestStreamUrl.isNotEmpty),
        );
        loaded = true;
        break;
      } catch (error) {
        lastError = error;
      }
    }

    if (!loaded) {
      throw Exception('Unable to load $path from Radio Browser: $lastError');
    }
  }

  return stations;
}

Future<List<RadioStation>> _loadLocalStations() async {
  final files = <String>[
    'assets/balkanradio_stations.json',
    'assets/exyuradio_stations.json',
  ];

  final stations = <RadioStation>[];
  for (final path in files) {
    final file = File(path);
    final raw = await file.readAsString();
    final payload = jsonDecode(raw);
    if (payload is! List<dynamic>) {
      throw FormatException('Unexpected local station payload in $path.');
    }
    stations.addAll(
      payload
          .map(
            (item) =>
                RadioStation.fromScraperJson(item as Map<String, dynamic>),
          )
          .where((station) => station.bestStreamUrl.isNotEmpty),
    );
  }
  return stations;
}

List<RadioStation> _mergeStations(List<RadioStation> stations) {
  final seenIds = <String>{};
  final seenNames = <String>{};
  final result = <RadioStation>[];

  for (final station in stations) {
    final stationId = station.stationUuid.trim();
    final stationName = station.displayName.trim().toLowerCase();
    if (station.bestStreamUrl.isEmpty) {
      continue;
    }
    if (stationId.isNotEmpty && seenIds.contains(stationId)) {
      continue;
    }
    if (stationName.isNotEmpty && seenNames.contains(stationName)) {
      continue;
    }
    if (stationId.isNotEmpty) {
      seenIds.add(stationId);
    }
    if (stationName.isNotEmpty) {
      seenNames.add(stationName);
    }
    result.add(station);
  }

  return result;
}

_Options _parseArgs(List<String> args) {
  var perFeedLimit = 200;
  var outputPath = _defaultOutputPath;
  var showHelp = false;

  for (final arg in args) {
    if (arg == '--help' || arg == '-h') {
      showHelp = true;
      continue;
    }
    if (arg.startsWith('--per-feed-limit=')) {
      perFeedLimit =
          int.tryParse(arg.substring('--per-feed-limit='.length)) ??
          perFeedLimit;
      continue;
    }
    if (arg.startsWith('--output=')) {
      outputPath = arg.substring('--output='.length).trim();
      continue;
    }
  }

  return _Options(
    perFeedLimit: perFeedLimit,
    outputPath: outputPath,
    showHelp: showHelp,
  );
}

void _printUsage() {
  stdout.writeln(
    'Usage: dart run tool/generate_fallback_catalog.dart [options]',
  );
  stdout.writeln('');
  stdout.writeln('Options:');
  stdout.writeln(
    '  --per-feed-limit=<n>  Stations fetched from each Radio Browser feed. Default: 200',
  );
  stdout.writeln(
    '  --output=<path>       Output JSON path. Default: $_defaultOutputPath',
  );
  stdout.writeln('  --help                Show this help.');
}

class _Options {
  const _Options({
    required this.perFeedLimit,
    required this.outputPath,
    required this.showHelp,
  });

  final int perFeedLimit;
  final String outputPath;
  final bool showHelp;
}

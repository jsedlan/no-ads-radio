import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ConnectivitySnapshot {
  const ConnectivitySnapshot({
    required this.isOnline,
    required this.isChecking,
    this.lastCheckedAt,
  });

  const ConnectivitySnapshot.unknown() : this(isOnline: null, isChecking: true);

  final bool? isOnline;
  final bool isChecking;
  final DateTime? lastCheckedAt;

  bool get isOffline => isOnline == false;
}

abstract class ConnectivityService {
  ValueListenable<ConnectivitySnapshot> get snapshot;

  Future<void> initialize();
  Future<void> internetReachable();
  void reportOnline();
  Future<void> dispose();
}

class ReachabilityConnectivityService implements ConnectivityService {
  ReachabilityConnectivityService({Uri? probeUri, http.Client? httpClient})
    : _probeUri =
          probeUri ?? Uri.parse('https://clients3.google.com/generate_204'),
      _httpClient = httpClient ?? http.Client();

  final Uri _probeUri;
  final http.Client _httpClient;
  final ValueNotifier<ConnectivitySnapshot> _snapshot =
      ValueNotifier<ConnectivitySnapshot>(const ConnectivitySnapshot.unknown());

  bool _disposed = false;
  bool _isChecking = false;

  @override
  ValueListenable<ConnectivitySnapshot> get snapshot => _snapshot;

  @override
  Future<void> initialize() async {
    await internetReachable();
  }

  @override
  Future<void> internetReachable() async {
    if (_disposed || _isChecking) {
      return;
    }

    _isChecking = true;
    final previous = _snapshot.value;
    _snapshot.value = ConnectivitySnapshot(
      isOnline: previous.isOnline,
      isChecking: true,
      lastCheckedAt: previous.lastCheckedAt,
    );

    try {
      final response = await _httpClient
          .get(_probeUri)
          .timeout(const Duration(seconds: 4));
      final isOnline = response.statusCode >= 200 && response.statusCode < 400;
      _snapshot.value = ConnectivitySnapshot(
        isOnline: isOnline,
        isChecking: false,
        lastCheckedAt: DateTime.now(),
      );
    } catch (_) {
      _snapshot.value = ConnectivitySnapshot(
        isOnline: false,
        isChecking: false,
        lastCheckedAt: DateTime.now(),
      );
    } finally {
      _isChecking = false;
    }
  }

  @override
  void reportOnline() {
    if (_disposed || _snapshot.value.isOnline == true) {
      return;
    }
    _snapshot.value = ConnectivitySnapshot(
      isOnline: true,
      isChecking: false,
      lastCheckedAt: DateTime.now(),
    );
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    _httpClient.close();
    _snapshot.dispose();
  }
}

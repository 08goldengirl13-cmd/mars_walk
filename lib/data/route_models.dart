/// One NASA waypoint of Curiosity's route (or an interpolated point between
/// two waypoints).
class RoutePoint {
  const RoutePoint({
    required this.sol,
    required this.lon,
    required this.lat,
    required this.elev,
    required this.tilt,
    required this.distM,
  });

  /// Mars day number of the waypoint.
  final int sol;

  /// Planetocentric longitude, degrees east.
  final double lon;

  /// Latitude, degrees north (Gale is just south of the equator).
  final double lat;

  /// Elevation in metres relative to the Mars geoid (`elev_geoid`).
  final double elev;

  /// Rover body tilt in degrees. Used only as a rough proxy for slope.
  final double tilt;

  /// Total distance driven so far, metres (`dist_total_m`).
  final double distM;

  double get km => distM / 1000.0;

  factory RoutePoint.fromList(List<dynamic> v) => RoutePoint(
    sol: (v[0] as num).round(),
    lon: (v[1] as num).toDouble(),
    lat: (v[2] as num).toDouble(),
    elev: (v[3] as num).toDouble(),
    tilt: (v[4] as num).toDouble(),
    distM: (v[5] as num).toDouble(),
  );

  @override
  String toString() =>
      'RoutePoint(sol $sol, $lat, $lon, ${elev.toStringAsFixed(1)} m, '
      '${distM.toStringAsFixed(1)} m)';
}

/// The whole route plus a few statistics.
class RouteData {
  RouteData({
    required this.points,
    required this.source,
    required this.downloaded,
    required this.isDemo,
  }) : assert(points.length >= 2),
       minElev = points.map((p) => p.elev).reduce((a, b) => a < b ? a : b),
       maxElev = points.map((p) => p.elev).reduce((a, b) => a > b ? a : b),
       minLat = points.map((p) => p.lat).reduce((a, b) => a < b ? a : b),
       maxLat = points.map((p) => p.lat).reduce((a, b) => a > b ? a : b),
       minLon = points.map((p) => p.lon).reduce((a, b) => a < b ? a : b),
       maxLon = points.map((p) => p.lon).reduce((a, b) => a > b ? a : b);

  final List<RoutePoint> points;
  final String source;
  final String downloaded;

  /// True when the bundled file is the placeholder demo route.
  final bool isDemo;

  final double minElev;
  final double maxElev;
  final double minLat;
  final double maxLat;
  final double minLon;
  final double maxLon;

  int get length => points.length;
  RoutePoint get first => points.first;
  RoutePoint get last => points.last;
  double get totalKm => last.distM / 1000.0;
  int get solCount => last.sol - first.sol;

  /// Difference between highest and lowest point of the route.
  double get climbM => maxElev - minElev;

  static RouteData fromJson(Map<String, dynamic> json) {
    final raw = (json['points'] as List).cast<List<dynamic>>();
    final source = (json['source'] ?? 'unknown').toString();
    return RouteData(
      points: [for (final p in raw) RoutePoint.fromList(p)],
      source: source,
      downloaded: (json['downloaded'] ?? '').toString(),
      isDemo: source.toUpperCase().startsWith('DEMO'),
    );
  }

  /// A tiny straight-line placeholder route, used ONLY when the real asset is
  /// missing. The app shows a yellow "demo data" banner when this is in use.
  static RouteData demo() {
    const n = 20;
    return RouteData(
      source: 'DEMO — run tool/prepare_data.dart',
      downloaded: '',
      isDemo: true,
      points: [
        for (var i = 0; i < n; i++)
          RoutePoint(
            sol: i * 10,
            lon: 137.44 - i * 0.003,
            lat: -4.59 - i * 0.01,
            elev: -4500 + i * 50.0,
            tilt: 5,
            distM: i * 600.0,
          ),
      ],
    );
  }
}

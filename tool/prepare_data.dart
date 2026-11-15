// Mars Walk — data preparation script.
//
// Downloads NASA/JPL's public Curiosity (MSL) waypoint file, cleans it and
// writes compact copies into assets/data/ for the app to bundle.
//
// Run from the project root:
//   dart run tool/prepare_data.dart          (download, fall back to local file)
//   dart run tool/prepare_data.dart --local  (only use tool/raw/MSL_waypoints.json)
//
// The app never fetches this data at runtime (CORS of the MMGIS host is not
// guaranteed), so this script is the only place the route data comes from.

import 'dart:convert';
import 'dart:io';

const String waypointsUrl = 'https://mars.nasa.gov/mmgis-maps/MSL/Layers/json/MSL_waypoints.json';
const String rawPath = 'tool/raw/MSL_waypoints.json';
const String routeOut = 'assets/data/route.json';
const String metaOut = 'assets/data/route_meta.json';
const String sourceLabel = 'NASA/JPL-Caltech MSL waypoints (MMGIS)';

class _Pt {
  _Pt(this.sol, this.lon, this.lat, this.elev, this.tilt, this.distM);
  final int sol;
  final double lon;
  final double lat;
  final double elev;
  final double tilt;
  final double distM;
}

Future<void> main(List<String> args) async {
  final localOnly = args.contains('--local');
  String? text;
  String dateLabel = _today();

  if (!localOnly) {
    text = await _download();
    if (text != null) {
      final raw = File(rawPath);
      raw.parent.createSync(recursive: true);
      raw.writeAsStringSync(text);
      stdout.writeln('Saved a raw copy to $rawPath');
    }
  }

  if (text == null) {
    final raw = File(rawPath);
    if (raw.existsSync()) {
      stdout.writeln('Using local file $rawPath');
      text = raw.readAsStringSync();
      dateLabel = _date(raw.lastModifiedSync());
    }
  }

  if (text == null) {
    stderr.writeln('''
Could not get the waypoint file.
  1. Open this URL in your browser:
     $waypointsUrl
  2. Save the file as $rawPath
  3. Run again:  dart run tool/prepare_data.dart --local
''');
    exitCode = 1;
    return;
  }

  final points = _parse(text);
  if (points.isEmpty) {
    stderr.writeln('No usable points found. Is this the right file?');
    exitCode = 1;
    return;
  }

  final cleaned = _clean(points);
  _writeOutputs(cleaned, dateLabel);
}

Future<String?> _download() async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 30);
  try {
    stdout.writeln('Downloading $waypointsUrl ...');
    final req = await client.getUrl(Uri.parse(waypointsUrl));
    req.headers.set(HttpHeaders.userAgentHeader, 'Mozilla/5.0 (compatible; MarsWalkDataPrep/1.0)');
    final res = await req.close().timeout(const Duration(seconds: 90));
    if (res.statusCode != 200) {
      stderr.writeln('Download failed: HTTP ${res.statusCode}');
      return null;
    }
    final body = await res.transform(utf8.decoder).join();
    stdout.writeln('Downloaded ${body.length} characters.');
    return body;
  } catch (e) {
    stderr.writeln('Download failed: $e');
    return null;
  } finally {
    client.close(force: true);
  }
}

double? _num(Object? v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

List<_Pt> _parse(String text) {
  final json = jsonDecode(text) as Map<String, dynamic>;
  final features = (json['features'] as List?) ?? const [];
  final out = <_Pt>[];
  final driveTypes = <String>{};
  var skipped = 0;

  for (final f in features) {
    if (f is! Map) {
      skipped++;
      continue;
    }
    final props = (f['properties'] as Map?) ?? const {};
    final geom = (f['geometry'] as Map?) ?? const {};
    final coords = (geom['coordinates'] as List?) ?? const [];

    final sol = _num(props['sol']);
    final lon = _num(props['lon']) ?? (coords.isNotEmpty ? _num(coords[0]) : null);
    final lat = _num(props['lat']) ?? (coords.length > 1 ? _num(coords[1]) : null);
    final elev = _num(props['elev_geoid']) ?? (coords.length > 2 ? _num(coords[2]) : null);
    final tilt = _num(props['tilt']) ?? 0.0;
    final dist = _num(props['dist_total_m']);
    final dt = props['drive_type'];
    if (dt != null) driveTypes.add('$dt');

    if (sol == null || lon == null || lat == null || elev == null || dist == null) {
      skipped++;
      continue;
    }
    out.add(_Pt(sol.round(), lon, lat, elev, tilt, dist));
  }

  stdout.writeln('');
  stdout.writeln('== Summary of the raw file ==');
  stdout.writeln('Features: ${features.length}, usable points: ${out.length}, skipped: $skipped');
  stdout.writeln('drive_type values: ${driveTypes.join(', ')}');
  if (out.isNotEmpty) {
    final elevs = out.map((p) => p.elev);
    final sols = out.map((p) => p.sol);
    stdout.writeln(
      'Elevation: ${elevs.reduce(_min).toStringAsFixed(1)} m '
      '→ ${elevs.reduce(_max).toStringAsFixed(1)} m',
    );
    stdout.writeln(
      'Sol: ${sols.reduce((a, b) => a < b ? a : b)} → '
      '${sols.reduce((a, b) => a > b ? a : b)}',
    );
    stdout.writeln(
      'Total distance (max dist_total_m): '
      '${out.map((p) => p.distM).reduce(_max).toStringAsFixed(1)} m',
    );
  }
  return out;
}

double _min(double a, double b) => a < b ? a : b;
double _max(double a, double b) => a > b ? a : b;

List<_Pt> _clean(List<_Pt> input) {
  var solMono = true;
  var distMono = true;
  for (var i = 1; i < input.length; i++) {
    if (input[i].sol < input[i - 1].sol) solMono = false;
    if (input[i].distM < input[i - 1].distM) distMono = false;
  }
  stdout.writeln('sol monotonic non-decreasing in file order: $solMono');
  stdout.writeln('dist_total_m monotonic non-decreasing in file order: $distMono');

  var pts = List<_Pt>.of(input);
  if (!solMono || !distMono) {
    stdout.writeln('WARNING: file is not in order — sorting by (sol, dist_total_m).');
    pts.sort((a, b) {
      final c = a.sol.compareTo(b.sol);
      return c != 0 ? c : a.distM.compareTo(b.distM);
    });
  }

  final seen = <String>{};
  final out = <_Pt>[];
  var dupes = 0;
  var backwards = 0;
  for (final p in pts) {
    final key = '${p.lon.toStringAsFixed(6)},${p.lat.toStringAsFixed(6)}';
    if (seen.contains(key)) {
      dupes++;
      continue;
    }
    if (out.isNotEmpty && p.distM < out.last.distM) {
      backwards++;
      continue;
    }
    seen.add(key);
    out.add(p);
  }
  stdout.writeln(
    'Dropped $dupes duplicate positions and $backwards points '
    'going backwards in distance. Kept ${out.length} points.',
  );
  if (out.length < 800) {
    stdout.writeln('NOTE: fewer than 800 points kept; animation may look less smooth.');
  }
  return out;
}

double _r(double v, int digits) => double.parse(v.toStringAsFixed(digits));

void _writeOutputs(List<_Pt> pts, String date) {
  final route = {
    'source': sourceLabel,
    'downloaded': date,
    'fields': ['sol', 'lon', 'lat', 'elev', 'tilt', 'distM'],
    'points': [
      for (final p in pts)
        [p.sol, _r(p.lon, 6), _r(p.lat, 6), _r(p.elev, 2), _r(p.tilt, 2), _r(p.distM, 1)],
    ],
  };

  final elevs = pts.map((p) => p.elev);
  final minElev = elevs.reduce(_min);
  final maxElev = elevs.reduce(_max);
  final meta = {
    'source': sourceLabel,
    'downloaded': date,
    'pointCount': pts.length,
    'firstSol': pts.first.sol,
    'lastSol': pts.last.sol,
    'minElevM': _r(minElev, 2),
    'maxElevM': _r(maxElev, 2),
    'elevRangeM': _r(maxElev - minElev, 1),
    'totalKm': _r(pts.last.distM / 1000.0, 3),
  };

  File(routeOut)
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(jsonEncode(route));
  File(metaOut).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(meta));

  stdout.writeln('');
  stdout.writeln('Wrote $routeOut (${pts.length} points) and $metaOut');
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(meta));
}

String _today() => _date(DateTime.now());

String _date(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

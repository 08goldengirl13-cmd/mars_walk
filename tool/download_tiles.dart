// Mars Walk — downloads the NASA Mars Trek map tiles around Curiosity's route
// once and bundles them with the app, so the map appears at once instead of
// waiting several seconds per tile for trek.nasa.gov.
//
// Run from the project root (after tool/prepare_data.dart):
//   dart run tool/download_tiles.dart            (download missing tiles)
//   dart run tool/download_tiles.dart --dry-run  (only count them)
//
// Writes:
//   assets/tiles/<layer>/<z>_<y>_<x>.<ext>   the tile images
//   lib/map/bundled_tiles.g.dart              which tiles are bundled and
//                                             which the server has no image for
// Tiles outside these sets (deeper zoom, other places) still come from NASA.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

const String routeFile = 'assets/data/route.json';
const String generatedFile = 'lib/map/bundled_tiles.g.dart';

class LayerSpec {
  const LayerSpec(this.id, this.folder, this.ext, this.areaZooms, this.corridor);

  final String id;
  final String folder;
  final String ext;

  /// Zoom → whole area (south, west, north, east) to bundle at that zoom.
  final Map<int, List<double>> areaZooms;

  /// Zoom → (rows, cols) margin around every route tile at that zoom.
  final Map<int, List<int>> corridor;
}

/// Gale Crater area used for the global base maps.
const _gale = [-6.9, 136.3, -3.9, 139.3];

/// Measured HiRISE coverage of the Curiosity site (see tile_layers.dart).
const _hirise = [-5.10, 137.10, -4.21, 137.82];

const layers = [
  LayerSpec('Mars_Viking_MDIM21_ClrMosaic_global_232m', 'viking', 'jpg', {
    3: _gale, 4: _gale, 5: _gale, 6: _gale, 7: _gale, //
  }, {}),
  LayerSpec('Mars_MGS_MOLA_ClrShade_merge_global_463m', 'mola', 'jpg', {
    3: _gale, 4: _gale, 5: _gale, 6: _gale, 7: _gale, //
  }, {}),
  // Overview zooms: the whole mosaic. Close-up zooms (the camera follows the
  // astronaut at z13 while playing): a band of tiles along the route.
  LayerSpec('curiosity_hirise_mosaic', 'hirise', 'png', {
    9: _hirise, 10: _hirise, 11: _hirise, //
  }, {
    12: [2, 3],
    13: [2, 4],
  }),
];

class Tile {
  const Tile(this.z, this.y, this.x);
  final int z, y, x;
  String get key => '$z/$y/$x';
  String get file => '${z}_${y}_$x';
  @override
  bool operator ==(Object o) => o is Tile && o.z == z && o.y == y && o.x == x;
  @override
  int get hashCode => Object.hash(z, y, x);
}

// Mars Trek "EQ" grid = flutter_map Epsg4326: 2^(z+1) columns, 2^z rows.
int _col(double lon, int z) => ((lon + 180) / 360 * (1 << (z + 1))).floor();
int _row(double lat, int z) => ((90 - lat) / 180 * (1 << z)).floor();

Set<Tile> tilesFor(LayerSpec spec, List<List<double>> route) {
  final out = <Tile>{};
  spec.areaZooms.forEach((z, b) {
    for (var y = _row(b[2], z); y <= _row(b[0], z); y++) {
      for (var x = _col(b[1], z); x <= _col(b[3], z); x++) {
        out.add(Tile(z, y, x));
      }
    }
  });
  spec.corridor.forEach((z, m) {
    for (final p in route) {
      final cy = _row(p[1], z), cx = _col(p[0], z);
      for (var y = cy - m[0]; y <= cy + m[0]; y++) {
        for (var x = cx - m[1]; x <= cx + m[1]; x++) {
          out.add(Tile(z, y, x));
        }
      }
    }
  });
  return out;
}

Future<void> main(List<String> args) async {
  final dryRun = args.contains('--dry-run');
  final json = jsonDecode(File(routeFile).readAsStringSync()) as Map<String, dynamic>;
  // [lon, lat] of every waypoint.
  final route = [
    for (final p in (json['points'] as List).cast<List<dynamic>>())
      [(p[1] as num).toDouble(), (p[2] as num).toDouble()],
  ];

  final client = HttpClient()..connectionTimeout = const Duration(seconds: 30);
  final generated = <String, (Set<String>, Set<String>)>{};
  var totalBytes = 0;

  for (final spec in layers) {
    final tiles = tilesFor(spec, route).toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final byZoom = <int, int>{};
    for (final t in tiles) {
      byZoom[t.z] = (byZoom[t.z] ?? 0) + 1;
    }
    stdout.writeln('${spec.folder}: ${tiles.length} tiles $byZoom');
    if (dryRun) continue;

    final dir = Directory('assets/tiles/${spec.folder}')..createSync(recursive: true);
    // "Server has no image" markers live outside assets/, so they are not
    // shipped with the app (the generated Dart file records them instead).
    final missDir = Directory('tool/raw/tiles_404/${spec.folder}')..createSync(recursive: true);
    final present = <String>{};
    final missing = <String>{};
    var done = 0;

    Future<void> fetch(Tile t) async {
      final file = File('${dir.path}/${t.file}.${spec.ext}');
      final miss = File('${missDir.path}/${t.file}.404');
      if (file.existsSync()) {
        present.add(t.key);
      } else if (miss.existsSync()) {
        missing.add(t.key);
      } else {
        final url = 'https://trek.nasa.gov/tiles/Mars/EQ/${spec.id}/1.0.0/'
            'default/default028mm/${t.z}/${t.y}/${t.x}.${spec.ext}';
        for (var attempt = 1;; attempt++) {
          try {
            final req = await client.getUrl(Uri.parse(url));
            final res = await req.close().timeout(const Duration(seconds: 90));
            final bytes = await res.fold<List<int>>([], (a, b) => a..addAll(b));
            if (res.statusCode == 200) {
              file.writeAsBytesSync(bytes);
              present.add(t.key);
            } else if (res.statusCode == 404) {
              miss.writeAsStringSync('');
              missing.add(t.key);
            } else {
              throw HttpException('HTTP ${res.statusCode}');
            }
            break;
          } catch (e) {
            if (attempt >= 5) {
              stderr.writeln('  gave up on ${t.key}: $e (run again later)');
              break;
            }
            await Future<void>.delayed(Duration(seconds: 2 * attempt));
          }
        }
      }
      done++;
      if (done % 50 == 0 || done == tiles.length) {
        stdout.writeln('  $done / ${tiles.length}');
      }
    }

    // A few requests at a time: the server is slow and we should be polite.
    final queue = List.of(tiles);
    await Future.wait([
      for (var w = 0; w < 6; w++)
        () async {
          while (queue.isNotEmpty) {
            await fetch(queue.removeLast());
          }
        }(),
    ]);

    for (final f in dir.listSync().whereType<File>()) {
      totalBytes += f.lengthSync();
    }
    generated[spec.id] = (present, missing);
    stdout.writeln('  ${present.length} images, ${missing.length} empty (404)');
  }
  client.close(force: true);
  if (dryRun) return;

  _writeGenerated(generated);
  stdout.writeln('Bundled ${(totalBytes / 1e6).toStringAsFixed(1)} MB of tiles. '
      'Wrote $generatedFile');
}

void _writeGenerated(Map<String, (Set<String>, Set<String>)> data) {
  String setOf(Set<String> s) {
    final list = s.toList()..sort();
    final b = StringBuffer('{');
    for (var i = 0; i < list.length; i++) {
      if (i % 6 == 0) b.write('\n    ');
      b.write("'${list[i]}', ");
    }
    b.write('\n  }');
    return b.toString();
  }

  final b = StringBuffer()
    ..writeln('// GENERATED by tool/download_tiles.dart — do not edit by hand.')
    ..writeln('// Tile keys are "z/y/x" in the Mars Trek EQ grid.')
    ..writeln()
    ..writeln('/// Layer id → tiles bundled under `assets/tiles/<folder>/`.')
    ..writeln('const Map<String, Set<String>> bundledTiles = {');
  data.forEach((id, v) => b.writeln("  '$id': ${setOf(v.$1)},"));
  b
    ..writeln('};')
    ..writeln()
    ..writeln('/// Layer id → tiles the server has no image for (HTTP 404).')
    ..writeln('const Map<String, Set<String>> emptyTiles = {');
  data.forEach((id, v) => b.writeln("  '$id': ${setOf(v.$2)},"));
  b.writeln('};');
  File(generatedFile).writeAsStringSync(b.toString());
}

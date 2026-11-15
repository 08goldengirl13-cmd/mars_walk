import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mars_walk/logic/geo.dart';
import 'package:mars_walk/map/bundled_tiles.g.dart';
import 'package:mars_walk/map/tile_layers.dart';

/// The bundled NASA tiles (tool/download_tiles.dart) must match their list.
void main() {
  final layers = [TrekLayers.viking, TrekLayers.mola, TrekLayers.hirise];

  test('every listed tile has its asset file', () {
    for (final layer in layers) {
      for (final key in bundledTiles[layer.id] ?? const <String>{}) {
        final [z, y, x] = key.split('/').map(int.parse).toList();
        final path = BundledTileProvider.assetFor(layer, z, y, x)!;
        expect(File(path).existsSync(), isTrue, reason: path);
      }
    }
  });

  test('no tile is both bundled and empty', () {
    for (final layer in layers) {
      final both = (bundledTiles[layer.id] ?? {}).intersection(emptyTiles[layer.id] ?? {});
      expect(both, isEmpty, reason: layer.id);
    }
  });

  test('the landing site is bundled for the base map and HiRISE', () {
    const lat = -4.589467, lon = 137.441633;
    final v = tileFor(lat, lon, 7);
    expect(BundledTileProvider.assetFor(TrekLayers.viking, v.z, v.row, v.col), isNotNull);
    final h = tileFor(lat, lon, 13);
    expect(BundledTileProvider.assetFor(TrekLayers.hirise, h.z, h.row, h.col), isNotNull);
  });
}

import 'dart:convert' show base64Decode;

import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:latlong2/latlong.dart';

import '../logic/app_settings.dart';
import 'bundled_tiles.g.dart';

/// One NASA Mars Trek equirectangular ("EQ") tile layer.
///
/// Zoom limits were checked on 2026-11-14 at Bradbury Landing (HTTP 200):
/// Viking/MOLA up to z7, Gale CTX up to z12, HiRISE up to z16. All five
/// layers returned `Access-Control-Allow-Origin: *`, so Flutter Web can draw them.
class TrekLayer {
  const TrekLayer(this.id, this.folder, this.ext, this.maxNativeZoom, {this.coverage});

  final String id;

  /// Folder under assets/tiles/ with the bundled copies of this layer.
  final String folder;
  final String ext;
  final int maxNativeZoom;

  /// Area the mosaic actually covers. Tiles outside it are never requested
  /// (the server would only answer 404 and slow the real tiles down).
  final LatLngBounds? coverage;

  /// Mars Trek grid = flutter_map's Epsg4326 grid (2 × 1 tiles at zoom 0),
  /// rows counted from the top, so `{y}` needs no TMS flip.
  String get urlTemplate =>
      'https://trek.nasa.gov/tiles/Mars/EQ/$id/1.0.0/default/default028mm/{z}/{y}/{x}.$ext';
}

class TrekLayers {
  TrekLayers._();

  static const viking = TrekLayer('Mars_Viking_MDIM21_ClrMosaic_global_232m', 'viking', 'jpg', 7);
  static const mola = TrekLayer('Mars_MGS_MOLA_ClrShade_merge_global_463m', 'mola', 'jpg', 7);

  /// Gale Crater (centre ≈ −5.4°, 137.8°, about 154 km wide).
  static final ctxGale = TrekLayer(
    'Gale_CTX_BlockAdj_dd',
    'ctx',
    'png',
    12,
    coverage: LatLngBounds(const LatLng(-6.9, 136.3), const LatLng(-3.9, 139.3)),
  );

  /// Measured on 2026-11-15: at z10 the mosaic answers 200 only for rows
  /// 536–540 and columns 1804–1807, i.e. about −5.10…−4.22° lat and
  /// 137.11…137.81° lon. Everything else is a 404.
  static final hirise = TrekLayer(
    'curiosity_hirise_mosaic',
    'hirise',
    'png',
    16,
    coverage: LatLngBounds(const LatLng(-5.10, 137.10), const LatLng(-4.21, 137.82)),
  );
}

const String _userAgentPackage = 'org.marswalk.app';

/// Mars Trek is slow (seconds per tile) and sometimes drops requests.
/// Retry network errors and server errors a few times instead of leaving a
/// hole in the map. 404s (outside a mosaic) are not retried.
http.Client _trekClient() => RetryClient(
  http.Client(),
  retries: 3,
  when: (r) => r.statusCode >= 500 || r.statusCode == 429,
  whenError: (_, _) => true,
);

/// 1 × 1 transparent PNG, shown where NASA has no image (known 404).
final MemoryImage _emptyTile = MemoryImage(
  base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
  ),
);

/// Serves tiles from the copies bundled by `tool/download_tiles.dart`
/// (Gale Crater and a band along the route), so the usual views appear
/// immediately. Everything else — deeper zooms, other places — still comes
/// from NASA Mars Trek over the network.
class BundledTileProvider extends TileProvider {
  BundledTileProvider(this.layer, this.network);

  final TrekLayer layer;
  final NetworkTileProvider network;

  /// Asset path of a bundled tile, or null if it is not bundled.
  static String? assetFor(TrekLayer layer, int z, int y, int x) {
    final bundled = bundledTiles[layer.id];
    if (bundled == null || !bundled.contains('$z/$y/$x')) return null;
    return 'assets/tiles/${layer.folder}/${z}_${y}_$x.${layer.ext}';
  }

  static bool isKnownEmpty(TrekLayer layer, int z, int y, int x) =>
      emptyTiles[layer.id]?.contains('$z/$y/$x') ?? false;

  @override
  bool get supportsCancelLoading => true;

  @override
  ImageProvider getImageWithCancelLoadingSupport(
    TileCoordinates coordinates,
    TileLayer options,
    Future<void> cancelLoading,
  ) {
    final (z, y, x) = (coordinates.z, coordinates.y, coordinates.x);
    final asset = assetFor(layer, z, y, x);
    if (asset != null) return AssetImage(asset);
    if (isKnownEmpty(layer, z, y, x)) return _emptyTile;
    return network.getImageWithCancelLoadingSupport(coordinates, options, cancelLoading);
  }

  // Shared between map rebuilds (see _providerFor), so nothing to close here.
  @override
  void dispose() {}
}

/// One shared provider per layer, so rebuilding the map (e.g. toggling a
/// layer) does not throw away tiles that are already loading.
final Map<String, BundledTileProvider> _providers = {};

BundledTileProvider _providerFor(TrekLayer layer, {required bool silent}) =>
    _providers.putIfAbsent(
      layer.id,
      () => BundledTileProvider(
        layer,
        NetworkTileProvider(httpClient: _trekClient(), silenceExceptions: silent),
      ),
    );

/// Global base map. Its errors mean "network problem", so they are reported.
Widget baseTileLayer(TrekLayer layer, TileStatus status) => TileLayer(
  key: ValueKey(layer.id),
  urlTemplate: layer.urlTemplate,
  maxNativeZoom: layer.maxNativeZoom,
  userAgentPackageName: _userAgentPackage,
  tileProvider: _providerFor(layer, silent: false),
  // Tiles that failed are dropped from memory, so they are asked for again
  // the next time they come into view.
  evictErrorTileStrategy: EvictErrorTileStrategy.notVisibleRespectMargin,
  errorTileCallback: (tile, error, stackTrace) => status.reportError(),
);

/// Local PNG mosaic with transparency. Only tiles inside its coverage are
/// requested; no extra ring of off-screen tiles, so the visible ones arrive
/// sooner from the slow server.
Widget overlayTileLayer(TrekLayer layer, double opacity) => Opacity(
  key: ValueKey(layer.id),
  opacity: opacity,
  child: TileLayer(
    urlTemplate: layer.urlTemplate,
    maxNativeZoom: layer.maxNativeZoom,
    tileBounds: layer.coverage,
    panBuffer: 0,
    userAgentPackageName: _userAgentPackage,
    tileProvider: _providerFor(layer, silent: true),
    evictErrorTileStrategy: EvictErrorTileStrategy.notVisibleRespectMargin,
  ),
);

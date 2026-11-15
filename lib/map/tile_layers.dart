import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';

import '../logic/app_settings.dart';

/// One NASA Mars Trek equirectangular ("EQ") tile layer.
///
/// Zoom limits were checked on 2026-11-14 at Bradbury Landing (HTTP 200):
/// Viking/MOLA up to z7, Gale CTX up to z12, HiRISE up to z16. All five
/// layers returned `Access-Control-Allow-Origin: *`, so Flutter Web can draw them.
class TrekLayer {
  const TrekLayer(this.id, this.ext, this.maxNativeZoom);

  final String id;
  final String ext;
  final int maxNativeZoom;

  /// Mars Trek grid = flutter_map's Epsg4326 grid (2 × 1 tiles at zoom 0),
  /// rows counted from the top, so `{y}` needs no TMS flip.
  String get urlTemplate =>
      'https://trek.nasa.gov/tiles/Mars/EQ/$id/1.0.0/default/default028mm/{z}/{y}/{x}.$ext';
}

class TrekLayers {
  TrekLayers._();

  static const viking = TrekLayer('Mars_Viking_MDIM21_ClrMosaic_global_232m', 'jpg', 7);
  static const mola = TrekLayer('Mars_MGS_MOLA_ClrShade_merge_global_463m', 'jpg', 7);
  static const ctxGale = TrekLayer('Gale_CTX_BlockAdj_dd', 'png', 12);
  static const hirise = TrekLayer('curiosity_hirise_mosaic', 'png', 16);
}

const String _userAgentPackage = 'org.marswalk.app';

/// Global base map. Its errors mean "network problem", so they are reported.
Widget baseTileLayer(TrekLayer layer, TileStatus status) => TileLayer(
  key: ValueKey(layer.id),
  urlTemplate: layer.urlTemplate,
  maxNativeZoom: layer.maxNativeZoom,
  userAgentPackageName: _userAgentPackage,
  tileProvider: NetworkTileProvider(),
  errorTileCallback: (tile, error, stackTrace) => status.reportError(),
);

/// Local PNG mosaic with transparency. Outside its coverage the server
/// answers 404 — that is normal, so errors are silenced (transparent tile).
Widget overlayTileLayer(TrekLayer layer, double opacity) => Opacity(
  key: ValueKey(layer.id),
  opacity: opacity,
  child: TileLayer(
    urlTemplate: layer.urlTemplate,
    maxNativeZoom: layer.maxNativeZoom,
    userAgentPackageName: _userAgentPackage,
    tileProvider: NetworkTileProvider(silenceExceptions: true),
  ),
);

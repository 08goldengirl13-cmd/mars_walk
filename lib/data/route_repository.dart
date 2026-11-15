import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'route_models.dart';

/// Loads the bundled route (created by `tool/prepare_data.dart`).
class RouteRepository {
  static const String routeAsset = 'assets/data/route.json';

  /// Never throws: falls back to the clearly-labelled demo route.
  static Future<RouteData> load() async {
    try {
      final text = await rootBundle.loadString(routeAsset);
      return parse(text);
    } catch (_) {
      return RouteData.demo();
    }
  }

  static RouteData parse(String text) {
    final json = jsonDecode(text) as Map<String, dynamic>;
    final data = RouteData.fromJson(json);
    if (data.points.length < 2) return RouteData.demo();
    return data;
  }
}

import 'package:flutter/widgets.dart';

import 'app.dart';

void main() {
  // `?nointro` in the URL skips the intro slides (handy for recording a demo).
  final skipIntro = Uri.base.queryParameters.containsKey('nointro');
  runApp(MarsWalkApp(showIntro: !skipIntro));
}

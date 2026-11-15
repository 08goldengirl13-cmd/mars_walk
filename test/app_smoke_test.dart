import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mars_walk/app.dart';
import 'package:mars_walk/data/route_repository.dart';

/// Smoke tests of the whole app without network tiles (no network in tests).
void main() {
  final route = RouteRepository.parse(File('assets/data/route.json').readAsStringSync());

  Future<void> pumpApp(WidgetTester tester, Size size, {bool intro = false}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MarsWalkApp(routeOverride: route, networkTiles: false, showIntro: intro),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('intro shows and can be skipped', (tester) async {
    await pumpApp(tester, const Size(1440, 900), intro: true);
    expect(find.text('You are the first human on Mars.'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('You are the first human on Mars.'), findsNothing);
  });

  testWidgets('desktop: play moves the astronaut, UZ toggle works', (tester) async {
    await pumpApp(tester, const Size(1440, 900));
    expect(find.text('Sol ${route.first.sol}'), findsWidgets);

    await tester.tap(find.byTooltip('Play'));
    await tester.pump();
    // 2 s of real frames (one 2 s frame would count as a hidden tab).
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Sol ${route.first.sol}'), findsNothing);
    await tester.tap(find.byTooltip('Pause'));
    await tester.pump();

    await tester.tap(find.text('UZ').first);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Missiya'), findsOneWidget);
    expect(find.text('TOSH QATLAMLARI'), findsOneWidget);
  });

  testWidgets('mission mode can be played to the end', (tester) async {
    await pumpApp(tester, const Size(1440, 900));
    await tester.tap(find.text('Mission'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Start mission'));
    await tester.pump(const Duration(milliseconds: 400));

    for (var i = 0; i < 5; i++) {
      // Always the last option on each card.
      final options = find.byType(OutlinedButton);
      expect(options, findsWidgets);
      await tester.tap(options.last);
      await tester.pump(const Duration(milliseconds: 400));
      final next = i == 4 ? find.text('See my result') : find.text('Next stop');
      await tester.ensureVisible(next);
      await tester.tap(next);
      await tester.pump(const Duration(milliseconds: 1500));
    }
    expect(find.text('Mission complete!'), findsOneWidget);
    expect(find.text('Copy my result'), findsOneWidget);
  });

  testWidgets('phone layout builds without overflow', (tester) async {
    await pumpApp(tester, const Size(390, 844));
    expect(tester.takeException(), isNull);
    expect(find.text('Mars Walk'), findsWidgets);
  });

  testWidgets('phone layout in Uzbek, mission cards and stop card fit', (tester) async {
    await pumpApp(tester, const Size(360, 740));
    await tester.tap(find.text('UZ').first);
    await tester.pump(const Duration(milliseconds: 300));

    // Play to the end so the fun-fact line shows.
    await tester.tap(find.byTooltip('Boshlash'));
    await tester.pump();
    for (var i = 0; i < 320; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.textContaining('marafon'), findsOneWidget);

    await tester.tap(find.byTooltip('Missiya'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.ensureVisible(find.text('Missiyani boshlash'));
    await tester.tap(find.text('Missiyani boshlash'));
    await tester.pump(const Duration(milliseconds: 400));
    for (var i = 0; i < 5; i++) {
      final options = find.byType(OutlinedButton);
      await tester.ensureVisible(options.first);
      await tester.tap(options.first);
      await tester.pump(const Duration(milliseconds: 1500));
      final next = i == 4 ? find.text('Natijamni ko‘rish') : find.text('Keyingi bekat');
      await tester.ensureVisible(next);
      await tester.tap(next);
      await tester.pump(const Duration(milliseconds: 1500));
    }
    expect(find.text('Missiya tugadi!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

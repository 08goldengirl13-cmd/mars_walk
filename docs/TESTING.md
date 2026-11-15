# Manual test checklist

Automatic checks first:

```bash
flutter pub get
flutter analyze      # expect: No issues found!
flutter test         # expect: All tests passed!
```

Then run the app: `flutter run -d chrome` (add `?nointro` to the URL to skip the intro).

| # | Check | Expected | OK? |
|---|---|---|---|
| 1 | App starts in Chrome | Dark "mission control" screen; intro slides appear | ☐ |
| 2 | Map tiles | Viking colour base + sharp grey HiRISE close-up around the route. Zoom in/out with wheel or pinch. Areas without HiRISE show the Viking map — no error messages | ☐ |
| 3 | Alignment | At Sol 3 the astronaut is at stop 1 (Bradbury Landing) at the top of the route. Press Play to the end: the astronaut ends at stop 6 on the mountain side. The amber line follows visible terrain (it crosses the dark dune band at a narrow gap) | ☐ |
| 4 | Time Machine | Play runs about 30 s at 1× (≈15 s at 2×, ≈7.5 s at 4×). Slider scrubbing moves the astronaut. Sol, km, elevation and tilt chips change. Elevation profile fills in amber. At the end a fun-fact line appears | ☐ |
| 5 | Layers + era scene | While playing, the highlighted rock layer moves up and the era scene cross-fades: lake → shrinking lake → dusty ridge → clay → dry desert. "Artist's concept" label is visible | ☐ |
| 6 | Mission mode | Mission → Start mission → 5 cards. Try every option type (go, halfway, study, ask Earth). Each result shows verdict, oxygen and energy bars, radiation, "What NASA actually did". End screen shows score and badges. "Copy my result" puts text in the clipboard | ☐ |
| 7 | Language | EN ⇄ UZ changes every visible text, including the mission, layers sheet, Sources screen and intro. No raw keys like `chipSol` | ☐ |
| 8 | Layouts | Desktop ~1440 px: side panel left, time dock bottom. Phone ~390 px (Chrome DevTools device mode): map on top, scene + layer column below, dock at the bottom, "⋮" menu for layers/sources/help | ☐ |
| 9 | Offline | Turn the network off (DevTools → Network → Offline) and reload the map area: an orange "Map pictures could not load" banner appears, the route and controls still work, no crash | ☐ |
| 10 | Sources | Every "Open link" opens the NASA page in a new tab without login | ☐ |
| 11 | Stops | Tap each numbered circle: a card with name, sol, km, elevation, NASA objective chips and "More" | ☐ |
| 12 | Map follow | While playing, drag the map: following stops and a "Re-centre" button appears. Press it: the camera returns to the astronaut | ☐ |
| 13 | Calm mode | Layers sheet → Calm mode: the scene stops moving, camera jumps instead of easing | ☐ |
| 14 | Deployed site | After GitHub Pages deploy, the live link opens in a private window (no login) | ☐ |

What was already checked by the developer agent (2026-11-14): `flutter analyze` clean,
`flutter test` passing (geo, mission model, route data, playback, i18n and whole-app
widget tests at 1440 px, 390 px and 360 px in English and Uzbek), `flutter build web`
succeeds, and headless-Chrome screenshots at 1440 × 900 and 390 × 844 showed the tiles,
the route on the HiRISE imagery and the panels. Items 2–14 still need a human with a
real browser (clicking, dragging, clipboard, offline mode, links).

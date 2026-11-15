# Mars Walk — walk 38 km on Mars in 90 seconds

**NASA Space Apps Challenge · Challenge #10 "Interplanetary Survival Guide: Martian Map"**

You are the first human on Mars. NASA's Curiosity rover has already walked this ground in Gale Crater for 14 years. Mars Walk lets you replay its **real** 38.6 km journey from NASA data, climb Mount Sharp through its ancient rock layers while the scene shows how Mars changed from a lake world to a dry desert, and then plan your own walks: the real distance, slope and climb of each leg decide whether you get back safely.

Made for young people (about 10–17) and anyone curious about Mars. Short sentences, big buttons, English and Uzbek.

**Live demo:** https://08goldengirl13-cmd.github.io/mars_walk/

## Screenshots

_Add after the first run._

## Features

- **Time Machine** — press Play and the astronaut follows Curiosity's real route (1,369 NASA waypoints) in 90 seconds at the default 0.5× speed (45 s at 1×). Drag the Sol slider to any Mars day. Live chips show sol, distance, elevation and terrain tilt; a mini elevation profile grows as you climb.
- **Climb through the layers** — a rock-layer column of Mount Sharp. The astronaut rises with the real elevation. Each layer has a short card ("Ancient lake floor", "Clay-rich layer", …) and an animated "Mars at that time" scene that cross-fades from lake to streams to dry, dusty desert. Clearly labelled as an artist's concept.
- **Mars today at Gale** — approximate modern temperature, pressure, radiation and gravity.
- **Mission mode** — 5 decision cards on real stops (Yellowknife Bay, Pahrump Hills, Bagnold Dunes, Glen Torridon, Curiosity's latest position). Go, walk halfway, study here or ask Earth. The result (Safe / Risky / Too far, oxygen, energy, radiation) is computed from the real leg, then "What NASA actually did here" is shown. Score, badges and "Copy my result".
- **NASA objectives** — each stop and card shows official NASA Moon to Mars objective codes (September 2022 edition).
- **Layers and sources** — Viking colour or MOLA relief base map, HiRISE and CTX close-ups, opacity, calm mode; a Sources screen with every dataset and link.
- **English + Uzbek (Latin)** toggle. Works on desktop and phone browsers.

## How NASA data is used (the heart of the project)

| Data | From | Used for |
|---|---|---|
| Viking MDIM 2.1 colour mosaic | NASA Mars Trek WMTS (`Mars_Viking_MDIM21_ClrMosaic_global_232m`) | Colour base map |
| MGS MOLA colour shaded relief | NASA Mars Trek WMTS (`Mars_MGS_MOLA_ClrShade_merge_global_463m`) | Relief base map |
| MRO HiRISE mosaic of the Curiosity site | NASA Mars Trek WMTS (`curiosity_hirise_mosaic`, up to zoom 16) | Sharpest close-up layer |
| MRO CTX Gale Crater mosaic | NASA Mars Trek WMTS (`Gale_CTX_BlockAdj_dd`) | Crater-wide close-up layer |
| Curiosity (MSL) waypoints | NASA/JPL MMGIS `MSL_waypoints.json` | The whole route: sol, position, elevation, rover tilt, distance driven |
| Moon to Mars Objectives (Sept 2022) | NASA | Objective chips on stops and cards |

- Map tiles are loaded live from `trek.nasa.gov` (equirectangular grid, no API key; CORS headers checked).
- The route file is downloaded once by `tool/prepare_data.dart`, cleaned (sorted, duplicates and distance glitches removed) and bundled as `assets/data/route.json`. **Every number on the map, the chips, the elevation profile, the layer column and the mission legs comes from this file.** Stop positions are looked up by sol in the data, never typed by hand.
- Snapshot used in this build: 1,369 waypoints, sol 3 → 5073, 38.64 km driven, elevation −4521 m → −3472 m (about 1,049 m of climbing range).

## Honesty and limitations

- Era scenes are an **artist's concept** based on published NASA interpretations. No ancient temperatures are shown.
- The mission model (walking speed 2.5 km/h, 8 h of oxygen, 20 % reserve, slower on tilted ground) is **our educational assumption**, not NASA data. Rover body tilt is only a rough proxy for slope.
- "Mars today" values are approximate. Era boundary sols and some stop facts are drafts listed in [`docs/VERIFY.md`](docs/VERIFY.md) for checking.
- Distances follow the rover's path, not a straight line.

## Tech stack

Flutter (web first, also mobile-friendly) · Dart · `flutter_map` (Epsg4326 CRS = Mars Trek EQ grid) · `latlong2` · `url_launcher` · `material_ui`. No backend, no accounts, no API keys, no tracking. All drawings (astronaut, scenes, charts) are made with `CustomPainter`.

## Run it

```bash
flutter pub get
dart run tool/prepare_data.dart   # optional: refresh the NASA route data
flutter run -d chrome             # add ?nointro to the URL to skip the intro slides
```

Tests and checks:

```bash
flutter analyze
flutter test
```

## Build and deploy

```bash
flutter build web --release --base-href /<repo-name>/
```

GitHub Pages: push to `main`, then in **Settings → Pages → Source** choose **GitHub Actions**. The workflow in `.github/workflows/deploy.yml` runs analyze, tests and the web build, then publishes `build/web`.

## Data sources and attribution

- Imagery: NASA/JPL-Caltech, NASA Mars Trek — https://trek.nasa.gov/tiles/apidoc/trekAPI.html?body=mars
- Route: NASA/JPL-Caltech MSL waypoints (MMGIS) — https://mars.nasa.gov/mmgis-maps/MSL/Layers/json/MSL_waypoints.json
- MSL mission overview, Space Science Reviews (2022) — https://link.springer.com/article/10.1007/s11214-022-00882-7
- NASA Moon to Mars Objectives (September 2022) — https://www.nasa.gov/MoonToMarsArchitecture

NASA imagery and data are used under NASA's public media and data guidelines, with attribution to NASA/JPL-Caltech. We do not claim ownership of NASA data. More in [`docs/DATA.md`](docs/DATA.md).

## License

Code: [MIT](LICENSE). Data: NASA (see above).

## Team

3 members: _Name 1_, _Name 2_, _Name 3_.

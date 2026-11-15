# Data sources, licences and how to refresh

## 1. NASA Mars Trek map tiles (live, no key)

URL template (equirectangular "EQ" grid):

```
https://trek.nasa.gov/tiles/Mars/EQ/{layer}/1.0.0/default/default028mm/{z}/{row}/{col}.{ext}
```

- Zoom 0 = 1 row × 2 columns; each zoom doubles both. Columns start at −180°, rows at +90°.
  This is the same grid as `flutter_map`'s `Epsg4326` CRS (checked in `test/geo_test.dart`).
- Tiles are 256 × 256 px.

| Layer ID | ext | Max zoom used | Role in app |
|---|---|---|---|
| `Mars_Viking_MDIM21_ClrMosaic_global_232m` | jpg | 7 | Base map "Viking colour" (default) |
| `Mars_MGS_MOLA_ClrShade_merge_global_463m` | jpg | 7 | Base map "MOLA relief" |
| `Gale_CTX_BlockAdj_dd` | png | 12 | Overlay "CTX" (off by default) |
| `curiosity_hirise_mosaic` | png | 16 | Overlay "HiRISE" (on by default) |

Checked on 2026-11-14 at Bradbury Landing: all return HTTP 200 and
`Access-Control-Allow-Origin: *`. PNG layers return 404 outside their coverage; the app
treats that as a transparent tile. Errors from the global base map are counted and show
an "offline" banner.

API documentation: https://trek.nasa.gov/tiles/apidoc/trekAPI.html?body=mars

### Bundled tiles (fast start)

Mars Trek answers slowly (often 2–15 s per tile), so the tiles for the usual
views are downloaded once and shipped with the app:

```bash
dart run tool/download_tiles.dart            # downloads only what is missing
dart run tool/download_tiles.dart --dry-run  # just count the tiles
```

- Viking and MOLA: z3–z7 over Gale Crater (20 tiles each).
- HiRISE: z9–z11 over the whole mosaic, z12–z13 in a band along the route
  (the camera follows the astronaut at z13 while playing).
- Snapshot 2026-11-15: 392 images, 19.4 MB in `assets/tiles/`; 80 HiRISE tiles
  have no image on the server (404) and are drawn transparent without asking.
- The list lives in the generated `lib/map/bundled_tiles.g.dart`;
  `test/bundled_tiles_test.dart` checks every listed file exists.
- Anything not bundled (deeper zoom, CTX, other places) still loads live.

## 2. Curiosity route (bundled)

- Source: https://mars.nasa.gov/mmgis-maps/MSL/Layers/json/MSL_waypoints.json (NASA/JPL-Caltech, MMGIS)
- Not fetched at runtime (its CORS policy is not guaranteed). Instead:

```bash
dart run tool/prepare_data.dart          # download + clean + write assets
dart run tool/prepare_data.dart --local  # use tool/raw/MSL_waypoints.json only
```

If the download fails, open the URL in a browser, save the file as
`tool/raw/MSL_waypoints.json` and run with `--local`.

What the script does:
1. Reads `sol`, `lon`, `lat`, `elev_geoid` (fallback: geometry z), `tilt`, `dist_total_m`.
2. Prints a summary (count, drive types, elevation and sol range, monotonic checks).
3. Sorts by (sol, distance) if needed, drops duplicate positions and points that go
   backwards in distance (the 2026-11-14 file had several `dist_total_m = 0` glitches
   and one reset to 18.31 m).
4. Writes `assets/data/route.json` (`[sol, lon, lat, elev, tilt, distM]` per point) and
   `assets/data/route_meta.json` (summary numbers).

Snapshot in this repository: downloaded 2026-11-14, 1,369 points, sol 3 → 5073,
38.638 km, elevation −4521.31 → −3472.09 m.

After refreshing, run `flutter test` — `test/route_data_test.dart` checks the invariants
and that the meta file matches. Then re-check the stop rows in `docs/VERIFY.md`.

If `assets/data/route.json` is missing, the app falls back to a tiny straight demo route
and shows a yellow "Demo data" banner. It never pretends the demo is real.

## 3. Other references

- MSL mission overview, Space Science Reviews (2022): https://link.springer.com/article/10.1007/s11214-022-00882-7
- PDS Analyst's Notebook: https://an.rsl.wustl.edu
- NASA Moon to Mars Objectives, September 2022 edition: https://www.nasa.gov/MoonToMarsArchitecture

## 4. Licences and attribution

- Code: MIT (see `LICENSE`).
- NASA imagery and data: public NASA data, used under NASA's media and data usage
  guidelines. Attribution shown in the app: "Imagery: NASA/JPL-Caltech · Mars Trek.
  Route: NASA/JPL MSL." We do not claim ownership of NASA data and do not imply NASA
  endorsement.
- No photos of people and no third-party art are used; all visuals are drawn in code.

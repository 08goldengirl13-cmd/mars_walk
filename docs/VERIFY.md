# VERIFY — facts to check before submission

Every `// VERIFY` comment in the code is listed here. Check each row, then either
keep the text, soften it ("around", "about"), or remove it. Data-verified rows are
listed at the bottom for completeness.

Useful places to check:
- NASA Curiosity mission page and news: https://science.nasa.gov/mission/msl-curiosity/
- PDS Analyst's Notebook (sols, targets, drill holes): https://an.rsl.wustl.edu
- MSL overview paper (Space Science Reviews, 2022): https://link.springer.com/article/10.1007/s11214-022-00882-7
- NASA/JPL traverse maps, e.g. first 1,185 sols: https://www.jpl.nasa.gov/images/curiosity-rovers-traverse-first-1185-sols-on-mars

## 1. Era / rock-layer boundaries (`lib/data/strata_content.dart`)

The app converts each start sol to a position and elevation **from the route data**.
Only the sol numbers are drafts.

| Claim | Where in app | Value in app | Data lookup (first waypoint ≥ sol) | What to check | Where |
|---|---|---|---|---|---|
| Era 1 "Ancient lake floor" starts at landing | Strata column, layer card | sol 0 | sol 3, −4500.97 m | — (data-verified) | — |
| Era 2 "Layers of lake mud" (Murray) starts | Strata column | sol 750 | sol 751, −4459.42 m, 9.44 km | Pahrump Hills / Murray arrival sol | Mission updates Sept 2014; Analyst's Notebook |
| Era 3 "Vera Rubin Ridge" starts | Strata column | sol 1800 | sol 1800, −4209.11 m, 17.51 km | Start of the ridge ascent | Mission updates Sept 2017 |
| Era 4 "Clay-rich layer" (Glen Torridon) starts | Strata column | sol 2300 | sol 2300, −4140.06 m, 20.24 km | Glen Torridon entry sol | Mission updates early 2019 |
| Era 5 "Salty sulfate layers" starts | Strata column | sol 3400 | sol 3400, −3968.21 m, 27.62 km | Sulfate-bearing unit entry sol | Mission updates 2021–2022; overview paper |

## 2. Era texts (`lib/data/strata_content.dart`)

| Claim | Where | What to check | Where |
|---|---|---|---|
| "Rivers and a lake once flowed here. Mud settled at the bottom." | Layer card, era 1 | Lake/stream interpretation of Yellowknife Bay rocks | NASA news 2013; overview paper |
| "History that starts about 3.6 billion years ago" | Era 1 "More" | Number and wording | MSL overview paper 2022 (spec §4.3) |
| "Calm lake; tiny life could have lived in that water — if life ever existed" | Era 1 "More" | Habitability wording (not a claim of life) | NASA news 2013 |
| "Murray formation is a thick stack of mudstone; lake stayed long, maybe on and off" | Era 2 | Murray description | Mission updates 2015–2017 |
| "Hard iron-rich ridge; hematite seen from orbit; groundwater changed the rocks" | Era 3 | Vera Rubin Ridge results | Mission updates 2017–2019 |
| "Orbiters saw lots of clay in Glen Torridon; Curiosity drilled there" | Era 4 | Clay-bearing unit description | Mission updates 2019–2021 |
| "Higher layers hold salty sulfate minerals; Mars drying out" | Era 5 | Sulfate unit interpretation | Mission updates 2021–2023 |
| "NASA reported rocks made of pure sulfur in Gediz Vallis" | Era 5 "More" | The sulfur discovery and its wording | NASA news 2024 |

## 3. Stops (`lib/data/stops_content.dart`)

Positions are looked up in the data: the last waypoint with sol ≤ target.

| Stop | Target sol (draft) | Data lookup result | What to check | Where |
|---|---|---|---|---|
| 1 Bradbury Landing | first waypoint | sol 3, lat −4.589467, lon 137.441633, −4500.97 m | Landing month "August 2012" | NASA MSL mission page |
| 2 Yellowknife Bay | 182 | sol 166, lat −4.589485, lon 137.449130, −4520.46 m, 0.72 km | John Klein drill sol; "first rock drilled"; "chemistry life could use" | Analyst's Notebook; NASA news Feb–Mar 2013 |
| 2 Yellowknife Bay | — | Lowest route point is sol 127 (−4521.31 m), same area | "This area holds the lowest point" — data-verified | `assets/data/route.json` |
| 3 Pahrump Hills | 750 | sol 748, lat −4.661054, lon 137.376779, −4459.51 m, 9.32 km | Arrival sol; "first rocks of Mount Sharp itself" | Mission updates Sept 2014 |
| 4 Bagnold Dunes | 1165 | sol 1162, lat −4.676310, lon 137.366053, −4432.32 m, 11.72 km | Visit sol; "first close-up study of active dunes on another planet"; "still move today" | JPL news Dec 2015; traverse map first 1,185 sols |
| 5 Glen Torridon | 2300 | sol 2300, lat −4.729274, lon 137.379569, −4140.06 m, 20.24 km | Entry sol; clay unit wording. The ISRU/water question is our idea, phrased as an open question | Mission updates 2019 |
| 6 Latest position | last waypoint | sol 5073, lat −4.826023, lon 137.388886, −3472.09 m, 38.64 km | "Curiosity keeps climbing Mount Sharp" still true on submission day | NASA MSL page |
| Pahrump "More" | — | — | "Mount Sharp rises about 5 km above the crater floor" — from spec §4.3 (some sources say 5.5 km) | — |

## 4. Mission cards — "What NASA actually did here" (`lib/data/cards_content.dart`)

| Card | Text | What to check | Where |
|---|---|---|---|
| Yellowknife Bay | "Drilled here in early 2013; found clay minerals and chemical elements that tiny life could use" | Date and findings | NASA news March 2013 |
| Pahrump Hills | "Spent months here studying thin layers of lake mud" | Duration (Sept 2014 – early 2015?) | Mission updates |
| Bagnold Dunes | "Scooped sand from Namib Dune and watched grains move with the wind" | Dune name, scooping, observed motion | JPL news 2015–2016 |
| Glen Torridon | "Drilled several holes; found the most clay minerals of its mission so far" | "Highest clay amounts" wording | NASA news 2019 |
| Latest position | "Still driving; climbing through sulfate layers" | Status on submission day | NASA MSL page |

## 5. Modern conditions and model constants

| Claim | Where | Value | What to check | Where |
|---|---|---|---|---|
| Air temperature range | "Mars today" card | about −90 °C to 0 °C | Typical REMS range at Gale | PDS REMS docs / NASA |
| Air pressure | "Mars today" card | about 0.7–0.9 kPa, < 1 % of Earth | REMS seasonal range | PDS REMS docs |
| Surface radiation | "Mars today" card and `MissionConstants.radiationMsvPerDay` | about 0.6 mSv per day | RAD surface dose rate | Hassler et al., Science 2014; PDS RAD docs |
| Gravity | "Mars today" card | 0.38 g | Standard value | — |
| Sources link | Sources screen | https://science.nasa.gov/mission/msl-curiosity/ | The link opens without login | Browser |
| Intro: "explored this ground for 14 years" | Intro slide 2 | 2012 → 2026 | Matches the landing year | NASA MSL page |

Model constants in `lib/logic/mission_model.dart` (`walkSpeedKmh` 2.5, `suitHours` 8,
`reserveFraction` 0.2, `effortFromTilt = 1 + tilt/15`, `studyHours` 2,
`energyPctPerHour` 6, scoring) are **our assumptions**, labelled as such in the app
(Sources screen and "Walking model" note). They do not need NASA checking.

## 6. Already verified

- **Route data** (`assets/data/route.json`): downloaded 2026-11-14 from NASA/JPL MMGIS;
  1,389 features → 1,369 points after removing 13 duplicate positions and 7 distance
  glitches (points with `dist_total_m` = 0 or a reset to 18.31 m). Sol 3 → 5073,
  38.64 km, −4521.31 m → −3472.09 m. Checked by `test/route_data_test.dart`.
- **Mars Trek tiles**: on 2026-11-14 all five layers returned HTTP 200 at Bradbury
  Landing with `Access-Control-Allow-Origin: *` (Viking z7, MOLA z7, Gale CTX z12,
  curiosity CTX z10, HiRISE z16). Tiles are 256 × 256 px. The Trek grid equals
  flutter_map's Epsg4326 grid (`test/geo_test.dart`), and a browser screenshot showed
  the route following the terrain on the HiRISE mosaic.
- **NASA Moon to Mars objective codes** (section 9.7 of the spec): verified against the
  NASA PDF "Moon to Mars Objectives", September 2022. Only the 18 codes in
  `lib/data/objectives_content.dart` are used; `test/playback_and_i18n_test.dart`
  fails if any other code appears. The LPS-4 superscript is printed unclearly in the
  PDF and is treated as Mars-relevant.

# Mars Walk — project page text (draft)

## Summary

Mars Walk lets anyone walk NASA Curiosity's real 38.6 km route across Gale Crater in 30 seconds. You climb Mount Sharp through its ancient rock layers while the scene shows Mars changing from a lake world to a dry desert. Then you plan your own walks, and the real distance, slope and climb from NASA data decide if you make it back safely.

## The problem

Mars feels far away and complicated. Real NASA maps and datasets are powerful, but they are made for scientists. Young people and ordinary visitors see numbers and layers they cannot read, so the story of Mars — and of how hard it will be for humans to walk there — gets lost.

## Our solution

One full-screen map of Gale Crater and three simple experiences:

1. **Time Machine** — press Play and an astronaut follows Curiosity's real path, sol by sol. Distance, elevation and slope update live, and an elevation profile grows as you climb.
2. **Climb through the layers** — a rock-layer column of Mount Sharp follows your real elevation. Each layer has a two-sentence card and an animated "Mars at that time" scene (lake → streams → drying → cold desert).
3. **Mission mode** — five decision cards on real stops. Walk on, walk halfway, study here, or ask Earth. The outcome (Safe, Risky, Too far; oxygen, energy, radiation) is computed from the real leg, and then we show what NASA actually did there.

## How we use NASA data

- **NASA Mars Trek map tiles** (live): Viking MDIM 2.1 colour mosaic and MGS MOLA colour relief as base maps; MRO HiRISE mosaic of the Curiosity site and MRO CTX Gale Crater mosaic as sharp overlays.
- **NASA/JPL MSL waypoints** (MMGIS JSON): 1,369 cleaned waypoints with sol, position, elevation, rover tilt and distance. This one file drives the animation, the stat chips, the elevation profile, the rock-layer column, the stop positions and every mission leg.
- **NASA Moon to Mars Objectives** (September 2022): each stop and card shows the official objective codes it connects to (for example LPS-4 habitable environments, AS-1 surface environment, RT-3 crew return, OP-2 working with communication delays).

## What makes it creative

Instead of "go from A to B on a map", you **replay a real robot's journey as a human**, and the same data powers a climb through geological time and a survival game. The rock layers, the climate scene and the decisions are all tied to one real route.

## Scientific validity and limitations

- Real data: the route, positions, sols, distances, elevations, tilt, and the map imagery.
- Educational approximations, clearly labelled in the app: the era scenes (artist's concept based on published NASA interpretations, no invented ancient temperatures), the walking model (2.5 km/h, 8 h of oxygen, 20 % reserve, slower on tilted ground — our assumptions), and approximate "Mars today" values from Curiosity's REMS and RAD.
- Distances follow the rover's path. Rover tilt is only a rough proxy for slope.
- A Sources screen inside the app lists every dataset and link.

## Impact for young people and teachers

- Works in any browser, on phones and laptops, with no login and no install.
- English and Uzbek, short sentences, big buttons — usable in classrooms where English is not the first language.
- A 5-minute lesson: play the route, read the layer cards, then let students compete in Mission mode and compare their choices with what NASA did.

## How to use it

Open the link, press **Play**, drag the **Sol** slider, tap numbered stops, then press **Mission**.

## Tech

Flutter Web (Dart), `flutter_map` with an equirectangular CRS that matches the Mars Trek tile grid, all graphics drawn with `CustomPainter`. No backend, no API keys, no tracking. Unit and widget tests run in GitHub Actions before each deploy to GitHub Pages.

## Team

_Name 1_, _Name 2_, _Name 3_.

## Links

- Live demo: _add link_
- GitHub: _add link_
- Video (30 s): _add link_

## Credits and sources

- Imagery: NASA/JPL-Caltech, NASA Mars Trek — https://trek.nasa.gov
- Route: NASA/JPL-Caltech MSL waypoints (MMGIS) — https://mars.nasa.gov/mmgis-maps/MSL/Layers/json/MSL_waypoints.json
- MSL mission overview, Space Science Reviews (2022) — https://link.springer.com/article/10.1007/s11214-022-00882-7
- NASA Moon to Mars Objectives (September 2022) — https://www.nasa.gov/MoonToMarsArchitecture

import '../i18n/strings.dart';

class DataSource {
  const DataSource({
    required this.name,
    required this.usedFor,
    this.url,
    this.approximation = false,
  });

  final String name;
  final Tr usedFor;

  /// Null when there is nothing to link to.
  final String? url;

  /// True when what we show from it is an approximation.
  final bool approximation;
}

const List<DataSource> dataSources = [
  DataSource(
    name: 'NASA Mars Trek — WMTS map tiles',
    usedFor: Tr(
      'All map pictures. Equirectangular tiles, no key needed.',
      'Barcha xarita suratlari. Ekvidistant tile’lar, kalit kerak emas.',
    ),
    url: 'https://trek.nasa.gov/tiles/apidoc/trekAPI.html?body=mars',
  ),
  DataSource(
    name: 'Viking MDIM 2.1 colour mosaic (Mars Trek layer)',
    usedFor: Tr('Colour base map of Mars.', 'Marsning rangli asosiy xaritasi.'),
    url: 'https://trek.nasa.gov/mars/',
  ),
  DataSource(
    name: 'MGS MOLA colour shaded relief (Mars Trek layer)',
    usedFor: Tr(
      'Relief base map (height shown as colour).',
      'Relyef xaritasi (balandlik rang bilan ko‘rsatilgan).',
    ),
    url: 'https://trek.nasa.gov/mars/',
  ),
  DataSource(
    name: 'MRO HiRISE mosaic of the Curiosity site (Mars Trek layer)',
    usedFor: Tr(
      'Sharpest close-up pictures along the route.',
      'Yo‘l bo‘ylab eng aniq yaqin suratlar.',
    ),
    url: 'https://trek.nasa.gov/mars/',
  ),
  DataSource(
    name: 'MRO CTX Gale Crater mosaic (Mars Trek layer)',
    usedFor: Tr(
      'Close-up pictures of the whole crater area.',
      'Butun krater hududining yaqin suratlari.',
    ),
    url: 'https://trek.nasa.gov/mars/',
  ),
  DataSource(
    name: 'NASA/JPL MMGIS — Curiosity (MSL) waypoints',
    usedFor: Tr(
      'The real route: sol, position, elevation, tilt and distance of every waypoint.',
      "Haqiqiy yo‘l: har bir nuqtaning soli, joyi, balandligi, qiyaligi va masofasi.",
    ),
    url: 'https://mars.nasa.gov/mmgis-maps/MSL/Layers/json/MSL_waypoints.json',
  ),
  DataSource(
    name: 'MSL mission overview (Space Science Reviews, 2022)',
    usedFor: Tr(
      'Background on the rock layers of Mount Sharp.',
      'Sharp tog‘i qatlamlari haqida asosiy ma’lumot.',
    ),
    url: 'https://link.springer.com/article/10.1007/s11214-022-00882-7',
  ),
  DataSource(
    name: 'PDS Analyst\'s Notebook (MSL)',
    usedFor: Tr(
      'Checking sols and places of stops.',
      'Bekatlarning sollari va joylarini tekshirish.',
    ),
    url: 'https://an.rsl.wustl.edu',
  ),
  DataSource(
    name: 'NASA Curiosity mission page (REMS weather, RAD radiation)',
    usedFor: Tr(
      '"Mars today" values and the radiation rate in the mission model.',
      '"Bugungi Mars" qiymatlari va missiya modelidagi radiatsiya darajasi.',
    ),
    // VERIFY: link target — NASA Science MSL mission page.
    url: 'https://science.nasa.gov/mission/msl-curiosity/',
    approximation: true,
  ),
  DataSource(
    name: 'NASA Moon to Mars Objectives (September 2022 edition)',
    usedFor: Tr(
      'Objective chips on stops and cards (codes AS, HBS, HS, LPS, MI, OP, RT, SE, TH).',
      'Bekat va kartalardagi maqsad belgilari (AS, HBS, HS, LPS, MI, OP, RT, SE, TH kodlari).',
    ),
    url: 'https://www.nasa.gov/MoonToMarsArchitecture',
  ),
  DataSource(
    name: 'Mars Walk mission model (our assumptions)',
    usedFor: Tr(
      'Walking speed 2.5 km/h, 8 h of oxygen, 20 % reserve, slower on tilted ground.',
      'Yurish tezligi 2,5 km/soat, 8 soat kislorod, 20 % zaxira, qiya yerda sekinroq.',
    ),
    url: null,
    approximation: true,
  ),
];

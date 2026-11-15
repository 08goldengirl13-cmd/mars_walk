import '../i18n/strings.dart';
import '../logic/geo.dart';
import 'route_models.dart';

/// A science stop. Coordinates are NEVER typed in by hand: the app looks up
/// where the rover was on [solTarget] in the NASA route data.
class Stop {
  const Stop({
    required this.id,
    required this.solTarget,
    required this.name,
    required this.short,
    required this.more,
    required this.verifyNote,
    required this.objectiveCodes,
  });

  final String id;

  /// Sol to look up in the data. `0` = first waypoint, [lastSol] = last one.
  final int solTarget;
  final Tr name;
  final Tr short;
  final Tr more;

  /// What still needs checking (empty if data-verified). Listed in docs/VERIFY.md.
  final String verifyNote;

  /// Official NASA Moon to Mars objective codes (see objectives_content.dart).
  final List<String> objectiveCodes;

  static const int lastSol = 1 << 30;

  /// Index of this stop in [points].
  int indexIn(List<RoutePoint> points) {
    if (solTarget <= 0) return 0;
    if (solTarget >= lastSol) return points.length - 1;
    return indexAtSol(points, solTarget);
  }
}

const List<Stop> stops = [
  Stop(
    id: 'bradbury',
    solTarget: 0,
    name: Tr('Bradbury Landing', 'Bradbury qo‘nish joyi'),
    // VERIFY: landing date August 2012 — NASA MSL mission page.
    short: Tr(
      'Curiosity landed here in August 2012. This is your base.',
      "Curiosity bu yerga 2012-yil avgustda qo‘ngan. Bu sizning bazangiz.",
    ),
    more: Tr(
      'The position comes from the first NASA waypoint in our data. '
          'Every walk in this app starts and ends here.',
      "Joylashuv ma’lumotlarimizdagi birinchi NASA nuqtasidan olingan. "
          "Ilovadagi har bir yurish shu yerda boshlanadi va tugaydi.",
    ),
    verifyNote: 'Position data-verified (first waypoint). Landing date: check NASA MSL page.',
    objectiveCodes: ['OP-5', 'AS-1', 'TH-7'],
  ),
  Stop(
    id: 'yellowknife',
    solTarget: 182, // VERIFY: John Klein drill sol (draft 182)
    name: Tr('Yellowknife Bay', 'Yellowknife ko‘rfazi'),
    // VERIFY: first drill hole "John Klein"; chemical ingredients for life found.
    short: Tr(
      'Curiosity drilled its first rock here. The powder showed chemistry that life could use.',
      "Curiosity birinchi toshini shu yerda burg‘ulagan. Kukunda hayot ishlatishi mumkin bo‘lgan kimyo topilgan.",
    ),
    more: Tr(
      'The drilled rock was named "John Klein". It is mud rock from an old lake. '
          'This area holds the lowest point of the whole route (from the data).',
      "Burg‘ulangan tosh \"John Klein\" deb nomlangan. Bu qadimgi ko‘lning loy toshi. "
          "Butun yo‘lning eng past nuqtasi shu hududda (ma’lumotlardan).",
    ),
    verifyNote: 'Drill sol (~182) and John Klein results — NASA MSL news, Analyst\'s Notebook.',
    objectiveCodes: ['LPS-4', 'SE-4'],
  ),
  Stop(
    id: 'pahrump',
    solTarget: 750, // VERIFY: Pahrump Hills arrival (draft ~750)
    name: Tr('Pahrump Hills', 'Pahrump tepaliklari'),
    // VERIFY: first outcrop of the base of Mount Sharp.
    short: Tr(
      'The first rocks of Mount Sharp itself. Curiosity studied them layer by layer.',
      "Sharp tog‘ining o‘zidagi birinchi toshlar. Curiosity ularni qatlam-qatlam o‘rgangan.",
    ),
    more: Tr(
      'Here the rover reached the base of the mountain. '
          'Mount Sharp rises about 5 km above the crater floor.',
      "Bu yerda rover tog‘ etagiga yetgan. "
          "Sharp tog‘i krater tubidan taxminan 5 km balandlikka ko‘tariladi.",
    ),
    verifyNote: 'Arrival sol (~750) — NASA MSL mission updates.',
    objectiveCodes: ['LPS-2', 'SE-5'],
  ),
  Stop(
    id: 'bagnold',
    solTarget: 1165, // VERIFY: Bagnold Dunes visit (draft ~1165)
    name: Tr('Bagnold Dunes', 'Bagnold qumtepalari'),
    // VERIFY: first close-up study of active dunes on another planet.
    short: Tr(
      'Dark sand dunes that still move with the wind today.',
      "Bugun ham shamol bilan siljiydigan qora qum tepalari.",
    ),
    more: Tr(
      'NASA called this the first close-up study of active sand dunes on another planet. '
          'Moving sand and dust matter for astronaut safety and machines.',
      "NASA buni boshqa sayyoradagi faol qumtepalarni birinchi yaqindan o‘rganish deb atagan. "
          "Harakatlanuvchi qum va chang astronavtlar xavfsizligi va texnika uchun muhim.",
    ),
    verifyNote: 'Visit sol (~1165) and "first active dunes" claim — NASA/JPL news 2015–2016.',
    objectiveCodes: ['AS-1', 'LPS-2'],
  ),
  Stop(
    id: 'glen_torridon',
    solTarget: 2300, // VERIFY: Glen Torridon entry (draft ~2300)
    name: Tr('Glen Torridon', 'Glen Torridon'),
    // VERIFY: clay-bearing unit; any ISRU water link is our idea, not a NASA claim.
    short: Tr(
      'A valley full of clay minerals. Clay forms in water.',
      "Gil minerallariga to‘la vodiy. Gil suvda hosil bo‘ladi.",
    ),
    more: Tr(
      'Water-made minerals are interesting for future crews too: '
          'could they help find water to use on Mars? That is still an open question.',
      "Suv hosil qilgan minerallar kelajakdagi ekipajlar uchun ham qiziq: "
          "ular Marsda ishlatish uchun suv topishga yordam beradimi? Bu hali ochiq savol.",
    ),
    verifyNote: 'Entry sol (~2300); clay unit description — NASA MSL updates 2019.',
    objectiveCodes: ['LPS-4', 'AS-3', 'MI-4'],
  ),
  Stop(
    id: 'latest',
    solTarget: Stop.lastSol,
    name: Tr('Latest position', 'Oxirgi joylashuv'),
    short: Tr(
      'The newest point in our NASA data. Curiosity keeps climbing Mount Sharp.',
      "NASA ma’lumotlarimizdagi eng yangi nuqta. Curiosity Sharp tog‘iga ko‘tarilishda davom etmoqda.",
    ),
    more: Tr(
      'From here the higher layers of the mountain are still unexplored. '
          'Long-term instruments could watch this place for years.',
      "Bu yerdan tog‘ning yuqori qatlamlari hali o‘rganilmagan. "
          "Uzoq muddatli asboblar bu joyni yillar davomida kuzatishi mumkin.",
    ),
    verifyNote: 'Position data-verified (last waypoint).',
    objectiveCodes: ['LPS-1', 'SE-6'],
  ),
];

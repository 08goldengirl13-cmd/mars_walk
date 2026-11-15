import 'dart:ui' show Color;

import '../i18n/strings.dart';
import '../logic/era_visual.dart';

/// One rock layer / era of Mount Sharp along Curiosity's route.
/// Positions and elevations are NOT typed in: the app looks them up in the
/// NASA route data at [solStart].
class Era {
  const Era({
    required this.id,
    required this.solStart,
    required this.name,
    required this.short,
    required this.more,
    required this.bandColor,
    required this.visual,
  });

  final String id;

  /// First sol of this era on the route (DRAFT — see docs/VERIFY.md).
  final int solStart;
  final Tr name;
  final Tr short;
  final Tr more;
  final Color bandColor;
  final EraVisualState visual;
}

// VERIFY: every era boundary sol below is a DRAFT from background knowledge of
// the Curiosity mission — check against NASA MSL mission updates
// (science.nasa.gov/mission/msl-curiosity), the PDS Analyst's Notebook
// (an.rsl.wustl.edu) and the MSL overview paper (Space Science Reviews 2022).
const List<Era> eras = [
  Era(
    id: 'floor',
    solStart: 0, // Bradbury Landing (first waypoint, data-verified)
    name: Tr('Ancient lake floor', 'Qadimgi ko‘l tubi'),
    // VERIFY: Yellowknife Bay lake/stream interpretation — MSL mission updates 2013.
    short: Tr(
      'Rivers and a lake once flowed here. Mud settled at the bottom.',
      "Bir paytlar bu yerda daryolar va ko‘l bo‘lgan. Tubiga loy cho‘kkan.",
    ),
    // VERIFY: "about 3.6 billion years" is from the MSL overview paper (2022);
    // "calm, not very salty water" — check NASA Yellowknife Bay results.
    more: Tr(
      'The rocks of Mount Sharp record a long history that starts about 3.6 billion years ago. '
          'Near Yellowknife Bay, Curiosity found fine mud rock from a calm lake. '
          'Scientists say tiny life could have lived in that water — if life ever existed on Mars.',
      "Sharp tog‘i toshlari taxminan 3,6 milliard yil oldin boshlangan uzoq tarixni saqlaydi. "
          "Yellowknife ko‘rfazi yaqinida Curiosity sokin ko‘lning mayda loy toshini topdi. "
          "Olimlarning fikricha, u suvda mayda hayot yashashi mumkin edi — agar Marsda hayot bo‘lgan bo‘lsa.",
    ),
    bandColor: Color(0xFF5B6075),
    visual: EraVisualState(
      skyTop: Color(0xFF3D6E9C),
      skyBottom: Color(0xFFBCCAD3),
      ground: Color(0xFF5E4A3A),
      water: 0.85,
      streams: 1.0,
      dust: 0.08,
      sun: 0.95,
      wind: 0.1,
    ),
  ),
  Era(
    id: 'murray',
    solStart: 750, // VERIFY: Pahrump Hills arrival sol (draft ~750)
    name: Tr('Layers of lake mud', 'Ko‘l loyi qatlamlari'),
    // VERIFY: Murray formation = thick lake mudstone; repeated lake episodes.
    short: Tr(
      'Layer after layer of lake mud piled up. The climate slowly changed.',
      "Ko‘l loyi qatlam-qatlam bo‘lib to‘plangan. Iqlim asta-sekin o‘zgargan.",
    ),
    more: Tr(
      'This part is called the Murray formation. It is a thick stack of mudstone, '
          'which means a lake stayed here for a long time, maybe on and off.',
      "Bu qism Murray formatsiyasi deyiladi. U qalin loy tosh qatlami — "
          "demak, bu yerda ko‘l uzoq vaqt, balki to‘xtab-to‘xtab, turgan.",
    ),
    bandColor: Color(0xFF9C5B3C),
    visual: EraVisualState(
      skyTop: Color(0xFF5B7491),
      skyBottom: Color(0xFFD2BBA2),
      ground: Color(0xFF7A4E36),
      water: 0.55,
      streams: 0.45,
      dust: 0.3,
      sun: 0.85,
      wind: 0.25,
    ),
  ),
  Era(
    id: 'ridge',
    solStart: 1800, // VERIFY: Vera Rubin Ridge climb start (draft ~1800)
    name: Tr('Vera Rubin Ridge', 'Vera Rubin tizmasi'),
    // VERIFY: hematite-rich ridge; altered by groundwater.
    short: Tr(
      'A hard ridge of iron-rich rock. It stands up because wind cannot wear it down easily.',
      "Temirga boy qattiq tosh tizmasi. Shamol uni oson yemira olmagani uchun baland turadi.",
    ),
    more: Tr(
      'Orbiters saw the iron mineral hematite here. Water moving underground probably '
          'changed these rocks long after they formed.',
      "Orbitadagi apparatlar bu yerda gematit (temir minerali) ko‘rgan. "
          "Yer ostidagi suv bu toshlarni ular hosil bo‘lganidan ancha keyin o‘zgartirgan bo‘lishi mumkin.",
    ),
    bandColor: Color(0xFF7A2E2E),
    visual: EraVisualState(
      skyTop: Color(0xFF86675A),
      skyBottom: Color(0xFFD9A57E),
      ground: Color(0xFF7A3A2A),
      water: 0.15,
      streams: 0.1,
      dust: 0.6,
      sun: 0.75,
      wind: 0.6,
    ),
  ),
  Era(
    id: 'clay',
    solStart: 2300, // VERIFY: Glen Torridon entry (draft ~2300)
    name: Tr('Clay-rich layer', 'Gilga boy qatlam'),
    // VERIFY: Glen Torridon = clay-bearing unit seen from orbit.
    short: Tr(
      'Clay minerals form in water. They are a clue about wet times.',
      "Gil minerallari suvda hosil bo‘ladi. Ular nam davrlar haqida dalil.",
    ),
    more: Tr(
      'This valley is called Glen Torridon. Spacecraft in orbit saw lots of clay here, '
          'and Curiosity drilled the rocks to read their story.',
      "Bu vodiy Glen Torridon deb ataladi. Orbitadagi apparatlar bu yerda ko‘p gil ko‘rgan, "
          "Curiosity esa ularning tarixini o‘qish uchun toshlarni burg‘ulagan.",
    ),
    bandColor: Color(0xFFB0815A),
    visual: EraVisualState(
      skyTop: Color(0xFF7A6868),
      skyBottom: Color(0xFFD6AE8A),
      ground: Color(0xFF8C5A3C),
      water: 0.32,
      streams: 0.3,
      dust: 0.45,
      sun: 0.7,
      wind: 0.4,
    ),
  ),
  Era(
    id: 'sulfate',
    solStart: 3400, // VERIFY: sulfate-bearing unit entry (draft ~3400)
    name: Tr('Salty sulfate layers', 'Sulfatli tuzli qatlamlar'),
    // VERIFY: sulfate unit interpreted as drier climate; Gediz Vallis sulfur find.
    short: Tr(
      'Higher layers hold salty minerals. They show Mars drying out.',
      "Yuqori qatlamlarda tuzli minerallar bor. Ular Marsning qurib borganini ko‘rsatadi.",
    ),
    more: Tr(
      'Here Curiosity explored a channel called Gediz Vallis. '
          'NASA reported that it found rocks made of pure sulfur there.',
      "Bu yerda Curiosity Gediz Vallis nomli o‘zanni o‘rgangan. "
          "NASA u yerda sof oltingugurtdan iborat toshlar topilganini xabar qilgan.",
    ),
    bandColor: Color(0xFFD8B987),
    visual: EraVisualState(
      skyTop: Color(0xFF6B5244),
      skyBottom: Color(0xFFE2B58A),
      ground: Color(0xFFB0714A),
      water: 0.0,
      streams: 0.0,
      dust: 0.8,
      sun: 0.55,
      wind: 0.85,
    ),
  ),
];

/// Index into [eras] for a given sol.
int eraIndexForSol(int sol) {
  var idx = 0;
  for (var i = 0; i < eras.length; i++) {
    if (sol >= eras[i].solStart) idx = i;
  }
  return idx;
}

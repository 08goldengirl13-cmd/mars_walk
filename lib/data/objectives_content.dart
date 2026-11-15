import '../i18n/strings.dart';

/// One official NASA Moon to Mars objective (September 2022 edition).
/// Labels are short plain-language paraphrases; the Sources screen links to
/// the official document for the exact wording.
class Objective {
  const Objective(this.code, this.appliesTo, this.label, this.pdfPage);
  final String code;

  /// L = Moon, M = Mars, LM = both, "all" for recurring tenets.
  final String appliesTo;
  final Tr label;
  final int pdfPage;
}

/// Checked against "Moon to Mars Objectives", NASA, September 2022.
/// Only these codes may be used in the app (spec section 9.7).
const Map<String, Objective> objectives = {
  'LPS-1': Objective(
    'LPS-1',
    'LM',
    Tr(
      'How and when planets formed; the impact history of the inner solar system',
      "Sayyoralar qanday va qachon paydo bo‘lgani; ichki Quyosh tizimidagi zarbalar tarixi",
    ),
    6,
  ),
  'LPS-2': Objective(
    'LPS-2',
    'LM',
    Tr(
      'Geologic processes; how surfaces change over time (including active change)',
      "Geologik jarayonlar; sirt vaqt o‘tishi bilan qanday o‘zgaradi (hozirgi o‘zgarishlar ham)",
    ),
    6,
  ),
  'LPS-3': Objective(
    'LPS-3',
    'LM',
    Tr(
      'Where volatiles such as water came from and where they are now',
      'Suv kabi uchuvchan moddalar qayerdan kelgan va hozir qayerda',
    ),
    6,
  ),
  // The superscript is printed unclearly in the PDF (looks like LM);
  // treated as Mars-relevant.
  'LPS-4': Objective(
    'LPS-4',
    'LM',
    Tr(
      'Habitable environments and signs of past or present life',
      "Yashash uchun qulay muhitlar va o‘tmishdagi yoki hozirgi hayot belgilari",
    ),
    6,
  ),
  'HS-3': Objective(
    'HS-3',
    'LM',
    Tr(
      'Plasma processes, including dust–plasma interactions',
      "Plazma jarayonlari, jumladan chang va plazma o‘zaro ta’siri",
    ),
    6,
  ),
  'HBS-1': Objective(
    'HBS-1',
    'LM',
    Tr(
      'How short and long exposure to Moon/Mars/deep-space environments affects health',
      "Oy, Mars va chuqur koinot muhitida qisqa va uzoq qolish sog‘liqqa qanday ta’sir qiladi",
    ),
    7,
  ),
  'AS-1': Objective(
    'AS-1',
    'LM',
    Tr(
      "Monitor today's surface environment: micrometeorites, weather, space weather, space weathering, dust — for crew safety",
      "Bugungi sirt muhitini kuzatish: mikrometeoritlar, ob-havo, koinot ob-havosi, nurash, chang — ekipaj xavfsizligi uchun",
    ),
    8,
  ),
  'AS-3': Objective(
    'AS-3',
    'LM',
    Tr(
      'Find and assess resources for in-situ resource utilization (ISRU)',
      'Joyidagi resurslardan foydalanish (ISRU) uchun resurslarni topish va baholash',
    ),
    8,
  ),
  'SE-4': Objective(
    'SE-4',
    'LM',
    Tr(
      'Return representative samples from several locations',
      'Bir nechta joydan namunalarni Yerga qaytarish',
    ),
    8,
  ),
  'SE-5': Objective(
    'SE-5',
    'LM',
    Tr(
      'Use robots to survey and prepare sites before and during astronaut work',
      "Astronavtlar ishidan oldin va ish paytida joylarni robotlar bilan o‘rganish va tayyorlash",
    ),
    8,
  ),
  'SE-6': Objective(
    'SE-6',
    'LM',
    Tr(
      'Place long-term, planet-wide science instruments',
      "Uzoq muddatli, butun sayyorani qamrab oluvchi ilmiy asboblarni o‘rnatish",
    ),
    8,
  ),
  'MI-4': Objective(
    'MI-4',
    'M',
    Tr('Demonstrate Mars ISRU', 'Marsda joyidagi resurslardan foydalanishni namoyish qilish'),
    9,
  ),
  'TH-7': Objective(
    'TH-7',
    'M',
    Tr(
      'Systems to explore, operate and live on the Martian surface',
      "Mars sirtida tadqiqot qilish, ishlash va yashash tizimlari",
    ),
    10,
  ),
  'TH-8': Objective(
    'TH-8',
    'LM',
    Tr(
      'Monitor crew health and performance, also during communication delays',
      "Ekipaj sog‘lig‘i va ish qobiliyatini kuzatish, aloqa kechikkanda ham",
    ),
    10,
  ),
  'OP-2': Objective(
    'OP-2',
    'LM',
    Tr(
      'Work as a team between Earth, orbit and the surface despite communication delays',
      "Aloqa kechikishiga qaramay Yer, orbita va sirt o‘rtasida jamoa bo‘lib ishlash",
    ),
    11,
  ),
  'OP-5': Objective(
    'OP-5',
    'LM',
    Tr(
      'Operate surface mobility: EVA suits, tools, vehicles',
      "Sirtda harakatlanish: skafandrlar, asboblar, transport vositalari",
    ),
    11,
  ),
  'RT-3': Objective(
    'RT-3',
    'all',
    Tr(
      'Crew Return: bring crews safely back to Earth while limiting harm to their health',
      "Ekipajni qaytarish: sog‘lig‘iga zararni kamaytirib, Yerga xavfsiz qaytarish",
    ),
    5,
  ),
  'RT-4': Objective(
    'RT-4',
    'all',
    Tr(
      'Crew Time: make the most of crew time for science and engineering',
      "Ekipaj vaqti: vaqtdan fan va muhandislik uchun unumli foydalanish",
    ),
    5,
  ),
};

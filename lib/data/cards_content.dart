import '../i18n/strings.dart';
import '../logic/mission_model.dart';

/// A mission decision card placed on a real stop. Numbers in [scenario] are
/// placeholders filled from real NASA legs by the mission model:
/// {from} {to} {km} {hours} {oxygen} {gain}.
class MissionCard {
  const MissionCard({
    required this.stopId,
    required this.scenario,
    required this.options,
    required this.nasaDid,
    required this.takeaway,
    required this.objectiveCodes,
  });

  /// Destination stop (see stops_content.dart). The leg starts at the stop
  /// before it in the list.
  final String stopId;
  final Tr scenario;
  final List<OptionKind> options;

  /// "What NASA actually did / found here". VERIFY before submission.
  final Tr nasaDid;
  final Tr takeaway;
  final List<String> objectiveCodes;
}

const List<MissionCard> missionCards = [
  MissionCard(
    stopId: 'yellowknife',
    scenario: Tr(
      'Your crew camps at {from}. {to} is {km} km away on the real path. '
          'The walk there and back takes about {hours} h. Go, or study the rock here?',
      "Ekipajingiz {from} da turibdi. {to} haqiqiy yo‘l bo‘yicha {km} km uzoqlikda. "
          "Borib-kelish taxminan {hours} soat. Borasizmi yoki shu yerdagi toshni o‘rganasizmi?",
    ),
    options: [OptionKind.go, OptionKind.study],
    // VERIFY: drilling in early 2013; clay minerals and key chemical elements — NASA MSL news.
    nasaDid: Tr(
      'Curiosity drilled here in early 2013. It found clay minerals and chemical elements that tiny life could use.',
      "Curiosity bu yerda 2013-yil boshida burg‘ulagan. Mayda hayot foydalanishi mumkin bo‘lgan gil minerallari va kimyoviy elementlar topilgan.",
    ),
    takeaway: Tr(
      'Short walks near the base are safe and still give great science.',
      "Baza yaqinidagi qisqa yurishlar xavfsiz va baribir katta ilmiy natija beradi.",
    ),
    objectiveCodes: ['LPS-4', 'SE-4'],
  ),
  MissionCard(
    stopId: 'pahrump',
    scenario: Tr(
      '{to} is {km} km away and {gain} m higher. Walking there and back would take about {hours} h. '
          'Your suit has {oxygen} h of oxygen.',
      "{to} {km} km uzoqlikda va {gain} m balandroq. Borib-kelish taxminan {hours} soat oladi. "
          "Skafandringizda {oxygen} soat kislorod bor.",
    ),
    options: [OptionKind.go, OptionKind.half, OptionKind.study],
    // VERIFY: months of study at Pahrump Hills (2014–2015) — NASA MSL news.
    nasaDid: Tr(
      'Curiosity spent months here, studying thin layers of lake mud at the foot of the mountain.',
      "Curiosity bu yerda bir necha oy tog‘ etagidagi ko‘l loyining yupqa qatlamlarini o‘rgangan.",
    ),
    takeaway: Tr(
      'Walking in a heavy suit is slow. Long trips need a vehicle or a closer camp.',
      "Og‘ir skafandrda yurish sekin. Uzoq safarlar uchun transport yoki yaqinroq lager kerak.",
    ),
    objectiveCodes: ['RT-3', 'OP-5'],
  ),
  MissionCard(
    stopId: 'bagnold',
    scenario: Tr(
      'Dark dunes are {km} km away. The round trip takes about {hours} h on soft sand. '
          'A radio message to Earth and back takes many minutes. Ask, or decide yourself?',
      "Qora qumtepalar {km} km uzoqlikda. Yumshoq qumda borib-kelish taxminan {hours} soat. "
          "Yerga radio xabar borib-kelishi ko‘p daqiqa oladi. So‘raysizmi yoki o‘zingiz hal qilasizmi?",
    ),
    options: [OptionKind.go, OptionKind.askEarth, OptionKind.study],
    // VERIFY: Namib Dune scooping and observed grain motion — NASA/JPL news 2015–2016.
    nasaDid: Tr(
      'Curiosity scooped sand from a dune called Namib Dune and watched the grains move with the wind.',
      "Curiosity Namib qumtepasidan qum olgan va zarralar shamolda harakatlanishini kuzatgan.",
    ),
    takeaway: Tr(
      "On Mars, Earth's advice always arrives late. Crews must often decide by themselves.",
      "Marsda Yerdan maslahat doim kechikib keladi. Ekipaj ko‘pincha o‘zi qaror qilishi kerak.",
    ),
    objectiveCodes: ['OP-2', 'RT-4'],
  ),
  MissionCard(
    stopId: 'glen_torridon',
    scenario: Tr(
      '{to} is {km} km away, {gain} m higher. The round trip would take about {hours} h. '
          'You could also walk halfway and bring back a sample.',
      "{to} {km} km uzoqlikda, {gain} m balandroq. Borib-kelish taxminan {hours} soat. "
          "Yarim yo‘lgacha borib namuna olib qaytishingiz ham mumkin.",
    ),
    options: [OptionKind.go, OptionKind.half, OptionKind.study],
    // VERIFY: several drill holes in clay-rich rock; highest clay amounts of the mission.
    nasaDid: Tr(
      'Curiosity drilled several holes here and found the most clay minerals of its mission so far.',
      "Curiosity bu yerda bir nechta teshik burg‘ulagan va missiyasidagi eng ko‘p gil minerallarini topgan.",
    ),
    takeaway: Tr(
      'Halfway with a sample can be smarter than all the way with no oxygen left.',
      "Namuna bilan yarim yo‘l — kislorodsiz butun yo‘ldan aqlliroq bo‘lishi mumkin.",
    ),
    objectiveCodes: ['AS-3', 'RT-3'],
  ),
  MissionCard(
    stopId: 'latest',
    scenario: Tr(
      "Curiosity's latest position is {km} km further and {gain} m higher. "
          'Walking there and back would take about {hours} h — and every hour outside adds radiation.',
      "Curiosity’ning oxirgi joyi yana {km} km uzoqda va {gain} m balandroq. "
          "Borib-kelish taxminan {hours} soat — tashqaridagi har soat radiatsiya qo‘shadi.",
    ),
    options: [OptionKind.go, OptionKind.half, OptionKind.askEarth],
    // VERIFY: Curiosity still active, climbing through sulfate-bearing layers.
    nasaDid: Tr(
      'Curiosity is still driving. It climbs through salty sulfate layers that show Mars drying out.',
      "Curiosity hali ham harakatda. U Marsning qurib borganini ko‘rsatuvchi sulfatli qatlamlar bo‘ylab ko‘tarilmoqda.",
    ),
    takeaway: Tr(
      'A robot needed years for this distance. Humans will need rovers and many missions.',
      "Robotga bu masofa uchun yillar kerak bo‘ldi. Odamlarga roverlar va ko‘p missiyalar kerak bo‘ladi.",
    ),
    objectiveCodes: ['HBS-1', 'TH-8'],
  ),
];

import 'package:flutter/widgets.dart';

enum Lang { en, uz }

/// A text in both languages (used by the content files).
class Tr {
  const Tr(this.en, this.uz);
  final String en;
  final String uz;

  String of(Lang lang) => lang == Lang.uz && uz.isNotEmpty ? uz : en;
}

/// Holds the selected language. The whole app rebuilds when it changes.
class LanguageController extends ChangeNotifier {
  LanguageController([this._lang = Lang.en]);
  Lang _lang;

  Lang get lang => _lang;

  set lang(Lang value) {
    if (value == _lang) return;
    _lang = value;
    notifyListeners();
  }

  void toggle() => lang = _lang == Lang.en ? Lang.uz : Lang.en;
}

/// Simple string lookup. Missing UZ keys fall back to EN; a missing EN key
/// returns the key itself (and asserts in debug mode).
class S {
  const S(this.lang);
  final Lang lang;

  String t(String key, [Map<String, Object> params = const {}]) {
    var s = (lang == Lang.uz ? _uz[key] : null) ?? _en[key];
    assert(s != null, 'Missing string key: $key');
    s ??= key;
    params.forEach((k, v) => s = s!.replaceAll('{$k}', '$v'));
    return s!;
  }

  String tr(Tr text) => text.of(lang);

  static bool hasKey(String key) => _en.containsKey(key);
  static Iterable<String> get enKeys => _en.keys;
  static Iterable<String> get uzKeys => _uz.keys;
}

const Map<String, String> _en = {
  'appTitle': 'Mars Walk',
  'appSubtitle': 'Walk {km} km on Mars in 30 seconds',
  'loading': 'Loading NASA route data…',
  'btnMission': 'Mission',
  'btnLayers': 'Map layers',
  'btnSources': 'Sources & data',
  'btnHelp': 'How to use',
  'btnLanguage': 'Change language',

  // Time dock
  'play': 'Play',
  'pause': 'Pause',
  'restart': 'Restart',
  'speed': 'Speed',
  'chipSol': 'Sol {sol}',
  'chipKm': '{km} km',
  'chipElev': '{elev} m',
  'chipTilt': 'Tilt {tilt}°',
  'sliderLabel': 'Mars day (sol)',
  'funFact': 'You walked {km} km in {sols} sols and climbed {climb} m. That is about {marathons} marathons!',
  'profileLabel': 'Elevation along the route',

  // Map
  'recentre': 'Re-centre',
  'attribution': 'Imagery: NASA/JPL-Caltech · Mars Trek. Route: NASA/JPL MSL.',
  'demoBanner': 'Demo data — run the data script (tool/prepare_data.dart).',
  'tilesOffline': 'Map pictures could not load. Check your internet. The route still works.',
  'stopTapHint': 'Tap a numbered circle to jump there.',

  // Strata + era scene
  'strataTitle': 'ROCK LAYERS',
  'sceneTitle': 'MARS AT THAT TIME',
  'artistNote': "Artist's concept based on published NASA interpretations.",
  'wet': 'Wet',
  'dry': 'Dry',
  'youAreHere': 'You',
  'currentLayer': 'NOW CLIMBING',
  'more': 'More',
  'less': 'Less',

  // Mars today
  'todayTitle': 'MARS TODAY AT GALE',
  'todayTemp': 'Air temperature',
  'todayPressure': 'Air pressure',
  'todayRadiation': 'Radiation',
  'todayGravity': 'Gravity',
  'todayTempValue': 'about −90 °C to 0 °C',
  'todayPressureValue': 'about 0.7–0.9 kPa (< 1 % of Earth)',
  'todayRadiationValue': 'about 0.6 mSv per day',
  'todayGravityValue': '0.38 g',
  'todayNote': "Approximate values from Curiosity's REMS and RAD instruments — see Sources.",

  // Intro
  'intro1Title': 'You are the first human on Mars.',
  'intro1Body': 'Welcome to Gale Crater. Mount Sharp is in front of you.',
  'intro2Title': 'A robot walked here first.',
  'intro2Body': "NASA's Curiosity rover has explored this ground for 14 years. Every step here uses its real data.",
  'intro3Title': 'Press Play.',
  'intro3Body': 'Drag the Sol slider, climb the rock layers, then try a Mission.',
  'next': 'Next',
  'start': 'Start',
  'skip': 'Skip',

  // Layers sheet
  'layersTitle': 'Map layers',
  'baseMap': 'Base map',
  'baseViking': 'Viking colour',
  'baseMola': 'MOLA relief',
  'overlays': 'Sharp close-ups',
  'overlayHirise': 'HiRISE (sharpest)',
  'overlayCtx': 'CTX (Gale Crater)',
  'opacity': 'Close-up opacity',
  'calmMode': 'Calm mode',
  'calmModeHint': 'Less motion: no camera easing, still scenes.',

  // Sources
  'sourcesTitle': 'Sources & data',
  'sourcesIntro': 'Everything on the map comes from these NASA datasets.',
  'usedFor': 'Used for',
  'openLink': 'Open link',
  'approxTag': 'Approximation',
  'honesty': 'Era scenes and mission numbers are educational approximations.',
  'objectivesNote': "Objective codes are from NASA's September 2022 edition; NASA may update them — check the official page.",
  'routeInfo': 'Route data: {source}, downloaded {date}, {n} waypoints.',
  'objectivesTitle': 'NASA Moon to Mars objectives used in the app',
  'linkFailed': 'Could not open the link.',

  // Mission
  'missionTitle': 'MISSION',
  'missionGoal': 'Reach as many science stops as you can and get back safely.',
  'missionRules':
      'Each walk starts with a full suit: {oxygen} h of oxygen. Keep a {reserve} % safety reserve.',
  'missionStart': 'Start mission',
  'missionExit': 'Exit mission',
  'cardOf': 'Stop {n} of {total}',
  'legFacts':
      'Real path: {km} km, {gain} m up, average tilt {tilt}°. Curiosity needed {sols} sols for it.',
  'legFactsDown':
      'Real path: {km} km, {gain} m down, average tilt {tilt}°. Curiosity needed {sols} sols for it.',
  'optGo': 'Walk to {stop}',
  'optHalf': 'Walk halfway and take a sample',
  'optStudy': 'Stay and study the rock here',
  'optAskEarth': 'Ask Earth first',
  'resOxygen': 'Oxygen left',
  'resEnergy': 'Crew energy',
  'resRadiation': 'Radiation dose',
  'resWalk': 'Walk there and back: {hours} h',
  'resRadValue': '+{dose} mSv (total {total} mSv)',
  'verdictSafe': 'Safe',
  'verdictRisky': 'Risky',
  'verdictTooFar': 'Too far',
  'verdictSafeText': 'You keep your safety reserve. Well planned!',
  'verdictRiskyText': 'You make it, but you used your safety reserve.',
  'verdictTooFarText': 'Your oxygen would run out. Mission control orders you to turn back.',
  'askEarthText':
      'Earth answers after the radio delay. Their advice: "{choice}". You lose a little crew time.',
  'whatNasaDid': 'WHAT NASA ACTUALLY DID HERE',
  'takeaway': 'LESSON',
  'points': '{points} points',
  'nextCard': 'Next stop',
  'finish': 'See my result',
  'endTitle': 'Mission complete!',
  'score': 'Score',
  'stopsReached': 'Science stops reached: {n} of {total}',
  'achievements': 'Achievements',
  'achSafe': 'Safe walker — never too far',
  'achExplorer': 'Explorer — 3 or more stops',
  'achSaver': 'Oxygen saver — over 2 h left on average',
  'achTeam': 'Team player — asked Earth',
  'achNone': 'No badges this time. Try again!',
  'copyResult': 'Copy my result',
  'copied': 'Copied!',
  'playAgain': 'Play again',
  'backToMap': 'Back to the map',
  'shareText': 'I played Mars Walk (NASA Space Apps): {score} points, {stops}/{total} science stops on Curiosity\'s real path in Gale Crater, Mars.',
  'summaryGreat': 'Great planning. NASA would hire you!',
  'summaryOk': 'Good job. Next time keep more oxygen.',
  'summaryLow': 'Mars is hard. Plan shorter walks and try again.',
  'objectivesChipTitle': 'NASA objective',
  'modelNote': 'Walking model: our educational assumptions — see Sources.',
};

const Map<String, String> _uz = {
  'appTitle': 'Mars Walk',
  'appSubtitle': "Marsda {km} km yo‘lni 30 soniyada bosib o‘ting",
  'loading': "NASA yo‘l ma’lumotlari yuklanmoqda…",
  'btnMission': 'Missiya',
  'btnLayers': 'Xarita qatlamlari',
  'btnSources': 'Manbalar',
  'btnHelp': 'Qanday ishlatiladi',
  'btnLanguage': 'Tilni almashtirish',

  'play': 'Boshlash',
  'pause': 'To‘xtatish',
  'restart': 'Qaytadan',
  'speed': 'Tezlik',
  'chipSol': 'Sol {sol}',
  'chipKm': '{km} km',
  'chipElev': '{elev} m',
  'chipTilt': 'Qiyalik {tilt}°',
  'sliderLabel': 'Mars kuni (sol)',
  'funFact': "Siz {sols} solda {km} km yurdingiz va {climb} m ko‘tarildingiz. Bu taxminan {marathons} ta marafon!",
  'profileLabel': 'Yo‘l bo‘yicha balandlik',

  'recentre': 'Markazga',
  'attribution': 'Tasvirlar: NASA/JPL-Caltech · Mars Trek. Yo‘l: NASA/JPL MSL.',
  'demoBanner': "Demo ma’lumot — tool/prepare_data.dart skriptini ishga tushiring.",
  'tilesOffline': "Xarita rasmlari yuklanmadi. Internetni tekshiring. Yo‘l baribir ishlaydi.",
  'stopTapHint': "U yerga o‘tish uchun raqamli doirani bosing.",

  'strataTitle': 'TOSH QATLAMLARI',
  'sceneTitle': 'O‘SHA DAVRDAGI MARS',
  'artistNote': "Rassom tasavvuri: NASA e’lon qilgan talqinlar asosida.",
  'wet': 'Nam',
  'dry': 'Quruq',
  'youAreHere': 'Siz',
  'currentLayer': 'HOZIRGI QATLAM',
  'more': 'Batafsil',
  'less': 'Qisqaroq',

  'todayTitle': 'BUGUNGI MARS (GALE)',
  'todayTemp': 'Havo harorati',
  'todayPressure': 'Havo bosimi',
  'todayRadiation': 'Radiatsiya',
  'todayGravity': 'Tortishish',
  'todayTempValue': 'taxminan −90 °C dan 0 °C gacha',
  'todayPressureValue': 'taxminan 0,7–0,9 kPa (Yerdagining 1 % idan kam)',
  'todayRadiationValue': 'kuniga taxminan 0,6 mSv',
  'todayGravityValue': '0,38 g',
  'todayNote': "Curiosity’ning REMS va RAD asboblaridan taxminiy qiymatlar — Manbalarga qarang.",

  'intro1Title': 'Siz Marsdagi birinchi insonsiz.',
  'intro1Body': "Gale krateriga xush kelibsiz. Oldingizda Sharp tog‘i.",
  'intro2Title': 'Bu yerda avval robot yurgan.',
  'intro2Body': "NASA’ning Curiosity roveri bu yerni 14 yildan beri o‘rganmoqda. Har bir qadam uning haqiqiy ma’lumotlariga asoslangan.",
  'intro3Title': 'Boshlash tugmasini bosing.',
  'intro3Body':
      "Sol slayderini suring, qatlamlar bo‘ylab ko‘tariling, keyin Missiyani sinab ko‘ring.",
  'next': 'Keyingi',
  'start': 'Boshlash',
  'skip': 'O‘tkazib yuborish',

  'layersTitle': 'Xarita qatlamlari',
  'baseMap': 'Asosiy xarita',
  'baseViking': 'Viking rangli',
  'baseMola': 'MOLA relyef',
  'overlays': 'Aniq suratlar',
  'overlayHirise': 'HiRISE (eng aniq)',
  'overlayCtx': 'CTX (Gale krateri)',
  'opacity': 'Suratlar shaffofligi',
  'calmMode': 'Sokin rejim',
  'calmModeHint': 'Kamroq harakat: kamera silliq ergashmaydi, sahna qotadi.',

  'sourcesTitle': 'Manbalar va ma’lumotlar',
  'sourcesIntro': "Xaritadagi hamma narsa shu NASA ma’lumotlaridan olingan.",
  'usedFor': 'Nima uchun',
  'openLink': 'Havolani ochish',
  'approxTag': 'Taxminiy',
  'honesty': 'Davr sahnalari va missiya raqamlari o‘quv maqsadidagi taxminlardir.',
  'objectivesNote': "Maqsad kodlari NASA’ning 2022-yil sentabr nashridan. NASA ularni yangilashi mumkin — rasmiy sahifani tekshiring.",
  'routeInfo': "Yo‘l ma’lumoti: {source}, yuklangan sana {date}, {n} ta nuqta.",
  'objectivesTitle': 'Ilovada ishlatilgan NASA Oydan Marsga maqsadlari',
  'linkFailed': 'Havolani ochib bo‘lmadi.',

  'missionTitle': 'MISSIYA',
  'missionGoal': "Imkon qadar ko‘p ilmiy bekatlarga yeting va xavfsiz qayting.",
  'missionRules': "Har bir yurish to‘la skafandr bilan boshlanadi: {oxygen} soat kislorod. {reserve} % zaxirani saqlang.",
  'missionStart': 'Missiyani boshlash',
  'missionExit': 'Missiyadan chiqish',
  'cardOf': 'Bekat {n} / {total}',
  'legFacts': "Haqiqiy yo‘l: {km} km, {gain} m yuqoriga, o‘rtacha qiyalik {tilt}°. Curiosity bunga {sols} sol sarflagan.",
  'legFactsDown': "Haqiqiy yo‘l: {km} km, {gain} m pastga, o‘rtacha qiyalik {tilt}°. Curiosity bunga {sols} sol sarflagan.",
  'optGo': '{stop} gacha yurish',
  'optHalf': 'Yarim yo‘lgacha borib namuna olish',
  'optStudy': "Shu yerda qolib toshni o‘rganish",
  'optAskEarth': 'Avval Yerdan so‘rash',
  'resOxygen': 'Qolgan kislorod',
  'resEnergy': 'Ekipaj kuchi',
  'resRadiation': 'Radiatsiya dozasi',
  'resWalk': 'Borish va qaytish: {hours} soat',
  'resRadValue': '+{dose} mSv (jami {total} mSv)',
  'verdictSafe': 'Xavfsiz',
  'verdictRisky': 'Xavfli',
  'verdictTooFar': 'Juda uzoq',
  'verdictSafeText': 'Zaxirangiz saqlandi. Yaxshi rejalashtirdingiz!',
  'verdictRiskyText': 'Yetib bordingiz, lekin zaxirani ishlatdingiz.',
  'verdictTooFarText': 'Kislorod yetmasdi. Boshqaruv markazi ortga qaytishni buyuradi.',
  'askEarthText': "Yer radio kechikishidan keyin javob beradi. Maslahat: \"{choice}\". Biroz vaqt yo‘qotdingiz.",
  'whatNasaDid': 'NASA BU YERDA AMALDA NIMA QILGAN',
  'takeaway': 'SABOQ',
  'points': '{points} ball',
  'nextCard': 'Keyingi bekat',
  'finish': 'Natijamni ko‘rish',
  'endTitle': 'Missiya tugadi!',
  'score': 'Ball',
  'stopsReached': 'Yetilgan ilmiy bekatlar: {n} / {total}',
  'achievements': 'Yutuqlar',
  'achSafe': 'Ehtiyotkor — hech qachon juda uzoqqa bormadi',
  'achExplorer': 'Tadqiqotchi — 3 va undan ko‘p bekat',
  'achSaver': 'Tejamkor — o‘rtacha 2 soatdan ko‘p kislorod qoldi',
  'achTeam': 'Jamoaviy — Yerdan so‘radi',
  'achNone': 'Bu safar nishon yo‘q. Yana urinib ko‘ring!',
  'copyResult': 'Natijamni nusxalash',
  'copied': 'Nusxalandi!',
  'playAgain': 'Yana o‘ynash',
  'backToMap': 'Xaritaga qaytish',
  'shareText': "Men Mars Walk o‘ynadim (NASA Space Apps): {score} ball, Marsdagi Gale kraterida Curiosity’ning haqiqiy yo‘lida {stops}/{total} ilmiy bekat.",
  'summaryGreat': 'Ajoyib reja. NASA sizni ishga olardi!',
  'summaryOk': 'Yaxshi. Keyingi safar ko‘proq kislorod qoldiring.',
  'summaryLow': 'Mars qiyin. Qisqaroq yurishlarni rejalang va qayta urining.',
  'objectivesChipTitle': 'NASA maqsadi',
  'modelNote': 'Yurish modeli: bizning o‘quv taxminlarimiz — Manbalarga qarang.',
};

/// Gives widgets access to the current [S] via `context.s`.
class LangScope extends InheritedNotifier<LanguageController> {
  const LangScope({super.key, required LanguageController controller, required super.child})
    : super(notifier: controller);

  static LanguageController controllerOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LangScope>()!.notifier!;
}

extension LangContext on BuildContext {
  S get s => S(LangScope.controllerOf(this).lang);
  Lang get lang => LangScope.controllerOf(this).lang;
}

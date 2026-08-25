// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get appTitle => 'Mapato';

  @override
  String get navHome => 'Nyumbani';

  @override
  String get navTxns => 'Miamala';

  @override
  String get navAdd => 'Ongeza';

  @override
  String get navSettings => 'Mipangilio';

  @override
  String get greetingMorning => 'Habari za asubuhi';

  @override
  String get greetingAfternoon => 'Habari za mchana';

  @override
  String get greetingEvening => 'Habari za jioni';

  @override
  String get moneyOverview => 'Hii ni muhtasari wa pesa zako';

  @override
  String get allTime => 'Nyakati zote';

  @override
  String get today => 'Leo';

  @override
  String get last7Days => 'Siku 7 zilizopita';

  @override
  String get thisMonth => 'Mwezi huu';

  @override
  String get lastMonth => 'Mwezi uliopita';

  @override
  String get custom => 'Desturi';

  @override
  String get all => 'Wote';

  @override
  String get week => 'Wiki';

  @override
  String get month => 'Mwezi';

  @override
  String get lastMo => 'Mwezi uliopita';

  @override
  String get thisWeek => 'Wiki hii';

  @override
  String get income => 'Mapato';

  @override
  String get expenses => 'Matumizi';

  @override
  String get saved => 'Imehifadhiwa';

  @override
  String get whereMoneyWent => 'Pesa yako ilikwenda wapi';

  @override
  String get recentActivity => 'Shughuli za hivi karibuni';

  @override
  String get totalSpent => 'Jumla ya matumizi';

  @override
  String netFlow(String month) {
    return 'Mtiririko wa $month';
  }

  @override
  String get savingThisMonth => 'Unahifadhi mwezi huu';

  @override
  String get spendingExceeded => 'Matumizi yamezidi mapato';

  @override
  String get askMapatoAi => 'Uliza Mapato AI';

  @override
  String get switchToLight => 'Badilisha hadi mwanga';

  @override
  String get switchToDark => 'Badilisha hadi giza';

  @override
  String get noTransactionsYet => 'Bado hakuna miamala';

  @override
  String get notifOnMessage =>
      'Upatikanaji wa arifa uko washwa -- miamala yako ya M-Pesa, Mixx, Airtel, HaloPesa na AzamPesa itaonekana hapa otomatiki endapo itafika.';

  @override
  String get notifOffMessage =>
      'Washesha upatikanaji wa arifa kwenye Mipangilio na miamala yako ya M-Pesa, Mixx, Airtel, HaloPesa na AzamPesa itaonekana hapa otomatiki.';

  @override
  String get openSettings => 'Fungua Mipangilio';

  @override
  String get tagline => 'Pesa yako, kila mtandao, kwa mtazamo mmoja.';

  @override
  String get language => 'Lugha';

  @override
  String get transactions => 'Miamala';

  @override
  String get onboardingWelcomeTitle => 'Karibu Mapato';

  @override
  String get onboardingWelcomeBody =>
      'Mfuatiliaji wa fedha binafsi uliobuniwa kwa kila mkoba wa pesa mtandaoni wa Mtanzania.';

  @override
  String get onboardingCapturesTitle => 'Inakamata kila mkoba';

  @override
  String get onboardingCapturesBody =>
      'Inasoma kiotomatiki miamala yako ya M-Pesa, Mixx by Yas, Airtel Money, HaloPesa na AzamPesa -- kupitia arifa na SMS.';

  @override
  String get onboardingPrivateTitle => 'Faragwa kwa muundo';

  @override
  String get onboardingPrivateBody =>
      'Kila kitu kinachakatwa na kuhifadhiwa kwenye kifaa chako. Data yako ya fedha haiondoki kwenye simu yako.';

  @override
  String get onboardingInsightsTitle => 'Maarifa bora';

  @override
  String get onboardingInsightsBody =>
      'Angalia mapato, matumizi, na mahali ambapo pesa yako inakwenda -- kwa jamii na kwa mtandao.';

  @override
  String get skip => 'Ruka';

  @override
  String get next => 'Endelea';

  @override
  String get getStarted => 'Anza';

  @override
  String get enableNotificationAccess => 'Washesha upatikanaji wa arifa';

  @override
  String get onboardingLanguageTitle => 'Chagua lugha yako';

  @override
  String get onboardingLanguageSubtitle => 'Choose your language';

  @override
  String get english => 'English';

  @override
  String get swahili => 'Kiswahili';

  @override
  String get pinEnterYourPin => 'Weka PIN yako';

  @override
  String get pinCreate4Digit => 'Unda PIN ya nambari 4';

  @override
  String get pinEnterCurrent => 'Weka PIN ya sasa';

  @override
  String get pinIncorrectCurrent => 'PIN ya sasa si sahihi';

  @override
  String get pinEnterNew => 'Weka PIN mpya';

  @override
  String get pinConfirmNew => 'Thibitisha PIN mpya';

  @override
  String get pinMismatch => 'PIN hazifanani. Jaribu tena.';

  @override
  String get pinConfirmYour => 'Thibitisha PIN yako';

  @override
  String get pinIncorrect => 'PIN si sahihi';

  @override
  String get changePin => 'Badilisha PIN';

  @override
  String get secureTracker => 'Linda mfuatiliaji wako wa pesa';

  @override
  String get setNewPin => 'Weka PIN mpya';

  @override
  String get verifyCurrentPin => 'Thibitisha PIN yako ya sasa';

  @override
  String get cancel => 'Ghairi';

  @override
  String get delete => 'Futa';

  @override
  String get save => 'Hifadhi';

  @override
  String get ok => 'Sawa';

  @override
  String get edit => 'Hariri';

  @override
  String deleteCountQuestion(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# miamala',
      one: '# muamala',
    );
    return 'Futa $_temp0?';
  }

  @override
  String get actionCannotUndone => 'Kitendo hiki hakiwezi kutendwa tena.';

  @override
  String get searchTransactions => 'Tafuta miamala...';

  @override
  String selectedCount(int count) {
    return '$count imechaguliwa';
  }

  @override
  String get selectAll => 'Chagua zote';

  @override
  String get deleteSelected => 'Futa zilizochaguliwa';

  @override
  String get select => 'Chagua';

  @override
  String get yesterday => 'Jana';

  @override
  String get noMatches => 'Hakuna matokeo.';

  @override
  String get more => 'Zaidi';

  @override
  String get noTransactionsFound =>
      'Hakuna miamala iliyopatikana. Washesha uchukuzi kwenye Mipangilio, ongeza moja kwa mkono, au badilisha kichujio cha tarehe.';

  @override
  String get enterValidAmount => 'Weka kiasi sahihi';

  @override
  String get editTransaction => 'Hariri muamala';

  @override
  String get spent => 'Imetumika';

  @override
  String get received => 'Imepokelewa';

  @override
  String get amountTsh => 'Kiasi (Tsh)';

  @override
  String get networkLabel => 'Mtandao';

  @override
  String get categoryLabel => 'Jamii';

  @override
  String get counterpartyOptional => 'Mshirika (si lazima)';

  @override
  String get noteOptional => 'Kumbuka (si lazima)';

  @override
  String get saveChanges => 'Hifadhi mabadiliko';

  @override
  String get deleteTransaction => 'Futa muamala?';

  @override
  String get transaction => 'Muamala';

  @override
  String get from => 'Kutoka';

  @override
  String get to => 'Kwenda';

  @override
  String get account => 'Akaunti';

  @override
  String get date => 'Tarehe';

  @override
  String get source => 'Chanzo';

  @override
  String get notifSource => 'Arifa';

  @override
  String get manualSource => 'Mkono';

  @override
  String get balance => 'Salio';

  @override
  String get noteDetail => 'Kumbuka';

  @override
  String get originalMessage => 'Ujumbe asilia';

  @override
  String addedDirection(String direction, String amount) {
    return 'Imeongezwa $direction $amount';
  }

  @override
  String get addTransaction => 'Ongeza muamala';

  @override
  String get saveTransaction => 'Hifadhi muamala';

  @override
  String get dataCapture => 'Uchukuzi wa Data';

  @override
  String get notificationAccess => 'Upatikanaji wa arifa';

  @override
  String get active => 'Hai';

  @override
  String get requiredToAutoCapture => 'Inahitajika ili kukamata kiotomatiki';

  @override
  String get enableBtn => 'Washa';

  @override
  String get smsCapture => 'Uchukuzi wa SMS';

  @override
  String get fallbackNoNotification => 'Mfumo wa kufanya hakuna arifa';

  @override
  String get captureSources => 'Vyanzo vya uchukuzi';

  @override
  String get allApps => 'Programu zote';

  @override
  String captureSourcesSelected(int count, int total) {
    return '$count/$total zimechaguliwa';
  }

  @override
  String get captureFromAllApps => 'Kukamata kutoka programu zote';

  @override
  String get security => 'Usalama';

  @override
  String get appLockPin => 'Kufunga programu (PIN)';

  @override
  String get requirePinToOpen => 'Hitaji PIN kufungua';

  @override
  String get appearance => 'Mwonekano';

  @override
  String get themeTitle => 'Mandhari';

  @override
  String get dark => 'Giza';

  @override
  String get light => 'Nuru';

  @override
  String get systemDefault => 'Mfumo chaguo-msingi';

  @override
  String get dataSection => 'Data';

  @override
  String get transactionsCaptured => 'Miamala iliyokamata';

  @override
  String get categoriesTitle => 'Jamii';

  @override
  String get parserLab => 'Maabara ya Paresa';

  @override
  String get backupRestore => 'Uhifadhi na Urejesho';

  @override
  String get exportBtn => 'Hamisha';

  @override
  String get importBtn => 'Ingiza';

  @override
  String importedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# miamala',
      one: '# muamala',
    );
    return 'Imeingizwa $_temp0.';
  }

  @override
  String get noValidTransactions => 'Hakuna miamala sahihi iliyopatikana.';

  @override
  String get about => 'Kuhusu';

  @override
  String get personalMoneyTracker => 'Mfuatiliaji wa pesa binafsi - v1.0.0';

  @override
  String get developer => 'Msanidi';

  @override
  String get phone => 'Simu';

  @override
  String get aboutDescription =>
      'Inasaidia M-Pesa, Mixx by Yas, Airtel Money, HaloPesa na AzamPesa. Data yako inabaki kwenye kifaa chako.';

  @override
  String failedToOpenSettings(String error) {
    return 'Imeshindikana kufungua mipangilio: $error';
  }

  @override
  String smsPermissionFailed(String error) {
    return 'Ruhusa ya SMS imeshindikana: $error';
  }

  @override
  String get smsPermissionBlocked => 'Ruhusa ya SMS Imezuiwa';

  @override
  String get smsPermissionBlockedMessage =>
      'Google Play Protect inazuia ruhusa ya SMS kwa Mapato. Ili kuwezesha uchukuzi wa SMS: Fungua Google Play Store, gusa ikoni ya wasifu yako kisha Play Protect, gusa ikoni ya vifaa vya mipangilio, ZIMA Improve harmful app protection. Hii ni salama -- Mapato inasoma SMS za pesa mtandaoni tu. Vinginevyo, tumia Upatilianaji wa arifa tu (inapendekezwa).';

  @override
  String get chatHistory => 'Historia ya mazungumzo';

  @override
  String get newChat => 'Mazungumzo mapya';

  @override
  String get history => 'Historia';

  @override
  String get mapatoAi => 'Mapato AI';

  @override
  String get askAboutMoney =>
      'Uliza kuhusu matumizi yako, uhifadhi, au jinsi pesa mtandaoni inavyofanya kazi nchini Tanzania.';

  @override
  String get aiUnavailable => 'Mapato AI haipatikani sasa hivi.';

  @override
  String get couldNotReachAi =>
      'Haiwezi kufikia Mapato AI. Angalia muunganisho wako na jaribu tena.';

  @override
  String get askHint => 'Uliza kuhusu pesa zako...';

  @override
  String get categoriesInstruction =>
      'Gusa jamii ili kuhariri jina, rangi na ikoni yake. Jamii maalum zinaonekana unapoongeza au kuhariri miamala.';

  @override
  String get newCategory => 'Jamii mpya';

  @override
  String get enterCategoryName => 'Weka jina la jamii';

  @override
  String get editCategory => 'Hariri jamii';

  @override
  String get name => 'Jina';

  @override
  String get color => 'Rangi';

  @override
  String get icon => 'Ikoni';

  @override
  String get deleteCategory => 'Futa jamii';

  @override
  String get parserLabInstruction =>
      'Bandika ujumbe wa SMS/pesa halisi hapo chini kuona jinsi Mapato itakavyouparsa. Tumia hii kusasisha lib/parser.dart kwa kila mtandao. Yoyote ambayo haitafanikiwa inamaanisha regex inahitaji kazi.';

  @override
  String get recentCaptured => 'Vilivyokamata hivi karibuni (gusa kulia)';

  @override
  String get noCapturesYet =>
      'Bado hakuna vilivyokamata. Wezesha upatikanaji wa arifa/SMS na fanya uhamisho halisi ili kujaza orodha hii.';

  @override
  String get sampleMessage => 'Ujumbe wa mfano';

  @override
  String get noMatch =>
      'Hakuna mechi -- parser imerudisha null. Sasisha regex.';

  @override
  String get directionLabel => 'Mwelekeo';

  @override
  String get counterparty => 'Mshirika';

  @override
  String get allowNotificationsTitle => 'Ruhusu Mapato kukutumia arifa?';

  @override
  String get allowNotificationsBody =>
      'Mapato inahitaji upatikanaji wa arifa ili kukamata kiotomatiki miamala yako ya M-Pesa, Mixx, Airtel, HaloPesa na AzamPesa inapotokea.';

  @override
  String get allowSmsTitle => 'Ruhusu Mapato kusoma SMS zako?';

  @override
  String get allowSmsBody =>
      'Mapato inasoma SMS za M-Pesa, Mixx, Airtel, HaloPesa na AzamPesa ili kurekodi miamala kiotomatiki. Ujumbe wako unabaki kwenye kifaa chako.';

  @override
  String get allow => 'Ruhusu';

  @override
  String get notNow => 'Sio sasa';

  @override
  String get permissionsTitle => 'Weka uchukuzi';

  @override
  String get permissionsSubtitle =>
      'Ruhusu Mapato kusoma arifa na SMS za pesa mtandaoni ili irekodi miamala kiotomatiki.';

  @override
  String get notificationAccessLabel => 'Upatikanaji wa arifa';

  @override
  String get notificationAccessDesc =>
      'Kukamata arifa za M-Pesa, Mixx, Airtel, HaloPesa na AzamPesa';

  @override
  String get smsAccessLabel => 'Upatikanaji wa SMS';

  @override
  String get smsAccessDesc =>
      'Soma SMS za pesa mtandaoni kama mbadala endapo arifa zimezimwa';

  @override
  String get enableAccess => 'Washa';

  @override
  String get granted => 'Imetolewa';

  @override
  String get setupComplete => 'Maliza';

  @override
  String get aiSection => 'Mapato AI';

  @override
  String get groqApiKey => 'Ufunguo wa Groq API';

  @override
  String get groqApiKeyDesc =>
      'Pata ufunguo bila malipo katika console.groq.com';

  @override
  String get enterApiKey => 'Weka ufunguo wako wa API';

  @override
  String get aiModel => 'Mfumo wa AI';

  @override
  String get aiModelDesc => 'Chagua mfumo wa kutumia';
}

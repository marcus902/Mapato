// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mapato';

  @override
  String get navHome => 'Home';

  @override
  String get navTxns => 'Txns';

  @override
  String get navAdd => 'Add';

  @override
  String get navSettings => 'Settings';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get moneyOverview => 'Here is your money overview';

  @override
  String get allTime => 'All time';

  @override
  String get today => 'Today';

  @override
  String get last7Days => 'Last 7 days';

  @override
  String get thisMonth => 'This month';

  @override
  String get lastMonth => 'Last month';

  @override
  String get custom => 'Custom';

  @override
  String get all => 'All';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get lastMo => 'Last mo';

  @override
  String get thisWeek => 'This week';

  @override
  String get income => 'Income';

  @override
  String get expenses => 'Expenses';

  @override
  String get saved => 'Saved';

  @override
  String get whereMoneyWent => 'Where your money went';

  @override
  String get recentActivity => 'Recent activity';

  @override
  String get totalSpent => 'Total spent';

  @override
  String netFlow(String month) {
    return '$month net flow';
  }

  @override
  String get savingThisMonth => 'You are saving this month';

  @override
  String get spendingExceeded => 'Spending exceeded income';

  @override
  String get askMapatoAi => 'Ask Mapato AI';

  @override
  String get switchToLight => 'Switch to light';

  @override
  String get switchToDark => 'Switch to dark';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get notifOnMessage =>
      'Notification access is on -- your M-Pesa, Mixx, Airtel, HaloPesa, AzamPesa and bank transactions will appear here automatically as they arrive.';

  @override
  String get notifOffMessage =>
      'Enable notification access in Settings and your M-Pesa, Mixx, Airtel, HaloPesa, AzamPesa and bank transactions will appear here automatically.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get tagline => 'Your money, every network, one view.';

  @override
  String get language => 'Language';

  @override
  String get transactions => 'Transactions';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Mapato';

  @override
  String get onboardingWelcomeBody =>
      'The personal finance tracker built for every Tanzanian mobile-money wallet.';

  @override
  String get onboardingCapturesTitle => 'Captures every wallet';

  @override
  String get onboardingCapturesBody =>
      'Automatically reads your M-Pesa, Mixx by Yas, Airtel Money, HaloPesa and AzamPesa transactions -- via notifications and SMS.';

  @override
  String get onboardingPrivateTitle => 'Private by design';

  @override
  String get onboardingPrivateBody =>
      'Everything is processed and stored on your device. Your financial data never leaves your phone.';

  @override
  String get onboardingInsightsTitle => 'Beautiful insights';

  @override
  String get onboardingInsightsBody =>
      'See income, expenses, and exactly where your money goes -- by category and by network.';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get started';

  @override
  String get enableNotificationAccess => 'Enable notification access';

  @override
  String get onboardingLanguageTitle => 'Choose your language';

  @override
  String get onboardingLanguageSubtitle =>
      'You can change this later in Settings';

  @override
  String get english => 'English';

  @override
  String get swahili => 'Kiswahili';

  @override
  String get pinEnterYourPin => 'Enter your PIN';

  @override
  String get pinCreate4Digit => 'Create a 4-digit PIN';

  @override
  String get pinEnterCurrent => 'Enter current PIN';

  @override
  String get pinIncorrectCurrent => 'Incorrect current PIN';

  @override
  String get pinEnterNew => 'Enter new PIN';

  @override
  String get pinConfirmNew => 'Confirm new PIN';

  @override
  String get pinMismatch => 'PINs do not match. Try again.';

  @override
  String get pinConfirmYour => 'Confirm your PIN';

  @override
  String get pinIncorrect => 'Incorrect PIN';

  @override
  String get changePin => 'Change PIN';

  @override
  String get secureTracker => 'Secure your money tracker';

  @override
  String get setNewPin => 'Set a new PIN';

  @override
  String get verifyCurrentPin => 'Verify your current PIN';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get ok => 'OK';

  @override
  String get edit => 'Edit';

  @override
  String deleteCountQuestion(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# transactions',
      one: '# transaction',
    );
    return 'Delete $_temp0?';
  }

  @override
  String get actionCannotUndone => 'This action cannot be undone.';

  @override
  String get searchTransactions => 'Search transactions...';

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String get selectAll => 'Select all';

  @override
  String get deleteSelected => 'Delete selected';

  @override
  String get select => 'Select';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get noMatches => 'No matches.';

  @override
  String get more => 'More';

  @override
  String get noTransactionsFound =>
      'No transactions found. Turn on capture in Settings, add one manually, or change the date filter.';

  @override
  String get enterValidAmount => 'Enter a valid amount';

  @override
  String get editTransaction => 'Edit transaction';

  @override
  String get spent => 'Spent';

  @override
  String get received => 'Received';

  @override
  String get amountTsh => 'Amount (Tsh)';

  @override
  String get networkLabel => 'Network';

  @override
  String get categoryLabel => 'Category';

  @override
  String get counterpartyOptional => 'Counterparty (optional)';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get deleteTransaction => 'Delete transaction?';

  @override
  String get transaction => 'Transaction';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get account => 'Account';

  @override
  String get date => 'Date';

  @override
  String get source => 'Source';

  @override
  String get notifSource => 'Notification';

  @override
  String get manualSource => 'Manual';

  @override
  String get balance => 'Balance';

  @override
  String get noteDetail => 'Note';

  @override
  String get originalMessage => 'Original message';

  @override
  String addedDirection(String direction, String amount) {
    return 'Added $direction $amount';
  }

  @override
  String get addTransaction => 'Add transaction';

  @override
  String get saveTransaction => 'Save transaction';

  @override
  String get dataCapture => 'Data Capture';

  @override
  String get notificationAccess => 'Notification access';

  @override
  String get active => 'Active';

  @override
  String get requiredToAutoCapture => 'Required to auto-capture';

  @override
  String get enableBtn => 'Enable';

  @override
  String get smsCapture => 'SMS capture';

  @override
  String get fallbackNoNotification => 'Fallback when no notification';

  @override
  String get captureSources => 'Capture sources';

  @override
  String get allApps => 'All apps';

  @override
  String captureSourcesSelected(int count, int total) {
    return '$count/$total selected';
  }

  @override
  String get captureFromAllApps => 'Capture from all apps';

  @override
  String get security => 'Security';

  @override
  String get appLockPin => 'App lock (PIN)';

  @override
  String get requirePinToOpen => 'Require PIN to open';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeTitle => 'Theme';

  @override
  String get dark => 'Dark';

  @override
  String get light => 'Light';

  @override
  String get systemDefault => 'System default';

  @override
  String get dataSection => 'Data';

  @override
  String get transactionsCaptured => 'Transactions captured';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get parserLab => 'Parser Lab';

  @override
  String get backupRestore => 'Backup and Restore';

  @override
  String get exportBtn => 'Export';

  @override
  String get importBtn => 'Import';

  @override
  String importedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# transactions',
      one: '# transaction',
    );
    return 'Imported $_temp0.';
  }

  @override
  String get noValidTransactions => 'No valid transactions found.';

  @override
  String get about => 'About';

  @override
  String get personalMoneyTracker => 'Personal money tracker - v1.0.0';

  @override
  String get developer => 'Developer';

  @override
  String get phone => 'Phone';

  @override
  String get aboutDescription =>
      'Supports M-Pesa, Mixx by Yas, Airtel Money, HaloPesa and AzamPesa. Your data stays on your device.';

  @override
  String failedToOpenSettings(String error) {
    return 'Failed to open settings: $error';
  }

  @override
  String smsPermissionFailed(String error) {
    return 'SMS permission failed: $error';
  }

  @override
  String get smsPermissionBlocked => 'SMS Permission Blocked';

  @override
  String get smsPermissionBlockedMessage =>
      'Google Play Protect is blocking SMS permission for Mapato. To enable SMS capture: Open Google Play Store, tap your profile icon then Play Protect, tap the settings gear icon, turn OFF Improve harmful app protection. This is safe -- Mapato only reads mobile-money SMS. Alternatively, use Notification access only (recommended).';

  @override
  String get chatHistory => 'Chat history';

  @override
  String get newChat => 'New chat';

  @override
  String get history => 'History';

  @override
  String get mapatoAi => 'Mapato AI';

  @override
  String get askAboutMoney =>
      'Ask about your spending, saving, or how mobile money works in Tanzania.';

  @override
  String get aiUnavailable => 'Mapato AI is unavailable right now.';

  @override
  String get couldNotReachAi =>
      'Could not reach Mapato AI. Check your connection and try again.';

  @override
  String get askHint => 'Ask about your money...';

  @override
  String get categoriesInstruction =>
      'Tap a category to edit its name, color and icon. Custom categories appear when adding or editing transactions.';

  @override
  String get newCategory => 'New category';

  @override
  String get enterCategoryName => 'Enter a category name';

  @override
  String get editCategory => 'Edit category';

  @override
  String get name => 'Name';

  @override
  String get color => 'Color';

  @override
  String get icon => 'Icon';

  @override
  String get deleteCategory => 'Delete category';

  @override
  String get parserLabInstruction =>
      'Paste a real money SMS or notification text below to see how Mapato will parse it. Use this to tune lib/parser.dart for each network. Anything that returns no match means the regex needs work.';

  @override
  String get recentCaptured => 'Recent captured (tap to load)';

  @override
  String get noCapturesYet =>
      'No captures yet. Enable notification/SMS access and do a real transfer to populate this list.';

  @override
  String get sampleMessage => 'Sample message';

  @override
  String get noMatch => 'No match -- parser returned null. Tune the regexes.';

  @override
  String get directionLabel => 'Direction';

  @override
  String get counterparty => 'Counterparty';

  @override
  String get allowNotificationsTitle =>
      'Allow Mapato to send you notifications?';

  @override
  String get allowNotificationsBody =>
      'Mapato needs notification access to automatically capture your M-Pesa, Mixx, Airtel, HaloPesa and AzamPesa transactions as they happen.';

  @override
  String get allowSmsTitle => 'Allow Mapato to read your SMS?';

  @override
  String get allowSmsBody =>
      'Mapato reads your M-Pesa, Mixx, Airtel, HaloPesa and AzamPesa SMS messages to automatically record transactions. Your messages stay on your device.';

  @override
  String get allow => 'Allow';

  @override
  String get notNow => 'Not now';

  @override
  String get permissionsTitle => 'Set up capture';

  @override
  String get permissionsSubtitle =>
      'Allow Mapato to read your mobile-money notifications and SMS so it can automatically record transactions.';

  @override
  String get notificationAccessLabel => 'Notification access';

  @override
  String get notificationAccessDesc =>
      'Capture M-Pesa, Mixx, Airtel, HaloPesa, AzamPesa and bank notifications';

  @override
  String get smsAccessLabel => 'SMS access';

  @override
  String get smsAccessDesc =>
      'Read mobile-money and bank SMS as a backup when notifications are off';

  @override
  String get enableAccess => 'Enable';

  @override
  String get granted => 'Granted';

  @override
  String get setupComplete => 'Done';

  @override
  String get notifAccessDialogTitle => 'Enable notification access';

  @override
  String get notifAccessDialogBody =>
      '1. Tap Open Settings below\n2. Find Mapato in the list\n3. Tap it and toggle ON\n4. Confirm the warning\n5. Press back to return to Mapato\n\nIf Mapato is not listed, the app may need to be opened again after install.';

  @override
  String get aiSection => 'Mapato AI';

  @override
  String get groqApiKey => 'Groq API Key';

  @override
  String get groqApiKeyDesc => 'Get a free key at console.groq.com';

  @override
  String get enterApiKey => 'Enter your API key';

  @override
  String get aiModel => 'AI Model';

  @override
  String get aiModelDesc => 'Choose which model to use';
}

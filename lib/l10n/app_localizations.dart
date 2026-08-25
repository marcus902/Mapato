import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sw'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mapato'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navTxns.
  ///
  /// In en, this message translates to:
  /// **'Txns'**
  String get navTxns;

  /// No description provided for @navAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get navAdd;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @moneyOverview.
  ///
  /// In en, this message translates to:
  /// **'Here is your money overview'**
  String get moneyOverview;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get allTime;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7Days;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get lastMonth;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @lastMo.
  ///
  /// In en, this message translates to:
  /// **'Last mo'**
  String get lastMo;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @whereMoneyWent.
  ///
  /// In en, this message translates to:
  /// **'Where your money went'**
  String get whereMoneyWent;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get recentActivity;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total spent'**
  String get totalSpent;

  /// No description provided for @netFlow.
  ///
  /// In en, this message translates to:
  /// **'{month} net flow'**
  String netFlow(String month);

  /// No description provided for @savingThisMonth.
  ///
  /// In en, this message translates to:
  /// **'You are saving this month'**
  String get savingThisMonth;

  /// No description provided for @spendingExceeded.
  ///
  /// In en, this message translates to:
  /// **'Spending exceeded income'**
  String get spendingExceeded;

  /// No description provided for @askMapatoAi.
  ///
  /// In en, this message translates to:
  /// **'Ask Mapato AI'**
  String get askMapatoAi;

  /// No description provided for @switchToLight.
  ///
  /// In en, this message translates to:
  /// **'Switch to light'**
  String get switchToLight;

  /// No description provided for @switchToDark.
  ///
  /// In en, this message translates to:
  /// **'Switch to dark'**
  String get switchToDark;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @notifOnMessage.
  ///
  /// In en, this message translates to:
  /// **'Notification access is on -- your M-Pesa, Mixx, Airtel, HaloPesa, AzamPesa and bank transactions will appear here automatically as they arrive.'**
  String get notifOnMessage;

  /// No description provided for @notifOffMessage.
  ///
  /// In en, this message translates to:
  /// **'Enable notification access in Settings and your M-Pesa, Mixx, Airtel, HaloPesa, AzamPesa and bank transactions will appear here automatically.'**
  String get notifOffMessage;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Your money, every network, one view.'**
  String get tagline;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Mapato'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'The personal finance tracker built for every Tanzanian mobile-money wallet.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingCapturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Captures every wallet'**
  String get onboardingCapturesTitle;

  /// No description provided for @onboardingCapturesBody.
  ///
  /// In en, this message translates to:
  /// **'Automatically reads your M-Pesa, Mixx by Yas, Airtel Money, HaloPesa and AzamPesa transactions -- via notifications and SMS.'**
  String get onboardingCapturesBody;

  /// No description provided for @onboardingPrivateTitle.
  ///
  /// In en, this message translates to:
  /// **'Private by design'**
  String get onboardingPrivateTitle;

  /// No description provided for @onboardingPrivateBody.
  ///
  /// In en, this message translates to:
  /// **'Everything is processed and stored on your device. Your financial data never leaves your phone.'**
  String get onboardingPrivateBody;

  /// No description provided for @onboardingInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Beautiful insights'**
  String get onboardingInsightsTitle;

  /// No description provided for @onboardingInsightsBody.
  ///
  /// In en, this message translates to:
  /// **'See income, expenses, and exactly where your money goes -- by category and by network.'**
  String get onboardingInsightsBody;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @enableNotificationAccess.
  ///
  /// In en, this message translates to:
  /// **'Enable notification access'**
  String get enableNotificationAccess;

  /// No description provided for @onboardingLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get onboardingLanguageTitle;

  /// No description provided for @onboardingLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can change this later in Settings'**
  String get onboardingLanguageSubtitle;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @swahili.
  ///
  /// In en, this message translates to:
  /// **'Kiswahili'**
  String get swahili;

  /// No description provided for @pinEnterYourPin.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get pinEnterYourPin;

  /// No description provided for @pinCreate4Digit.
  ///
  /// In en, this message translates to:
  /// **'Create a 4-digit PIN'**
  String get pinCreate4Digit;

  /// No description provided for @pinEnterCurrent.
  ///
  /// In en, this message translates to:
  /// **'Enter current PIN'**
  String get pinEnterCurrent;

  /// No description provided for @pinIncorrectCurrent.
  ///
  /// In en, this message translates to:
  /// **'Incorrect current PIN'**
  String get pinIncorrectCurrent;

  /// No description provided for @pinEnterNew.
  ///
  /// In en, this message translates to:
  /// **'Enter new PIN'**
  String get pinEnterNew;

  /// No description provided for @pinConfirmNew.
  ///
  /// In en, this message translates to:
  /// **'Confirm new PIN'**
  String get pinConfirmNew;

  /// No description provided for @pinMismatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match. Try again.'**
  String get pinMismatch;

  /// No description provided for @pinConfirmYour.
  ///
  /// In en, this message translates to:
  /// **'Confirm your PIN'**
  String get pinConfirmYour;

  /// No description provided for @pinIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN'**
  String get pinIncorrect;

  /// No description provided for @changePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePin;

  /// No description provided for @secureTracker.
  ///
  /// In en, this message translates to:
  /// **'Secure your money tracker'**
  String get secureTracker;

  /// No description provided for @setNewPin.
  ///
  /// In en, this message translates to:
  /// **'Set a new PIN'**
  String get setNewPin;

  /// No description provided for @verifyCurrentPin.
  ///
  /// In en, this message translates to:
  /// **'Verify your current PIN'**
  String get verifyCurrentPin;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @deleteCountQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete {count, plural, =1{# transaction} other{# transactions}}?'**
  String deleteCountQuestion(int count);

  /// No description provided for @actionCannotUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get actionCannotUndone;

  /// No description provided for @searchTransactions.
  ///
  /// In en, this message translates to:
  /// **'Search transactions...'**
  String get searchTransactions;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// No description provided for @deleteSelected.
  ///
  /// In en, this message translates to:
  /// **'Delete selected'**
  String get deleteSelected;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @noMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches.'**
  String get noMatches;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @noTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No transactions found. Turn on capture in Settings, add one manually, or change the date filter.'**
  String get noTransactionsFound;

  /// No description provided for @enterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get enterValidAmount;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit transaction'**
  String get editTransaction;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @amountTsh.
  ///
  /// In en, this message translates to:
  /// **'Amount (Tsh)'**
  String get amountTsh;

  /// No description provided for @networkLabel.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get networkLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @counterpartyOptional.
  ///
  /// In en, this message translates to:
  /// **'Counterparty (optional)'**
  String get counterpartyOptional;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @deleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Delete transaction?'**
  String get deleteTransaction;

  /// No description provided for @transaction.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transaction;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @notifSource.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notifSource;

  /// No description provided for @manualSource.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manualSource;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @noteDetail.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteDetail;

  /// No description provided for @originalMessage.
  ///
  /// In en, this message translates to:
  /// **'Original message'**
  String get originalMessage;

  /// No description provided for @addedDirection.
  ///
  /// In en, this message translates to:
  /// **'Added {direction} {amount}'**
  String addedDirection(String direction, String amount);

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get addTransaction;

  /// No description provided for @saveTransaction.
  ///
  /// In en, this message translates to:
  /// **'Save transaction'**
  String get saveTransaction;

  /// No description provided for @dataCapture.
  ///
  /// In en, this message translates to:
  /// **'Data Capture'**
  String get dataCapture;

  /// No description provided for @notificationAccess.
  ///
  /// In en, this message translates to:
  /// **'Notification access'**
  String get notificationAccess;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @requiredToAutoCapture.
  ///
  /// In en, this message translates to:
  /// **'Required to auto-capture'**
  String get requiredToAutoCapture;

  /// No description provided for @enableBtn.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enableBtn;

  /// No description provided for @smsCapture.
  ///
  /// In en, this message translates to:
  /// **'SMS capture'**
  String get smsCapture;

  /// No description provided for @fallbackNoNotification.
  ///
  /// In en, this message translates to:
  /// **'Fallback when no notification'**
  String get fallbackNoNotification;

  /// No description provided for @captureSources.
  ///
  /// In en, this message translates to:
  /// **'Capture sources'**
  String get captureSources;

  /// No description provided for @allApps.
  ///
  /// In en, this message translates to:
  /// **'All apps'**
  String get allApps;

  /// No description provided for @captureSourcesSelected.
  ///
  /// In en, this message translates to:
  /// **'{count}/{total} selected'**
  String captureSourcesSelected(int count, int total);

  /// No description provided for @captureFromAllApps.
  ///
  /// In en, this message translates to:
  /// **'Capture from all apps'**
  String get captureFromAllApps;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @appLockPin.
  ///
  /// In en, this message translates to:
  /// **'App lock (PIN)'**
  String get appLockPin;

  /// No description provided for @requirePinToOpen.
  ///
  /// In en, this message translates to:
  /// **'Require PIN to open'**
  String get requirePinToOpen;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeTitle;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @dataSection.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get dataSection;

  /// No description provided for @transactionsCaptured.
  ///
  /// In en, this message translates to:
  /// **'Transactions captured'**
  String get transactionsCaptured;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @parserLab.
  ///
  /// In en, this message translates to:
  /// **'Parser Lab'**
  String get parserLab;

  /// No description provided for @backupRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup and Restore'**
  String get backupRestore;

  /// No description provided for @exportBtn.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportBtn;

  /// No description provided for @importBtn.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importBtn;

  /// No description provided for @importedCount.
  ///
  /// In en, this message translates to:
  /// **'Imported {count, plural, =1{# transaction} other{# transactions}}.'**
  String importedCount(int count);

  /// No description provided for @noValidTransactions.
  ///
  /// In en, this message translates to:
  /// **'No valid transactions found.'**
  String get noValidTransactions;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @personalMoneyTracker.
  ///
  /// In en, this message translates to:
  /// **'Personal money tracker - v1.0.0'**
  String get personalMoneyTracker;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Supports M-Pesa, Mixx by Yas, Airtel Money, HaloPesa and AzamPesa. Your data stays on your device.'**
  String get aboutDescription;

  /// No description provided for @failedToOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Failed to open settings: {error}'**
  String failedToOpenSettings(String error);

  /// No description provided for @smsPermissionFailed.
  ///
  /// In en, this message translates to:
  /// **'SMS permission failed: {error}'**
  String smsPermissionFailed(String error);

  /// No description provided for @smsPermissionBlocked.
  ///
  /// In en, this message translates to:
  /// **'SMS Permission Blocked'**
  String get smsPermissionBlocked;

  /// No description provided for @smsPermissionBlockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Google Play Protect is blocking SMS permission for Mapato. To enable SMS capture: Open Google Play Store, tap your profile icon then Play Protect, tap the settings gear icon, turn OFF Improve harmful app protection. This is safe -- Mapato only reads mobile-money SMS. Alternatively, use Notification access only (recommended).'**
  String get smsPermissionBlockedMessage;

  /// No description provided for @chatHistory.
  ///
  /// In en, this message translates to:
  /// **'Chat history'**
  String get chatHistory;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get newChat;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @mapatoAi.
  ///
  /// In en, this message translates to:
  /// **'Mapato AI'**
  String get mapatoAi;

  /// No description provided for @askAboutMoney.
  ///
  /// In en, this message translates to:
  /// **'Ask about your spending, saving, or how mobile money works in Tanzania.'**
  String get askAboutMoney;

  /// No description provided for @aiUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Mapato AI is unavailable right now.'**
  String get aiUnavailable;

  /// No description provided for @couldNotReachAi.
  ///
  /// In en, this message translates to:
  /// **'Could not reach Mapato AI. Check your connection and try again.'**
  String get couldNotReachAi;

  /// No description provided for @askHint.
  ///
  /// In en, this message translates to:
  /// **'Ask about your money...'**
  String get askHint;

  /// No description provided for @categoriesInstruction.
  ///
  /// In en, this message translates to:
  /// **'Tap a category to edit its name, color and icon. Custom categories appear when adding or editing transactions.'**
  String get categoriesInstruction;

  /// No description provided for @newCategory.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get newCategory;

  /// No description provided for @enterCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Enter a category name'**
  String get enterCategoryName;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategory;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @icon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get icon;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get deleteCategory;

  /// No description provided for @parserLabInstruction.
  ///
  /// In en, this message translates to:
  /// **'Paste a real money SMS or notification text below to see how Mapato will parse it. Use this to tune lib/parser.dart for each network. Anything that returns no match means the regex needs work.'**
  String get parserLabInstruction;

  /// No description provided for @recentCaptured.
  ///
  /// In en, this message translates to:
  /// **'Recent captured (tap to load)'**
  String get recentCaptured;

  /// No description provided for @noCapturesYet.
  ///
  /// In en, this message translates to:
  /// **'No captures yet. Enable notification/SMS access and do a real transfer to populate this list.'**
  String get noCapturesYet;

  /// No description provided for @sampleMessage.
  ///
  /// In en, this message translates to:
  /// **'Sample message'**
  String get sampleMessage;

  /// No description provided for @noMatch.
  ///
  /// In en, this message translates to:
  /// **'No match -- parser returned null. Tune the regexes.'**
  String get noMatch;

  /// No description provided for @directionLabel.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get directionLabel;

  /// No description provided for @counterparty.
  ///
  /// In en, this message translates to:
  /// **'Counterparty'**
  String get counterparty;

  /// No description provided for @allowNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow Mapato to send you notifications?'**
  String get allowNotificationsTitle;

  /// No description provided for @allowNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'Mapato needs notification access to automatically capture your M-Pesa, Mixx, Airtel, HaloPesa and AzamPesa transactions as they happen.'**
  String get allowNotificationsBody;

  /// No description provided for @allowSmsTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow Mapato to read your SMS?'**
  String get allowSmsTitle;

  /// No description provided for @allowSmsBody.
  ///
  /// In en, this message translates to:
  /// **'Mapato reads your M-Pesa, Mixx, Airtel, HaloPesa and AzamPesa SMS messages to automatically record transactions. Your messages stay on your device.'**
  String get allowSmsBody;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @permissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up capture'**
  String get permissionsTitle;

  /// No description provided for @permissionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Allow Mapato to read your mobile-money notifications and SMS so it can automatically record transactions.'**
  String get permissionsSubtitle;

  /// No description provided for @notificationAccessLabel.
  ///
  /// In en, this message translates to:
  /// **'Notification access'**
  String get notificationAccessLabel;

  /// No description provided for @notificationAccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Capture M-Pesa, Mixx, Airtel, HaloPesa, AzamPesa and bank notifications'**
  String get notificationAccessDesc;

  /// No description provided for @smsAccessLabel.
  ///
  /// In en, this message translates to:
  /// **'SMS access'**
  String get smsAccessLabel;

  /// No description provided for @smsAccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Read mobile-money and bank SMS as a backup when notifications are off'**
  String get smsAccessDesc;

  /// No description provided for @enableAccess.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enableAccess;

  /// No description provided for @granted.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get granted;

  /// No description provided for @setupComplete.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get setupComplete;

  /// No description provided for @notifAccessDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable notification access'**
  String get notifAccessDialogTitle;

  /// No description provided for @notifAccessDialogBody.
  ///
  /// In en, this message translates to:
  /// **'1. Tap Open Settings below\n2. Find Mapato in the list\n3. Tap it and toggle ON\n4. Confirm the warning\n5. Press back to return to Mapato\n\nIf Mapato is not listed, the app may need to be opened again after install.'**
  String get notifAccessDialogBody;

  /// No description provided for @aiSection.
  ///
  /// In en, this message translates to:
  /// **'Mapato AI'**
  String get aiSection;

  /// No description provided for @groqApiKey.
  ///
  /// In en, this message translates to:
  /// **'Groq API Key'**
  String get groqApiKey;

  /// No description provided for @groqApiKeyDesc.
  ///
  /// In en, this message translates to:
  /// **'Get a free key at console.groq.com'**
  String get groqApiKeyDesc;

  /// No description provided for @enterApiKey.
  ///
  /// In en, this message translates to:
  /// **'Enter your API key'**
  String get enterApiKey;

  /// No description provided for @aiModel.
  ///
  /// In en, this message translates to:
  /// **'AI Model'**
  String get aiModel;

  /// No description provided for @aiModelDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose which model to use'**
  String get aiModelDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

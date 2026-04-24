import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Must Go Out'**
  String get appTitle;

  /// No description provided for @mustLeaveTime.
  ///
  /// In en, this message translates to:
  /// **'Departure Time'**
  String get mustLeaveTime;

  /// No description provided for @tapToChangeTime.
  ///
  /// In en, this message translates to:
  /// **'Tap to change time'**
  String get tapToChangeTime;

  /// No description provided for @preparationStartTime.
  ///
  /// In en, this message translates to:
  /// **'Prep Start Alarm'**
  String get preparationStartTime;

  /// No description provided for @totalPreparationTime.
  ///
  /// In en, this message translates to:
  /// **'Total Prep Time'**
  String get totalPreparationTime;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutes;

  /// No description provided for @noRoutine.
  ///
  /// In en, this message translates to:
  /// **'No Routine'**
  String get noRoutine;

  /// No description provided for @editSteps.
  ///
  /// In en, this message translates to:
  /// **'Edit Steps'**
  String get editSteps;

  /// No description provided for @alarmRepeat.
  ///
  /// In en, this message translates to:
  /// **'Alarm Repeat'**
  String get alarmRepeat;

  /// No description provided for @everyday.
  ///
  /// In en, this message translates to:
  /// **'Everyday'**
  String get everyday;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @weekdays.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get weekdays;

  /// No description provided for @weekends.
  ///
  /// In en, this message translates to:
  /// **'Weekends'**
  String get weekends;

  /// No description provided for @routineManagement.
  ///
  /// In en, this message translates to:
  /// **'Manage Routines'**
  String get routineManagement;

  /// No description provided for @newRoutine.
  ///
  /// In en, this message translates to:
  /// **'New Routine'**
  String get newRoutine;

  /// No description provided for @freeLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'Free version is limited to 2 routines. Subscribe to Premium!'**
  String get freeLimitMessage;

  /// No description provided for @maxStepLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'You can add up to 10 steps.'**
  String get maxStepLimitMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @stepName.
  ///
  /// In en, this message translates to:
  /// **'Step Name'**
  String get stepName;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @setDepartureTime.
  ///
  /// In en, this message translates to:
  /// **'Set Departure Time'**
  String get setDepartureTime;

  /// No description provided for @setRepeatDays.
  ///
  /// In en, this message translates to:
  /// **'Set Repeat Days'**
  String get setRepeatDays;

  /// No description provided for @startPreparation.
  ///
  /// In en, this message translates to:
  /// **'Schedule / Start Prep'**
  String get startPreparation;

  /// No description provided for @preparationStep.
  ///
  /// In en, this message translates to:
  /// **'Preparation Steps'**
  String get preparationStep;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Calculating your morning reverse'**
  String get splashSubtitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @korean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get korean;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @japanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get japanese;

  /// No description provided for @chineseSimplified.
  ///
  /// In en, this message translates to:
  /// **'Chinese (Simplified)'**
  String get chineseSimplified;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunday;

  /// No description provided for @routine_1.
  ///
  /// In en, this message translates to:
  /// **'Routine 1'**
  String get routine_1;

  /// No description provided for @routine_2.
  ///
  /// In en, this message translates to:
  /// **'Routine 2'**
  String get routine_2;

  /// No description provided for @routine_ui_test.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get routine_ui_test;

  /// No description provided for @item_step.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get item_step;

  /// No description provided for @add_step.
  ///
  /// In en, this message translates to:
  /// **'Add Step'**
  String get add_step;

  /// No description provided for @edit_step.
  ///
  /// In en, this message translates to:
  /// **'Edit Step'**
  String get edit_step;

  /// No description provided for @delete_step.
  ///
  /// In en, this message translates to:
  /// **'Delete Step'**
  String get delete_step;

  /// No description provided for @preparationTimeline.
  ///
  /// In en, this message translates to:
  /// **'Preparation Timeline'**
  String get preparationTimeline;

  /// No description provided for @delayOccurred.
  ///
  /// In en, this message translates to:
  /// **'Delay Occurred'**
  String get delayOccurred;

  /// No description provided for @hurryUp.
  ///
  /// In en, this message translates to:
  /// **'Hurry Up!'**
  String get hurryUp;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @preparationResult.
  ///
  /// In en, this message translates to:
  /// **'Preparation Result'**
  String get preparationResult;

  /// No description provided for @preparationFinished.
  ///
  /// In en, this message translates to:
  /// **'Preparation Finished!'**
  String get preparationFinished;

  /// No description provided for @resultDescription.
  ///
  /// In en, this message translates to:
  /// **'Here are your preparation results for today'**
  String get resultDescription;

  /// No description provided for @totalScore.
  ///
  /// In en, this message translates to:
  /// **'Total Score'**
  String get totalScore;

  /// No description provided for @lateByMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min Late'**
  String lateByMinutes(Object minutes);

  /// No description provided for @onTimeDeparture.
  ///
  /// In en, this message translates to:
  /// **'On Time Departure'**
  String get onTimeDeparture;

  /// No description provided for @planned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get planned;

  /// No description provided for @actual.
  ///
  /// In en, this message translates to:
  /// **'Actual'**
  String get actual;

  /// No description provided for @delayedFeedback.
  ///
  /// In en, this message translates to:
  /// **'Took {minutes} min longer than planned.'**
  String delayedFeedback(Object minutes);

  /// No description provided for @earlyFeedback.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You finished earlier than planned.\nHave a relaxed departure.'**
  String get earlyFeedback;

  /// No description provided for @plannedActualRatio.
  ///
  /// In en, this message translates to:
  /// **'Planned {planned}m / Actual {actual}m {seconds}s'**
  String plannedActualRatio(Object actual, Object planned, Object seconds);

  /// No description provided for @returnToMain.
  ///
  /// In en, this message translates to:
  /// **'Return to Main'**
  String get returnToMain;

  /// No description provided for @routinePresetSelection.
  ///
  /// In en, this message translates to:
  /// **'Select Routine/Preset'**
  String get routinePresetSelection;

  /// No description provided for @systemPreset.
  ///
  /// In en, this message translates to:
  /// **'System Preset'**
  String get systemPreset;

  /// No description provided for @userRoutine.
  ///
  /// In en, this message translates to:
  /// **'User Routine'**
  String get userRoutine;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Error occurred: {error}'**
  String errorOccurred(Object error);

  /// No description provided for @preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get preparing;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @extendOneMinute.
  ///
  /// In en, this message translates to:
  /// **'+ 1 min (Current Step)'**
  String get extendOneMinute;

  /// No description provided for @finalDepartureExpected.
  ///
  /// In en, this message translates to:
  /// **'Expected Departure: {time}'**
  String finalDepartureExpected(Object time);

  /// No description provided for @freeModeSwitched.
  ///
  /// In en, this message translates to:
  /// **'Switched to Free Mode'**
  String get freeModeSwitched;

  /// No description provided for @proModeSwitched.
  ///
  /// In en, this message translates to:
  /// **'Switched to Pro Mode (Unlimited Routines)'**
  String get proModeSwitched;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeMode;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @leaveAt.
  ///
  /// In en, this message translates to:
  /// **'Leave at {time}'**
  String leaveAt(String time);

  /// No description provided for @alarmNotSet.
  ///
  /// In en, this message translates to:
  /// **'Alarm not set'**
  String get alarmNotSet;

  /// No description provided for @alarmSet.
  ///
  /// In en, this message translates to:
  /// **'Alarm set'**
  String get alarmSet;

  /// No description provided for @wakeUpAt.
  ///
  /// In en, this message translates to:
  /// **'Wake'**
  String get wakeUpAt;

  /// No description provided for @departureAt.
  ///
  /// In en, this message translates to:
  /// **'Depart'**
  String get departureAt;

  /// No description provided for @deleteRoutineConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this routine?'**
  String get deleteRoutineConfirm;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'en',
        'es',
        'fr',
        'ja',
        'ko',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

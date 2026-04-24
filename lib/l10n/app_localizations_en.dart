// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Must Go Out';

  @override
  String get mustLeaveTime => 'Departure Time';

  @override
  String get tapToChangeTime => 'Tap to change time';

  @override
  String get preparationStartTime => 'Prep Start Alarm';

  @override
  String get totalPreparationTime => 'Total Prep Time';

  @override
  String get minutes => 'min';

  @override
  String get noRoutine => 'No Routine';

  @override
  String get editSteps => 'Edit Steps';

  @override
  String get alarmRepeat => 'Alarm Repeat';

  @override
  String get everyday => 'Everyday';

  @override
  String get none => 'None';

  @override
  String get weekdays => 'Weekdays';

  @override
  String get weekends => 'Weekends';

  @override
  String get routineManagement => 'Manage Routines';

  @override
  String get newRoutine => 'New Routine';

  @override
  String get freeLimitMessage =>
      'Free version is limited to 2 routines. Subscribe to Premium!';

  @override
  String get maxStepLimitMessage => 'You can add up to 10 steps.';

  @override
  String get cancel => 'Cancel';

  @override
  String get stepName => 'Step Name';

  @override
  String get confirm => 'Confirm';

  @override
  String get setDepartureTime => 'Set Departure Time';

  @override
  String get setRepeatDays => 'Set Repeat Days';

  @override
  String get startPreparation => 'Schedule / Start Prep';

  @override
  String get preparationStep => 'Preparation Steps';

  @override
  String get splashSubtitle => 'Calculating your morning reverse';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get systemDefault => 'System Default';

  @override
  String get korean => 'Korean';

  @override
  String get english => 'English';

  @override
  String get japanese => 'Japanese';

  @override
  String get chineseSimplified => 'Chinese (Simplified)';

  @override
  String get spanish => 'Spanish';

  @override
  String get french => 'French';

  @override
  String get monday => 'Mon';

  @override
  String get tuesday => 'Tue';

  @override
  String get wednesday => 'Wed';

  @override
  String get thursday => 'Thu';

  @override
  String get friday => 'Fri';

  @override
  String get saturday => 'Sat';

  @override
  String get sunday => 'Sun';

  @override
  String get routine_1 => 'Routine 1';

  @override
  String get routine_2 => 'Routine 2';

  @override
  String get routine_ui_test => 'Test';

  @override
  String get item_step => 'Step';

  @override
  String get add_step => 'Add Step';

  @override
  String get edit_step => 'Edit Step';

  @override
  String get delete_step => 'Delete Step';

  @override
  String get preparationTimeline => 'Preparation Timeline';

  @override
  String get delayOccurred => 'Delay Occurred';

  @override
  String get hurryUp => 'Hurry Up!';

  @override
  String get completed => 'Completed';

  @override
  String get preparationResult => 'Preparation Result';

  @override
  String get preparationFinished => 'Preparation Finished!';

  @override
  String get resultDescription => 'Here are your preparation results for today';

  @override
  String get totalScore => 'Total Score';

  @override
  String lateByMinutes(Object minutes) {
    return '$minutes min Late';
  }

  @override
  String get onTimeDeparture => 'On Time Departure';

  @override
  String get planned => 'Planned';

  @override
  String get actual => 'Actual';

  @override
  String delayedFeedback(Object minutes) {
    return 'Took $minutes min longer than planned.';
  }

  @override
  String get earlyFeedback =>
      'Congratulations! You finished earlier than planned.\nHave a relaxed departure.';

  @override
  String plannedActualRatio(Object actual, Object planned, Object seconds) {
    return 'Planned ${planned}m / Actual ${actual}m ${seconds}s';
  }

  @override
  String get returnToMain => 'Return to Main';

  @override
  String get routinePresetSelection => 'Select Routine/Preset';

  @override
  String get systemPreset => 'System Preset';

  @override
  String get userRoutine => 'User Routine';

  @override
  String errorOccurred(Object error) {
    return 'Error occurred: $error';
  }

  @override
  String get preparing => 'Preparing';

  @override
  String get stop => 'Stop';

  @override
  String get extendOneMinute => '+ 1 min (Current Step)';

  @override
  String finalDepartureExpected(Object time) {
    return 'Expected Departure: $time';
  }

  @override
  String get freeModeSwitched => 'Switched to Free Mode';

  @override
  String get proModeSwitched => 'Switched to Pro Mode (Unlimited Routines)';

  @override
  String get themeMode => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String leaveAt(String time) {
    return 'Leave at $time';
  }

  @override
  String get alarmNotSet => 'Alarm not set';

  @override
  String get alarmSet => 'Alarm set';

  @override
  String get wakeUpAt => 'Wake';

  @override
  String get departureAt => 'Depart';

  @override
  String get deleteRoutineConfirm => 'Delete this routine?';
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Dépêche-toi';

  @override
  String get mustLeaveTime => 'Heure de départ';

  @override
  String get tapToChangeTime => 'Appuyer pour changer l\'heure';

  @override
  String get preparationStartTime => 'Alarme de début';

  @override
  String get totalPreparationTime => 'Temps total de préparation';

  @override
  String get minutes => 'min';

  @override
  String get noRoutine => 'Aucune routine';

  @override
  String get editSteps => 'Modifier les étapes';

  @override
  String get alarmRepeat => 'Répétition d\'alarme';

  @override
  String get everyday => 'Tous les jours';

  @override
  String get none => 'Aucun';

  @override
  String get weekdays => 'Jours de semaine';

  @override
  String get weekends => 'Week-ends';

  @override
  String get routineManagement => 'Gérer les routines';

  @override
  String get newRoutine => 'Nouvelle routine';

  @override
  String get freeLimitMessage =>
      'La version gratuite est limitée à 2 routines. Abonnez-vous à Premium !';

  @override
  String get maxStepLimitMessage => 'Vous pouvez ajouter jusqu\'à 10 étapes.';

  @override
  String get cancel => 'Annuler';

  @override
  String get stepName => 'Nom de l\'étape';

  @override
  String get confirm => 'Confirmer';

  @override
  String get setDepartureTime => 'Définir l\'heure de départ';

  @override
  String get setRepeatDays => 'Définir les jours de répétition';

  @override
  String get startPreparation => 'Planifier / Démarrer la préparation';

  @override
  String get preparationStep => 'Étapes de préparation';

  @override
  String get splashSubtitle => 'Calcul de votre matin en sens inverse';

  @override
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get systemDefault => 'Défaut du système';

  @override
  String get korean => 'Coréen';

  @override
  String get english => 'Anglais';

  @override
  String get japanese => 'Japonais';

  @override
  String get chineseSimplified => 'Chinois (Simplifié)';

  @override
  String get spanish => 'Espagnol';

  @override
  String get french => 'Français';

  @override
  String get monday => 'Lun';

  @override
  String get tuesday => 'Mar';

  @override
  String get wednesday => 'Mer';

  @override
  String get thursday => 'Jeu';

  @override
  String get friday => 'Ven';

  @override
  String get saturday => 'Sam';

  @override
  String get sunday => 'Dim';

  @override
  String get routine_1 => 'Routine 1';

  @override
  String get routine_2 => 'Routine 2';

  @override
  String get routine_ui_test => 'Test';

  @override
  String get item_step => 'Étape';

  @override
  String get add_step => 'Ajouter une étape';

  @override
  String get edit_step => 'Modifier l\'étape';

  @override
  String get delete_step => 'Supprimer l\'étape';

  @override
  String get preparationTimeline => 'Chronologie de préparation';

  @override
  String get delayOccurred => 'Retard survenu';

  @override
  String get hurryUp => 'Dépêchez-vous !';

  @override
  String get completed => 'Terminé';

  @override
  String get preparationResult => 'Résultat de préparation';

  @override
  String get preparationFinished => 'Préparation terminée !';

  @override
  String get resultDescription =>
      'Voici vos résultats de préparation d\'aujourd\'hui';

  @override
  String get totalScore => 'Score total';

  @override
  String lateByMinutes(Object minutes) {
    return '$minutes min de retard';
  }

  @override
  String get onTimeDeparture => 'Départ à l\'heure';

  @override
  String get planned => 'Prévu';

  @override
  String get actual => 'Réel';

  @override
  String delayedFeedback(Object minutes) {
    return 'Vous avez pris $minutes min de plus que prévu.';
  }

  @override
  String get earlyFeedback =>
      'Félicitations ! Vous avez terminé plus tôt que prévu.\nProfitez d\'un départ serein.';

  @override
  String plannedActualRatio(Object actual, Object planned, Object seconds) {
    return 'Prévu ${planned}m / Réel ${actual}m ${seconds}s';
  }

  @override
  String get returnToMain => 'Retour à l\'accueil';

  @override
  String get routinePresetSelection => 'Sélectionner une routine/préréglage';

  @override
  String get systemPreset => 'Préréglage système';

  @override
  String get userRoutine => 'Routine utilisateur';

  @override
  String errorOccurred(Object error) {
    return 'Erreur survenue : $error';
  }

  @override
  String get preparing => 'Préparation en cours';

  @override
  String get stop => 'Arrêter';

  @override
  String get extendOneMinute => '+ 1 min (Étape actuelle)';

  @override
  String finalDepartureExpected(Object time) {
    return 'Départ prévu : $time';
  }

  @override
  String get freeModeSwitched => 'Passé en mode gratuit';

  @override
  String get proModeSwitched => 'Passé en mode Pro (routines illimitées)';

  @override
  String get themeMode => 'Thème';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeSystem => 'Système';

  @override
  String leaveAt(String time) {
    return 'Départ à $time';
  }

  @override
  String get alarmNotSet => 'Alarme non définie';

  @override
  String get alarmSet => 'Alarme définie';

  @override
  String get wakeUpAt => 'Réveil';

  @override
  String get departureAt => 'Départ';

  @override
  String get deleteRoutineConfirm => 'Supprimer cette routine ?';
}

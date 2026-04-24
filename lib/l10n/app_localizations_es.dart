// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Salir Ya';

  @override
  String get mustLeaveTime => 'Hora de salida';

  @override
  String get tapToChangeTime => 'Toca para cambiar la hora';

  @override
  String get preparationStartTime => 'Alarma de inicio';

  @override
  String get totalPreparationTime => 'Tiempo total de preparación';

  @override
  String get minutes => 'min';

  @override
  String get noRoutine => 'Sin rutina';

  @override
  String get editSteps => 'Editar pasos';

  @override
  String get alarmRepeat => 'Repetir alarma';

  @override
  String get everyday => 'Todos los días';

  @override
  String get none => 'Ninguno';

  @override
  String get weekdays => 'Días laborables';

  @override
  String get weekends => 'Fines de semana';

  @override
  String get routineManagement => 'Gestionar rutinas';

  @override
  String get newRoutine => 'Nueva rutina';

  @override
  String get freeLimitMessage =>
      'La versión gratuita está limitada a 2 rutinas. ¡Suscríbete a Premium!';

  @override
  String get maxStepLimitMessage => 'Puedes agregar hasta 10 pasos.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get stepName => 'Nombre del paso';

  @override
  String get confirm => 'Confirmar';

  @override
  String get setDepartureTime => 'Establecer hora de salida';

  @override
  String get setRepeatDays => 'Establecer días de repetición';

  @override
  String get startPreparation => 'Programar / Iniciar preparación';

  @override
  String get preparationStep => 'Pasos de preparación';

  @override
  String get splashSubtitle => 'Calculando tu mañana inversa';

  @override
  String get settings => 'Configuración';

  @override
  String get language => 'Idioma';

  @override
  String get systemDefault => 'Predeterminado del sistema';

  @override
  String get korean => 'Coreano';

  @override
  String get english => 'Inglés';

  @override
  String get japanese => 'Japonés';

  @override
  String get chineseSimplified => 'Chino (Simplificado)';

  @override
  String get spanish => 'Español';

  @override
  String get french => 'Francés';

  @override
  String get monday => 'Lun';

  @override
  String get tuesday => 'Mar';

  @override
  String get wednesday => 'Mié';

  @override
  String get thursday => 'Jue';

  @override
  String get friday => 'Vie';

  @override
  String get saturday => 'Sáb';

  @override
  String get sunday => 'Dom';

  @override
  String get routine_1 => 'Rutina 1';

  @override
  String get routine_2 => 'Rutina 2';

  @override
  String get routine_ui_test => 'Prueba';

  @override
  String get item_step => 'Paso';

  @override
  String get add_step => 'Agregar paso';

  @override
  String get edit_step => 'Editar paso';

  @override
  String get delete_step => 'Eliminar paso';

  @override
  String get preparationTimeline => 'Línea de tiempo de preparación';

  @override
  String get delayOccurred => 'Retraso ocurrido';

  @override
  String get hurryUp => '¡Date prisa!';

  @override
  String get completed => 'Completado';

  @override
  String get preparationResult => 'Resultado de preparación';

  @override
  String get preparationFinished => '¡Preparación terminada!';

  @override
  String get resultDescription =>
      'Aquí están tus resultados de preparación de hoy';

  @override
  String get totalScore => 'Puntuación total';

  @override
  String lateByMinutes(Object minutes) {
    return '$minutes min de retraso';
  }

  @override
  String get onTimeDeparture => 'Salida a tiempo';

  @override
  String get planned => 'Planificado';

  @override
  String get actual => 'Real';

  @override
  String delayedFeedback(Object minutes) {
    return 'Tardaste $minutes min más de lo planificado.';
  }

  @override
  String get earlyFeedback =>
      '¡Felicidades! Terminaste antes de lo planificado.\nTen una salida tranquila.';

  @override
  String plannedActualRatio(Object actual, Object planned, Object seconds) {
    return 'Planif. ${planned}m / Real ${actual}m ${seconds}s';
  }

  @override
  String get returnToMain => 'Volver al inicio';

  @override
  String get routinePresetSelection => 'Seleccionar rutina/preset';

  @override
  String get systemPreset => 'Preset del sistema';

  @override
  String get userRoutine => 'Rutina de usuario';

  @override
  String errorOccurred(Object error) {
    return 'Error ocurrido: $error';
  }

  @override
  String get preparing => 'Preparando';

  @override
  String get stop => 'Detener';

  @override
  String get extendOneMinute => '+ 1 min (Paso actual)';

  @override
  String finalDepartureExpected(Object time) {
    return 'Salida esperada: $time';
  }

  @override
  String get freeModeSwitched => 'Cambiado a modo gratuito';

  @override
  String get proModeSwitched => 'Cambiado a modo Pro (rutinas ilimitadas)';

  @override
  String get themeMode => 'Tema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String leaveAt(String time) {
    return 'Salir a las $time';
  }

  @override
  String get alarmNotSet => 'Alarma no configurada';

  @override
  String get alarmSet => 'Alarma configurada';

  @override
  String get wakeUpAt => 'Despertar';

  @override
  String get departureAt => 'Salida';

  @override
  String get deleteRoutineConfirm => '¿Eliminar esta rutina?';
}

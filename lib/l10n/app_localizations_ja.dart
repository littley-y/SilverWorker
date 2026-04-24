// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '外出準備';

  @override
  String get mustLeaveTime => '出発時刻';

  @override
  String get tapToChangeTime => 'タップして時刻を変更';

  @override
  String get preparationStartTime => '準備開始アラーム';

  @override
  String get totalPreparationTime => '総準備時間';

  @override
  String get minutes => '分';

  @override
  String get noRoutine => 'ルーティンなし';

  @override
  String get editSteps => 'ステップ編集';

  @override
  String get alarmRepeat => 'アラーム繰り返し';

  @override
  String get everyday => '毎日';

  @override
  String get none => 'なし';

  @override
  String get weekdays => '平日';

  @override
  String get weekends => '週末';

  @override
  String get routineManagement => 'ルーティン管理';

  @override
  String get newRoutine => '新しいルーティン';

  @override
  String get freeLimitMessage => '無料版は2つのルーティンまで。プレミアムに登録！';

  @override
  String get maxStepLimitMessage => 'ステップは最大10個まで追加できます。';

  @override
  String get cancel => 'キャンセル';

  @override
  String get stepName => 'ステップ名';

  @override
  String get confirm => '確認';

  @override
  String get setDepartureTime => '出発時刻設定';

  @override
  String get setRepeatDays => '繰り返し曜日設定';

  @override
  String get startPreparation => 'スケジュール / 準備開始';

  @override
  String get preparationStep => '準備ステップ';

  @override
  String get splashSubtitle => 'あなたの朝を逆算します';

  @override
  String get settings => '設定';

  @override
  String get language => '言語設定';

  @override
  String get systemDefault => 'システムデフォルト';

  @override
  String get korean => '韓国語';

  @override
  String get english => '英語';

  @override
  String get japanese => '日本語';

  @override
  String get chineseSimplified => '中国語（簡体字）';

  @override
  String get spanish => 'スペイン語';

  @override
  String get french => 'フランス語';

  @override
  String get monday => '月';

  @override
  String get tuesday => '火';

  @override
  String get wednesday => '水';

  @override
  String get thursday => '木';

  @override
  String get friday => '金';

  @override
  String get saturday => '土';

  @override
  String get sunday => '日';

  @override
  String get routine_1 => 'ルーティン1';

  @override
  String get routine_2 => 'ルーティン2';

  @override
  String get routine_ui_test => 'テスト';

  @override
  String get item_step => 'ステップ';

  @override
  String get add_step => 'ステップ追加';

  @override
  String get edit_step => 'ステップ編集';

  @override
  String get delete_step => 'ステップ削除';

  @override
  String get preparationTimeline => '準備タイムライン';

  @override
  String get delayOccurred => '遅延発生';

  @override
  String get hurryUp => '急いで！';

  @override
  String get completed => '完了';

  @override
  String get preparationResult => '準備結果';

  @override
  String get preparationFinished => '準備完了！';

  @override
  String get resultDescription => '今日の準備結果です';

  @override
  String get totalScore => '総合スコア';

  @override
  String lateByMinutes(Object minutes) {
    return '$minutes分遅延';
  }

  @override
  String get onTimeDeparture => '時間通りに出発';

  @override
  String get planned => '予定';

  @override
  String get actual => '実際';

  @override
  String delayedFeedback(Object minutes) {
    return '予定より$minutes分多くかかりました。';
  }

  @override
  String get earlyFeedback => 'おめでとうございます！予定より早く終わりました。\nゆっくり出発しましょう。';

  @override
  String plannedActualRatio(Object actual, Object planned, Object seconds) {
    return '予定$planned分 / 実際$actual分$seconds秒';
  }

  @override
  String get returnToMain => 'メインに戻る';

  @override
  String get routinePresetSelection => 'ルーティン/プリセット選択';

  @override
  String get systemPreset => 'システムプリセット';

  @override
  String get userRoutine => 'ユーザールーティン';

  @override
  String errorOccurred(Object error) {
    return 'エラーが発生しました: $error';
  }

  @override
  String get preparing => '準備中';

  @override
  String get stop => '停止';

  @override
  String get extendOneMinute => '+ 1分（現在のステップ）';

  @override
  String finalDepartureExpected(Object time) {
    return '出発予定: $time';
  }

  @override
  String get freeModeSwitched => '無料モードに切り替えました';

  @override
  String get proModeSwitched => 'プロモードに切り替えました（ルーティン無制限）';

  @override
  String get themeMode => 'テーマ';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get themeSystem => 'システム';

  @override
  String leaveAt(String time) {
    return '$time に出発';
  }

  @override
  String get alarmNotSet => 'アラーム未設定';

  @override
  String get alarmSet => 'アラーム設定済み';

  @override
  String get wakeUpAt => '起床';

  @override
  String get departureAt => '出発';

  @override
  String get deleteRoutineConfirm => 'このルーティンを削除しますか？';
}

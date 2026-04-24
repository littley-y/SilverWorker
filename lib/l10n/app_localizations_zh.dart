// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '出门准备';

  @override
  String get mustLeaveTime => '出发时间';

  @override
  String get tapToChangeTime => '点击更改时间';

  @override
  String get preparationStartTime => '准备开始闹钟';

  @override
  String get totalPreparationTime => '总准备时间';

  @override
  String get minutes => '分钟';

  @override
  String get noRoutine => '无例程';

  @override
  String get editSteps => '编辑步骤';

  @override
  String get alarmRepeat => '闹钟重复';

  @override
  String get everyday => '每天';

  @override
  String get none => '无';

  @override
  String get weekdays => '工作日';

  @override
  String get weekends => '周末';

  @override
  String get routineManagement => '例程管理';

  @override
  String get newRoutine => '新建例程';

  @override
  String get freeLimitMessage => '免费版最多支持2个例程。订阅高级版！';

  @override
  String get maxStepLimitMessage => '最多可添加10个步骤。';

  @override
  String get cancel => '取消';

  @override
  String get stepName => '步骤名称';

  @override
  String get confirm => '确认';

  @override
  String get setDepartureTime => '设置出发时间';

  @override
  String get setRepeatDays => '设置重复日';

  @override
  String get startPreparation => '计划 / 开始准备';

  @override
  String get preparationStep => '准备步骤';

  @override
  String get splashSubtitle => '正在逆算您的早晨';

  @override
  String get settings => '设置';

  @override
  String get language => '语言设置';

  @override
  String get systemDefault => '系统默认';

  @override
  String get korean => '韩语';

  @override
  String get english => '英语';

  @override
  String get japanese => '日语';

  @override
  String get chineseSimplified => '中文（简体）';

  @override
  String get spanish => '西班牙语';

  @override
  String get french => '法语';

  @override
  String get monday => '周一';

  @override
  String get tuesday => '周二';

  @override
  String get wednesday => '周三';

  @override
  String get thursday => '周四';

  @override
  String get friday => '周五';

  @override
  String get saturday => '周六';

  @override
  String get sunday => '周日';

  @override
  String get routine_1 => '例程1';

  @override
  String get routine_2 => '例程2';

  @override
  String get routine_ui_test => '测试';

  @override
  String get item_step => '步骤';

  @override
  String get add_step => '添加步骤';

  @override
  String get edit_step => '编辑步骤';

  @override
  String get delete_step => '删除步骤';

  @override
  String get preparationTimeline => '准备时间轴';

  @override
  String get delayOccurred => '发生延误';

  @override
  String get hurryUp => '快点！';

  @override
  String get completed => '已完成';

  @override
  String get preparationResult => '准备结果';

  @override
  String get preparationFinished => '准备完成！';

  @override
  String get resultDescription => '以下是您今天的准备结果';

  @override
  String get totalScore => '总分';

  @override
  String lateByMinutes(Object minutes) {
    return '迟到$minutes分钟';
  }

  @override
  String get onTimeDeparture => '准时出发';

  @override
  String get planned => '计划';

  @override
  String get actual => '实际';

  @override
  String delayedFeedback(Object minutes) {
    return '比计划多花了$minutes分钟。';
  }

  @override
  String get earlyFeedback => '恭喜！您比计划提前完成了。\n从容出发吧。';

  @override
  String plannedActualRatio(Object actual, Object planned, Object seconds) {
    return '计划$planned分 / 实际$actual分$seconds秒';
  }

  @override
  String get returnToMain => '返回主页';

  @override
  String get routinePresetSelection => '选择例程/预设';

  @override
  String get systemPreset => '系统预设';

  @override
  String get userRoutine => '用户例程';

  @override
  String errorOccurred(Object error) {
    return '发生错误: $error';
  }

  @override
  String get preparing => '准备中';

  @override
  String get stop => '停止';

  @override
  String get extendOneMinute => '+ 1分钟（当前步骤）';

  @override
  String finalDepartureExpected(Object time) {
    return '预计出发: $time';
  }

  @override
  String get freeModeSwitched => '已切换到免费模式';

  @override
  String get proModeSwitched => '已切换到专业模式（无限例程）';

  @override
  String get themeMode => '主题';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get themeSystem => '系统';

  @override
  String leaveAt(String time) {
    return '$time 出发';
  }

  @override
  String get alarmNotSet => '未设置闹钟';

  @override
  String get alarmSet => '已设置闹钟';

  @override
  String get wakeUpAt => '起床';

  @override
  String get departureAt => '出发';

  @override
  String get deleteRoutineConfirm => '删除此例程？';
}

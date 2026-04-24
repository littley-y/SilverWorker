import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../providers/alarm_provider.dart';
import '../../models/models.dart';
import '../../l10n/app_localizations.dart';
import '../../core/l10n_utils.dart';
import 'dialogs/main_screen_dialogs.dart';

class SlidableRoutineItem extends ConsumerStatefulWidget {
  final RoutineItem item;
  final VoidCallback onLongPress;

  const SlidableRoutineItem({
    super.key,
    required this.item,
    required this.onLongPress,
  });

  @override
  ConsumerState<SlidableRoutineItem> createState() =>
      _SlidableRoutineItemState();
}

class _SlidableRoutineItemState extends ConsumerState<SlidableRoutineItem> {
  bool _hapticTriggered = false;
  SlidableController? _slidableController;

  @override
  void dispose() {
    _slidableController?.animation.removeListener(_handleRatioChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(alarmProvider.notifier);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey(widget.item.id ?? widget.item.hashCode),
        // 슬라이드 패널 설정
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.25, // 1/4 크기
          dismissible: DismissiblePane(
            dismissThreshold: 0.25, // 1/4 넘어가면 삭제 확정
            onDismissed: () {
              if (widget.item.id != null) {
                notifier.deleteRoutineItem(widget.item.id!);
              }
            },
            confirmDismiss: () async {
              // 삭제 직전 한 번 더 강한 진동
              HapticFeedback.heavyImpact();
              return true;
            },
          ),
          children: [
            SlidableAction(
              onPressed: (context) {
                if (widget.item.id != null) {
                  notifier.deleteRoutineItem(widget.item.id!);
                }
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: l10n.delete_step,
              borderRadius: BorderRadius.circular(20),
            ),
          ],
        ),
        child: Builder(builder: (context) {
          // 슬라이드 컨트롤러 수명 주기 관리 (build에서 등록, dispose에서 해제)
          final controller = Slidable.of(context);
          if (controller != null && controller != _slidableController) {
            _slidableController?.animation.removeListener(_handleRatioChange);
            _slidableController = controller;
            controller.animation.addListener(_handleRatioChange);
          }
          return _buildRoutineItemTile(context, widget.item, l10n);
        }),
      ),
    );
  }

  void _handleRatioChange() {
    final ratio = _slidableController?.ratio.abs() ?? 0.0;

    // 0.25 임계값 도달 시 햅틱 피드백 (딱 한 번만)
    if (ratio >= 0.25 && !_hapticTriggered) {
      HapticFeedback.mediumImpact();
      _hapticTriggered = true;
    }
    // 패널이 완전히 닫혔을 때 햅틱 트리거 리셋
    else if (ratio == 0 && _hapticTriggered) {
      _hapticTriggered = false;
    }
  }

  Widget _buildRoutineItemTile(
    BuildContext context,
    RoutineItem item,
    AppLocalizations l10n,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onLongPress: widget.onLongPress,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                // 단계 이름 탭 → 이름 수정 다이얼로그
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () =>
                        showEditStepNameDialog(context, ref, item, l10n),
                    child: Text(
                      L10nUtils.translate(context, item.name),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color:
                            isDarkMode ? Colors.white : const Color(0xFF1C1C1E),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ),
                // 시간 텍스트 탭 → 시간 수정 다이얼로그
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () =>
                      showEditStepDurationDialog(context, ref, item, l10n),
                  child: Text(
                    '${item.estimatedDuration.inMinutes}${l10n.minutes}',
                    style: TextStyle(
                      color:
                          isDarkMode ? Colors.white38 : const Color(0xFF8E8E93),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

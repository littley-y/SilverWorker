import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/font_size_provider.dart';
import '../../widgets/mascot_widget.dart';
import '../../widgets/primary_button.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontScale = ref.watch(fontSizeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정', style: AppTextStyles.headline),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Row(
                children: <Widget>[
                  Expanded(
                    child: SizedBox.shrink(),
                  ),
                  MascotWidget(size: 60),
                ],
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('글자 크기'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('작게', style: AppTextStyles.caption),
                        Text(
                          '${(fontScale * 100).toInt()}%',
                          style: AppTextStyles.bodyBold,
                        ),
                        Text('크게', style: AppTextStyles.caption),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: fontScale,
                      min: FontSizeNotifier.minScale,
                      max: FontSizeNotifier.maxScale,
                      divisions: 6,
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.primaryLight,
                      onChanged: (value) {
                        ref.read(fontSizeProvider.notifier).setScale(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '미리보기',
                            style: AppTextStyles.caption,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '안녕하세요, 은빛일자리입니다.',
                            style: AppTextStyles.body,
                          ),
                          Text(
                            '이 크기로 공고 내용이 표시됩니다.',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('앱 정보'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    _buildInfoRow('앱 이름', '6080은빛일자리'),
                    const Divider(height: 24),
                    _buildInfoRow('버전', '1.0.0'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: '설정 초기화',
                onPressed: () => _showResetDialog(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(text, style: AppTextStyles.title);
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(label, style: AppTextStyles.body),
        Text(value, style: AppTextStyles.bodyBold),
      ],
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('설정 초기화', style: AppTextStyles.title),
          content: const Text(
            '모든 설정을 기본값으로 되돌리시겠습니까?',
            style: AppTextStyles.body,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('취소', style: AppTextStyles.body),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await ref.read(fontSizeProvider.notifier).setScale(1.0);
              },
              child: Text(
                '초기화',
                style: AppTextStyles.body.copyWith(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }
}

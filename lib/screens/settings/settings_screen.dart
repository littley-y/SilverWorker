import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/font_size_provider.dart';
import '../../widgets/mascot_widget.dart';

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
                        Text('현재 설정', style: AppTextStyles.body),
                        Text(
                          '${(fontScale * 100).toInt()}%',
                          style: AppTextStyles.bodyBold.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '시니어 분들의 가독성을 위해 글자 크기는 130%로 고정되어 있습니다.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
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
              // Font scale is fixed at 130% — no reset needed
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
}

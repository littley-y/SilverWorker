import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/address_data.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../router/app_router.dart';

/// Profile setup screen — shown once after first successful phone auth.
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _careerController = TextEditingController();

  String? _selectedSido;
  String? _selectedSigungu;
  bool _isSaving = false;

  bool get _isFormValid {
    return _nameController.text.trim().isNotEmpty &&
        _selectedSido != null &&
        _selectedSigungu != null;
  }

  Future<void> _onStart() async {
    if (!_isFormValid) return;

    setState(() => _isSaving = true);

    final repository = ref.read(authRepositoryProvider);
    final user = repository.currentUser;
    final phoneNumber = ref.read(phoneNumberProvider);

    if (user == null) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '로그인 정보가 없습니다. 다시 시도해 주세요.',
              style: AppTextStyles.body,
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    try {
      await repository.createProfile(
        uid: user.uid,
        phoneNumber: phoneNumber.isEmpty ? user.phoneNumber ?? '' : phoneNumber,
        name: _nameController.text.trim(),
        sido: _selectedSido!,
        sigungu: _selectedSigungu!,
        careerSummary: _careerController.text.trim(),
      );

      // Invalidate cached profile so MainScreen fetches the new document.
      ref.invalidate(userProfileProvider(user.uid));

      if (mounted) {
        context.go(AppRoutes.main);
      }
    } on Exception catch (_) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '프로필 저장에 실패했습니다. 다시 시도해 주세요.',
              style: AppTextStyles.body,
            ),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: '재시도',
              textColor: Colors.white,
              onPressed: _onStart,
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _careerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authRepositoryProvider).currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(AppRoutes.phone);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final profileAsync = ref.watch(userProfileProvider(user.uid));

    return profileAsync.when(
      data: (profile) {
        if (profile != null) {
          // Profile already exists → redirect to main
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go(AppRoutes.main);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return _buildForm();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => _buildForm(),
    );
  }

  Widget _buildForm() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 60),
              Text(
                '프로필을 등록해 주세요',
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '일자리 추천에 사용됩니다.',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),

              // Name
              Text('이름', style: AppTextStyles.bodyBold),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: AppTextStyles.body,
                maxLength: 20,
                decoration: InputDecoration(
                  hintText: '이름을 입력하세요',
                  hintStyle: AppTextStyles.body.copyWith(
                    color: Colors.grey.shade400,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),

              // Address — Sido
              Text('거주 지역', style: AppTextStyles.bodyBold),
              const SizedBox(height: 8),
              InputDecorator(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSido,
                    hint: Text(
                      '시 / 도 선택',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.grey.shade400,
                      ),
                    ),
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    isExpanded: true,
                    items: AddressData.sidoList.map((String sido) {
                      return DropdownMenuItem<String>(
                        value: sido,
                        child: Text(sido, style: AppTextStyles.body),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedSido = value;
                        _selectedSigungu = null;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Address — Sigungu
              InputDecorator(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSigungu,
                    hint: Text(
                      '구 / 군 선택',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.grey.shade400,
                      ),
                    ),
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    isExpanded: true,
                    items: AddressData.sigunguList(_selectedSido ?? '')
                        .map((String sigungu) {
                      return DropdownMenuItem<String>(
                        value: sigungu,
                        child: Text(sigungu, style: AppTextStyles.body),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() => _selectedSigungu = value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Career summary
              Text('경력 소개 (선택)', style: AppTextStyles.bodyBold),
              const SizedBox(height: 8),
              TextField(
                controller: _careerController,
                style: AppTextStyles.body,
                maxLength: 500,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: '간단한 경력을 소개해 주세요 (최대 500자)',
                  hintStyle: AppTextStyles.body.copyWith(
                    color: Colors.grey.shade400,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_careerController.text.length} / 500',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_isFormValid && !_isSaving) ? _onStart : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: AppTextStyles.button,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('시작하기'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

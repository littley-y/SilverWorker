import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/primary_button.dart';

/// Phone number input screen — first step of authentication.
class PhoneInputScreen extends ConsumerStatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  ConsumerState<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends ConsumerState<PhoneInputScreen> {
  final _controller = TextEditingController();
  bool _hasError = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isValid {
    final digits = _controller.text.replaceAll(RegExp(r'\D'), '');
    return digits.length == 11 && digits.startsWith('010');
  }

  Future<void> _onSendCode() async {
    if (!_isValid) {
      setState(() => _hasError = true);
      return;
    }
    setState(() => _hasError = false);

    final digits = _controller.text.replaceAll(RegExp(r'\D'), '');
    // E.164 format for Korea: prepend +82
    final phoneNumber = '+82$digits';

    await ref.read(phoneAuthProvider.notifier).startVerification(phoneNumber);

    if (!mounted) return;

    final authState = ref.read(phoneAuthProvider);
    if (authState.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.errorMessage!, style: AppTextStyles.body),
          backgroundColor: AppColors.error,
        ),
      );
    } else if (authState.verificationId != null) {
      context.push(AppRoutes.otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(phoneAuthProvider).isLoading;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 80),
                Text(
                  '휴대폰 번호로 시작하세요',
                  style: AppTextStyles.headline.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        '+82',
                        style: AppTextStyles.bodyBold.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        keyboardType: TextInputType.phone,
                        style: AppTextStyles.body,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                        ],
                        decoration: InputDecoration(
                          hintText: '01012345678',
                          hintStyle: AppTextStyles.body.copyWith(
                            color: AppColors.hintText,
                          ),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _hasError
                                  ? AppColors.error
                                  : AppColors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _hasError
                                  ? AppColors.error
                                  : AppColors.border,
                            ),
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
                          errorText: _hasError ? '올바른 번호를 입력하세요' : null,
                          errorStyle: AppTextStyles.caption.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                        onChanged: (_) {
                          if (_hasError) setState(() => _hasError = false);
                        },
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                PrimaryButton(
                  label: '인증번호 받기',
                  onPressed: isLoading ? null : _onSendCode,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    '가입과 로그인에 모두 사용됩니다',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

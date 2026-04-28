import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';

/// OTP (6-digit SMS code) input screen.
class OtpInputScreen extends ConsumerStatefulWidget {
  const OtpInputScreen({super.key});

  @override
  ConsumerState<OtpInputScreen> createState() => _OtpInputScreenState();
}

class _OtpInputScreenState extends ConsumerState<OtpInputScreen> {
  final _focusNodes = List<FocusNode>.generate(6, (_) => FocusNode());
  final _controllers = List<TextEditingController>.generate(
    6,
    (_) => TextEditingController(),
  );

  int _countdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    setState(() {
      _countdown = 60;
      _canResend = false;
    });
    Future<void>.delayed(const Duration(seconds: 1), _tick);
  }

  void _tick() {
    if (!mounted) return;
    setState(() => _countdown--);
    if (_countdown > 0) {
      Future<void>.delayed(const Duration(seconds: 1), _tick);
    } else {
      setState(() => _canResend = true);
    }
  }

  String get _enteredCode {
    return _controllers.map((c) => c.text).join();
  }

  bool get _isComplete => _enteredCode.length == 6;

  void _onDigitChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  Future<void> _onVerify() async {
    if (!_isComplete) return;

    final user = await verifyOtp(
      ref: ref,
      smsCode: _enteredCode,
      onError: (String msg) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg, style: AppTextStyles.body),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
    );

    if (user != null && mounted) {
      // Navigation is handled by the router's redirect logic
      // based on authStateProvider and userProfileProvider.
      // We just pop back so the router can decide the destination.
      context.go('/');
    }
  }

  Future<void> _onResend() async {
    final phoneNumber = ref.read(phoneNumberProvider);
    if (phoneNumber.isEmpty) return;

    await startPhoneVerification(
      ref: ref,
      phoneNumber: phoneNumber,
      onError: (String msg) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg, style: AppTextStyles.body),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      onCodeSent: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '인증번호가 재발송되었습니다.',
                style: AppTextStyles.body,
              ),
              backgroundColor: AppColors.success,
            ),
          );
          _startCountdown();
        }
      },
    );
  }

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    for (final ctrl in _controllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authLoadingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 16),
              Text(
                '인증번호 6자리를 입력하세요',
                style: AppTextStyles.title.copyWith(
                  fontSize: 22,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List<Widget>.generate(6, (int index) {
                  return SizedBox(
                    width: 56,
                    height: 64,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.title.copyWith(
                        fontSize: 24,
                        color: AppColors.textPrimary,
                      ),
                      maxLength: 1,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        counterText: '',
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
                      ),
                      onChanged: (String value) =>
                          _onDigitChanged(index, value),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              Center(
                child: TextButton(
                  onPressed: (_canResend && !isLoading) ? _onResend : null,
                  child: Text(
                    _canResend ? '인증번호 재발송' : '$_countdown초 후 재발송 가능',
                    style: AppTextStyles.body.copyWith(
                      color: _canResend
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_isComplete && !isLoading) ? _onVerify : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: AppTextStyles.button,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('확인'),
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

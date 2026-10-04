import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/toast_notification.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? oobCode;

  const ResetPasswordScreen({super.key, this.oobCode});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _codeController = TextEditingController();

  String _password = '';
  String _confirmPassword = '';

  @override
  void initState() {
    super.initState();
    if (widget.oobCode != null) {
      _codeController.text = widget.oobCode!;
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  bool get _hasMinLength => _password.length >= 8;
  bool get _hasNumber => RegExp(r'\d').hasMatch(_password);
  bool get _hasSpecialChar => RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_password);
  bool get _passwordsMatch => _password.isNotEmpty && _password == _confirmPassword;

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_hasMinLength || !_hasNumber || !_hasSpecialChar) {
      ToastNotification.show(
        context,
        message: 'Please satisfy all password security requirements.',
        type: ToastType.warning,
      );
      return;
    }

    if (!_passwordsMatch) {
      ToastNotification.show(
        context,
        message: 'Passwords do not match.',
        type: ToastType.warning,
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.confirmPasswordReset(
      code: _codeController.text.trim(),
      newPassword: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      ToastNotification.show(
        context,
        message: 'Password reset successfully! Please sign in with your new password.',
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else if (authProvider.errorMessage != null) {
      ToastNotification.show(
        context,
        message: authProvider.errorMessage!,
        type: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AuthHeader(
                    title: 'Reset Password',
                    subtitle: 'Create a new secure password for your MoneyTrack account.',
                  ),
                  SizedBox(height: 28.h),

                  if (widget.oobCode == null) ...[
                    AuthTextField(
                      controller: _codeController,
                      label: 'Reset Code',
                      hint: 'Enter code from email',
                      prefixIcon: Icons.key_outlined,
                      enabled: !authProvider.isLoading,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Please enter reset code';
                        return null;
                      },
                    ),
                    SizedBox(height: 18.h),
                  ],

                  // New Password
                  AuthTextField(
                    controller: _passwordController,
                    label: 'New Password',
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outline_rounded,
                    isPassword: true,
                    enabled: !authProvider.isLoading,
                    onChanged: (val) => setState(() => _password = val),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Please enter a new password';
                      if (val.length < 8) return 'Password must be at least 8 characters';
                      return null;
                    },
                  ),
                  SizedBox(height: 18.h),

                  // Confirm Password
                  AuthTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm New Password',
                    hint: '••••••••',
                    prefixIcon: Icons.lock_reset_rounded,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    enabled: !authProvider.isLoading,
                    onChanged: (val) => setState(() => _confirmPassword = val),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Please confirm your new password';
                      if (val != _passwordController.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Requirements Card
                  if (_password.isNotEmpty) ...[
                    Container(
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Password Requirements:',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          _requirementRow('At least 8 characters long', _hasMinLength),
                          SizedBox(height: 4.h),
                          _requirementRow('Includes at least 1 number', _hasNumber),
                          SizedBox(height: 4.h),
                          _requirementRow('Includes at least 1 special character', _hasSpecialChar),
                          if (_confirmPassword.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            _requirementRow('Passwords match', _passwordsMatch),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 18.h),
                  ],

                  if (authProvider.errorMessage != null) ...[
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: AppColors.expense.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.expense.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline_rounded, color: AppColors.expense, size: 20.sp),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              authProvider.errorMessage!,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.expense,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18.h),
                  ],

                  SizedBox(height: 16.h),

                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _handleResetPassword,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: authProvider.isLoading
                          ? SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Save New Password',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _requirementRow(String text, bool isSatisfied) {
    return Row(
      children: [
        Icon(
          isSatisfied ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          size: 16.sp,
          color: isSatisfied ? AppColors.income : AppColors.warning,
        ),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            color: isSatisfied ? AppColors.income : Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: isSatisfied ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

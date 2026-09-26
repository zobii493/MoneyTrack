import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/toast_notification.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isChecking = false;
  bool _canResend = true;
  int _resendCountdown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _checkVerification());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkVerification() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);

    final isVerified = await FirebaseService.checkEmailVerified();
    if (!mounted) return;

    if (isVerified) {
      _timer?.cancel();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.updateProfile();
      if (mounted) {
        ToastNotification.show(context, message: 'Email verified successfully!');
      }
    } else {
      setState(() => _isChecking = false);
    }
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendCountdown = 30;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown == 0) {
        timer.cancel();
        if (mounted) setState(() => _canResend = true);
      } else if (mounted) {
        setState(() => _resendCountdown--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userEmail = authProvider.user?.email ?? FirebaseService.currentUser?.email ?? 'your email';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.expense),
            tooltip: 'Log Out',
            onPressed: () => authProvider.logout(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            children: [
              const Spacer(),

              Container(
                width: 90.w,
                height: 90.h,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mark_email_unread_rounded,
                  size: 48.sp,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 28.h),

              Text(
                'Verify Your Email Address',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 12.h),

              Text(
                'We sent a verification email link to:',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13.sp),
              ),
              SizedBox(height: 6.h),

              Text(
                userEmail,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 16.h),

              Text(
                'Please click the link in your inbox to verify your account and unlock MoneyTrack features.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12.sp),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isChecking ? null : _checkVerification,
                  icon: _isChecking
                      ? SizedBox(
                          width: 18.w,
                          height: 18.h,
                          child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Icon(Icons.check_circle_outline, size: 20.sp),
                  label: Text('I Have Verified My Email', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: !_canResend
                      ? null
                      : () async {
                          try {
                            await FirebaseService.sendEmailVerification();
                            _startResendTimer();
                            if (mounted) {
                              ToastNotification.show(context, message: 'Verification email resent!');
                            }
                          } catch (e) {
                            if (mounted) {
                              ToastNotification.show(context, message: 'Resend error: $e', type: ToastType.error);
                            }
                          }
                        },
                  icon: Icon(Icons.send_rounded, size: 18.sp),
                  label: Text(
                    _canResend ? 'Resend Verification Email' : 'Resend in ${_resendCountdown}s',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              TextButton(
                onPressed: () => authProvider.logout(),
                child: Text('Use Different Email / Log Out', style: TextStyle(fontSize: 13.sp, color: AppColors.expense)),
              ),

              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}

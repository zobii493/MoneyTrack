import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/toast_notification.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  bool _isSubmitting = false;

  String _selectedGoal = 'Track spending';
  String _selectedCurrency = 'USD';
  bool _enableNotifications = true;

  final List<String> _goals = [
    'Track spending',
    'Save money',
    'Control my budget',
    'Reduce expenses',
    'Manage multiple accounts',
  ];

  final List<Map<String, String>> _currencies = [
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
    {'code': 'PKR', 'symbol': 'Rs.', 'name': 'Pakistani Rupee'},
    {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
    {'code': 'AED', 'symbol': 'AED', 'name': 'UAE Dirham'},
    {'code': 'SAR', 'symbol': 'SAR', 'name': 'Saudi Riyal'},
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            children: [
              // Step Progress Bar
              Row(
                children: List.generate(5, (index) {
                  return Expanded(
                    child: Container(
                      height: 4.h,
                      margin: EdgeInsets.symmetric(horizontal: 2.w),
                      decoration: BoxDecoration(
                        color: index <= _currentStep ? AppColors.primary : AppColors.borderLight,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 24.h),

              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildStepContent(),
                ),
              ),
              SizedBox(height: 20.h),

              // Bottom Button Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    OutlinedButton(
                      onPressed: _isSubmitting ? null : () => setState(() => _currentStep--),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text('Back', style: TextStyle(fontSize: 14.sp)),
                    )
                  else
                    const SizedBox.shrink(),

                  ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            if (_currentStep < 4) {
                              setState(() => _currentStep++);
                            } else {
                              setState(() => _isSubmitting = true);
                              try {
                                await authProvider.completeOnboarding(
                                  _selectedGoal,
                                  _selectedCurrency,
                                  _enableNotifications,
                                );
                                if (context.mounted) {
                                  ToastNotification.show(context, message: 'Welcome to MoneyTrack!');
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ToastNotification.show(context, message: 'Onboarding error: $e', type: ToastType.error);
                                }
                              } finally {
                                if (mounted) setState(() => _isSubmitting = false);
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            width: 18.w,
                            height: 18.h,
                            child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            _currentStep == 4 ? 'Finish Setup' : 'Next',
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Column(
          key: const ValueKey(0),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.handshake_outlined, size: 54.sp, color: AppColors.primary),
            ),
            SizedBox(height: 24.h),
            Text(
              'Welcome to MoneyTrack',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              'Take control of your money with simple, powerful financial tracking.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14.sp),
              textAlign: TextAlign.center,
            ),
          ],
        );

      case 1:
        return Column(
          key: const ValueKey(1),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What is your primary goal?', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 22.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 6.h),
            Text('We will tailor your experience based on your choice.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13.sp)),
            SizedBox(height: 20.h),
            Expanded(
              child: ListView(
                children: _goals.map((g) {
                  final isSelected = _selectedGoal == g;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: ChoiceChip(
                      label: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: Text(
                          g,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.white : null,
                          ),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      onSelected: (val) => setState(() => _selectedGoal = g),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );

      case 2:
        return Column(
          key: const ValueKey(2),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose Preferred Currency', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 22.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 6.h),
            Text('Select the default currency for displaying financial balances.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13.sp)),
            SizedBox(height: 20.h),
            Expanded(
              child: ListView.builder(
                itemCount: _currencies.length,
                itemBuilder: (context, index) {
                  final item = _currencies[index];
                  final isSelected = _selectedCurrency == item['code'];
                  return Card(
                    color: isSelected ? AppColors.primary.withOpacity(0.12) : null,
                    margin: EdgeInsets.only(bottom: 8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : Theme.of(context).dividerColor,
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        radius: 16.r,
                        child: Text(item['symbol']!, style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                      ),
                      title: Text('${item['code']} - ${item['name']}', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                      trailing: isSelected ? Icon(Icons.check_circle, color: AppColors.primary, size: 20.sp) : null,
                      onTap: () => setState(() => _selectedCurrency = item['code']!),
                    ),
                  );
                },
              ),
            ),
          ],
        );

      case 3:
        return Column(
          key: const ValueKey(3),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_active_outlined, size: 54.sp, color: AppColors.primary),
            SizedBox(height: 24.h),
            Text('Stay On Budget Alerts', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 22.sp, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            SizedBox(height: 12.h),
            Text(
              'Get intelligent alerts when you approach budget thresholds or reach saving milestones.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28.h),
            SwitchListTile.adaptive(
              title: Text('Enable Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
              subtitle: Text('Receive weekly financial summaries and budget warnings.', style: TextStyle(fontSize: 12.sp)),
              value: _enableNotifications,
              activeColor: AppColors.primary,
              onChanged: (val) => setState(() => _enableNotifications = val),
            ),
          ],
        );

      case 4:
        return Column(
          key: const ValueKey(4),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, size: 54.sp, color: Colors.white),
            ),
            SizedBox(height: 24.h),
            Text("You're All Set!", style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 24.sp, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            SizedBox(height: 12.h),
            Text(
              "Your personalized MoneyTrack environment is ready. Let's start building your wealth.",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14.sp),
              textAlign: TextAlign.center,
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

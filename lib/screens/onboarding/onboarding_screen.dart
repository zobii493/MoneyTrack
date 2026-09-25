import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;

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
          padding: const EdgeInsets.all(28.0),
          child: Column(
            children: [
              // Step Progress Bar
              Row(
                children: List.generate(5, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: index <= _currentStep ? AppColors.primary : AppColors.borderLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildStepContent(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    OutlinedButton(
                      onPressed: () => setState(() => _currentStep--),
                      child: const Text('Back'),
                    )
                  else
                    const SizedBox.shrink(),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentStep < 4) {
                        setState(() => _currentStep++);
                      } else {
                        authProvider.completeOnboarding(
                          _selectedGoal,
                          _selectedCurrency,
                          _enableNotifications,
                        );
                      }
                    },
                    child: Text(_currentStep == 4 ? 'Finish Setup' : 'Next'),
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.handshake_outlined, size: 60, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text('Welcome to MoneyTrack', style: Theme.of(context).textTheme.headlineLarge, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              'Take control of your money with simple, powerful financial tracking.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        );
      case 1:
        return Column(
          key: const ValueKey(1),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What is your primary goal?', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text('We will tailor your experience based on your choice.', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            ..._goals.map((g) {
              final isSelected = _selectedGoal == g;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ChoiceChip(
                  label: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(g, style: const TextStyle(fontSize: 15)),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : null),
                  onSelected: (val) => setState(() => _selectedGoal = g),
                ),
              );
            }).toList(),
          ],
        );
      case 2:
        return Column(
          key: const ValueKey(2),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose Preferred Currency', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text('Select the default currency for displaying financial balances.', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: _currencies.length,
                itemBuilder: (context, index) {
                  final item = _currencies[index];
                  final isSelected = _selectedCurrency == item['code'];
                  return Card(
                    color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Text(item['symbol']!, style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text('${item['code']} - ${item['name']}'),
                      trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
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
            const Icon(Icons.notifications_active_outlined, size: 60, color: AppColors.primary),
            const SizedBox(height: 24),
            Text('Stay On Budget Alerts', style: Theme.of(context).textTheme.headlineLarge, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              'Get intelligent alerts when you approach budget thresholds or reach saving milestones.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SwitchListTile.adaptive(
              title: const Text('Enable Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Receive weekly financial summaries and budget warnings.'),
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
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text("You're All Set!", style: Theme.of(context).textTheme.headlineLarge, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              "Your personalized MoneyTrack environment is ready. Let's start building your wealth.",
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

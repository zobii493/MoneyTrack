import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/finance_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_card.dart';
import '../widgets/toast_notification.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final financeProvider = Provider.of<FinanceProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
            Text('Manage account preferences, theme, and data', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),

            // Profile Section
            Text('Account Profile', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            CustomCard(
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: user?.currency ?? 'USD',
                    decoration: const InputDecoration(
                      labelText: 'Default Currency',
                      prefixIcon: Icon(Icons.currency_exchange),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'USD', child: Text('USD - US Dollar (\$)')),
                      DropdownMenuItem(value: 'EUR', child: Text('EUR - Euro (€)')),
                      DropdownMenuItem(value: 'GBP', child: Text('GBP - British Pound (£)')),
                      DropdownMenuItem(value: 'PKR', child: Text('PKR - Pakistani Rupee (Rs.)')),
                      DropdownMenuItem(value: 'INR', child: Text('INR - Indian Rupee (₹)')),
                      DropdownMenuItem(value: 'AED', child: Text('AED - UAE Dirham')),
                      DropdownMenuItem(value: 'SAR', child: Text('SAR - Saudi Riyal')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        authProvider.updateProfile(currency: val);
                        ToastNotification.show(context, message: 'Currency preference updated');
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        authProvider.updateProfile(
                          name: _nameController.text.trim(),
                          email: _emailController.text.trim(),
                        );
                        ToastNotification.show(context, message: 'Profile details saved');
                      },
                      child: const Text('Save Profile'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Preferences & Theme Section
            Text('App Preferences', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            CustomCard(
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    title: const Text('Dark Theme'),
                    subtitle: const Text('Enable dark navy theme interface'),
                    value: themeProvider.isDarkMode,
                    activeColor: AppColors.primary,
                    onChanged: (val) => themeProvider.toggleTheme(val),
                  ),
                  const Divider(),
                  SwitchListTile.adaptive(
                    title: const Text('Push Notifications'),
                    subtitle: const Text('Receive budget alerts & monthly report reminders'),
                    value: user?.notificationsEnabled ?? true,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      authProvider.updateProfile(notificationsEnabled: val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Dashboard Customization Widgets (Section 34)
            Text('Dashboard Customization', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            CustomCard(
              child: Column(
                children: [
                  _widgetToggle(authProvider, 'balance', 'Total Balance Card'),
                  _widgetToggle(authProvider, 'summary', 'Financial Summary Cards'),
                  _widgetToggle(authProvider, 'spending_chart', 'Spending Overview Chart'),
                  _widgetToggle(authProvider, 'expense_breakdown', 'Expense Breakdown Donut Chart'),
                  _widgetToggle(authProvider, 'recent_transactions', 'Recent Transactions List'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Data & Reset Section
            Text('Data Management', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            CustomCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.refresh, color: AppColors.primary),
                    title: const Text('Reset to Demo Sample Data'),
                    subtitle: const Text('Reload initial realistic transactions, budgets, and goals'),
                    onTap: () async {
                      await financeProvider.resetToSampleData();
                      ToastNotification.show(context, message: 'Sample data restored!');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Danger Zone
            Text('Danger Zone', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.expense)),
            const SizedBox(height: 12),
            CustomCard(
              backgroundColor: AppColors.expense.withOpacity(0.05),
              border: Border.all(color: AppColors.expense.withOpacity(0.3)),
              child: ListTile(
                leading: const Icon(Icons.delete_forever, color: AppColors.expense),
                title: const Text('Delete Account & Clear Data', style: TextStyle(color: AppColors.expense, fontWeight: FontWeight.bold)),
                subtitle: const Text('Permanently remove all local transaction logs and settings'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (dialogCtx) => AlertDialog(
                      title: const Text('Delete Account & Reset?'),
                      content: const Text('This will clear all your saved financial records permanently.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogCtx),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogCtx);
                            authProvider.logout();
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense),
                          child: const Text('Delete All Data'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _widgetToggle(AuthProvider auth, String key, String title) {
    final currentMap = Map<String, bool>.from(auth.user?.dashboardWidgets ?? {});
    final isEnabled = currentMap[key] ?? true;

    return SwitchListTile.adaptive(
      title: Text(title),
      value: isEnabled,
      activeColor: AppColors.primary,
      onChanged: (val) {
        currentMap[key] = val;
        auth.updateProfile(dashboardWidgets: currentMap);
      },
    );
  }
}

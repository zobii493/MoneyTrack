import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import '../widgets/mobile_bottom_nav.dart';
import '../widgets/navigation_sidebar.dart';
import 'accounts_screen.dart';
import 'analytics_screen.dart';
import 'budgets_screen.dart';
import 'categories_screen.dart';
import 'dashboard_screen.dart';
import 'goals_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import 'transactions_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _titles = [
    'Dashboard',
    'Transactions',
    'Budgets',
    'Analytics',
    'Goals',
    'Accounts',
    'Categories',
    'Reports',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 850;

    final List<Widget> pages = [
      DashboardScreen(
        onViewAllTransactions: () {
          setState(() => _selectedIndex = 1);
        },
      ),
      const TransactionsScreen(),
      const BudgetsScreen(),
      const AnalyticsScreen(),
      const GoalsScreen(),
      const AccountsScreen(),
      const CategoriesScreen(),
      const ReportsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: !isDesktop
          ? Drawer(
              child: NavigationSidebar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (idx) {
                  setState(() => _selectedIndex = idx);
                  Navigator.pop(context); // close drawer
                },
              ),
            )
          : null,
      body: Row(
        children: [
          if (isDesktop)
            NavigationSidebar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (idx) {
                setState(() => _selectedIndex = idx);
              },
            ),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: _titles[_selectedIndex],
                  onOpenDrawer: !isDesktop
                      ? () => _scaffoldKey.currentState?.openDrawer()
                      : null,
                ),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: pages,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isDesktop
          ? MobileBottomNav(
              currentIndex: _selectedIndex,
              onTap: (idx) {
                setState(() => _selectedIndex = idx);
              },
            )
          : null,
    );
  }
}

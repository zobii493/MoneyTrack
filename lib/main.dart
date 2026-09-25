import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/finance_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/main_layout.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MoneyTrackApp());
}

class MoneyTrackApp extends StatelessWidget {
  const MoneyTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FinanceProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return MaterialApp(
                title: 'MoneyTrack',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme(),
                darkTheme: AppTheme.darkTheme(),
                themeMode: themeProvider.themeMode,
                home: Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    if (authProvider.isLoading) {
                      return const Scaffold(
                        body: Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                      );
                    }

                    if (!authProvider.isLoggedIn) {
                      return const WelcomeScreen();
                    }

                    if (!authProvider.isOnboarded) {
                      return const OnboardingScreen();
                    }

                    return const MainLayout();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

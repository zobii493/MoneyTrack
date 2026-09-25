import 'package:flutter/material.dart';
export 'package:flutter_screenutil/flutter_screenutil.dart';

class ScreenUtilHelper {
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;

  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < mobileBreakpoint;
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;
  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= tabletBreakpoint;

  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (ScreenUtilHelper.isDesktop(context)) {
      return desktop;
    }
    if (ScreenUtilHelper.isTablet(context)) {
      return tablet ?? mobile;
    }
    return mobile;
  }
}

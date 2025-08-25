import 'package:flutter/material.dart';

class ResponsiveUtils {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768 && 
           MediaQuery.of(context).size.width < 1024;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  // Responsive horizontal padding
  static EdgeInsets getResponsiveHorizontalPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 20.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 40.0);
    } else {
      return const EdgeInsets.symmetric(horizontal: 80.0);
    }
  }

  // Responsive font sizes
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    if (isMobile(context)) {
      return baseFontSize;
    } else if (isTablet(context)) {
      return baseFontSize * 1.1;
    } else {
      return baseFontSize * 1.2;
    }
  }

  // Responsive card width
  static double getCardWidth(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    if (isMobile(context)) {
      return screenWidth - 40; // Full width with padding
    } else if (isTablet(context)) {
      return screenWidth * 0.8; // 80% of screen width
    } else {
      return 600; // Fixed width for desktop
    }
  }

  // Responsive grid columns
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 3;
    }
  }

  // Responsive spacing
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    if (isMobile(context)) {
      return baseSpacing;
    } else if (isTablet(context)) {
      return baseSpacing * 1.2;
    } else {
      return baseSpacing * 1.5;
    }
  }

  // Get maximum content width for better readability on large screens
  static double getMaxContentWidth(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    if (isDesktop(context)) {
      return screenWidth > 1200 ? 1200 : screenWidth * 0.9;
    }
    return screenWidth;
  }

  // Responsive container constraints
  static BoxConstraints getResponsiveConstraints(BuildContext context) {
    final maxWidth = getMaxContentWidth(context);
    return BoxConstraints(
      maxWidth: maxWidth,
      minHeight: getScreenHeight(context),
    );
  }
}

// Text styles with Inter font and responsive sizing
class AppTextStyles {
  static TextStyle heading1(BuildContext context) {
    return TextStyle(
      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 32),
      fontWeight: FontWeight.w700,
      color: const Color(0xFF1A1A1A),
      height: 1.2,
    );
  }

  static TextStyle heading2(BuildContext context) {
    return TextStyle(
      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 28),
      fontWeight: FontWeight.w600,
      color: const Color(0xFF1A1A1A),
      height: 1.3,
    );
  }

  static TextStyle heading3(BuildContext context) {
    return TextStyle(
      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 24),
      fontWeight: FontWeight.w600,
      color: const Color(0xFF1A1A1A),
      height: 1.3,
    );
  }

  static TextStyle heading4(BuildContext context) {
    return TextStyle(
      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
      fontWeight: FontWeight.w600,
      color: const Color(0xFF1A1A1A),
      height: 1.4,
    );
  }

  static TextStyle bodyLarge(BuildContext context) {
    return TextStyle(
      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
      fontWeight: FontWeight.w400,
      color: const Color(0xFF1A1A1A),
      height: 1.5,
    );
  }

  static TextStyle bodyMedium(BuildContext context) {
    return TextStyle(
      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
      fontWeight: FontWeight.w400,
      color: const Color(0xFF1A1A1A),
      height: 1.5,
    );
  }

  static TextStyle bodySmall(BuildContext context) {
    return TextStyle(
      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
      fontWeight: FontWeight.w400,
      color: const Color(0xFF6B7280),
      height: 1.4,
    );
  }

  static TextStyle button(BuildContext context) {
    return TextStyle(
      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
      fontWeight: FontWeight.w600,
      height: 1.2,
    );
  }

  static TextStyle caption(BuildContext context) {
    return TextStyle(
      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
      fontWeight: FontWeight.w500,
      color: const Color(0xFF6B7280),
      height: 1.3,
    );
  }
}

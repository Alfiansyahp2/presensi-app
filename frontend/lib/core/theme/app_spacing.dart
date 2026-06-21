import 'package:flutter/material.dart';

/// 📐 Spacing & Layout System
///
/// Sistem spacing yang konsisten untuk layout yang harmonis
/// Menggunakan 8px base unit (Material Design 3)
///
/// Context: Aplikasi Presensi Sekolah Premium 2025-2026
class AppSpacing {
  // =============================================
  // BASE SPACING UNIT - 8px Grid
  // =============================================

  static const double baseUnit = 8.0;

  // =============================================
  // SPACING SCALE
  // =============================================

  /// 0px - No spacing
  static const double zero = 0.0;

  /// 4px - Extra tight spacing
  static const double xxxs = 4.0;

  /// 8px - Extra small spacing
  static const double xxs = 8.0;

  /// 12px - Small spacing
  static const double xs = 12.0;

  /// 16px - Regular spacing
  static const double sm = 16.0;

  /// 24px - Medium spacing
  static const double md = 24.0;

  /// 32px - Large spacing
  static const double lg = 32.0;

  /// 48px - Extra large spacing
  static const double xl = 48.0;

  /// 64px - Extra extra large spacing
  static const double xxl = 64.0;

  /// 96px - Huge spacing
  static const double xxxl = 96.0;

  // =============================================
  // PADDING
  // =============================================

  /// Padding untuk compact cards
  static const EdgeInsets paddingXS = EdgeInsets.all(xxs);
  static const EdgeInsets paddingSM = EdgeInsets.all(xs);
  static const EdgeInsets paddingMD = EdgeInsets.all(sm);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  /// Horizontal padding
  static const EdgeInsets paddingHSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHLG = EdgeInsets.symmetric(horizontal: lg);

  /// Vertical padding
  static const EdgeInsets paddingVSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVLG = EdgeInsets.symmetric(vertical: lg);

  /// Asymmetric padding
  static const EdgeInsets paddingCard = EdgeInsets.fromLTRB(
    md,
    md,
    md,
    lg,
  );

  static const EdgeInsets paddingSection = EdgeInsets.fromLTRB(
    sm,
    lg,
    sm,
    xl,
  );

  // =============================================
  // MARGIN
  // =============================================

  /// Margin untuk spacing antar elements
  static const EdgeInsets marginXS = EdgeInsets.all(xxs);
  static const EdgeInsets marginSM = EdgeInsets.all(xs);
  static const EdgeInsets marginMD = EdgeInsets.all(sm);
  static const EdgeInsets marginLG = EdgeInsets.all(lg);

  /// Horizontal margin
  static const EdgeInsets marginHSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets marginHMD = EdgeInsets.symmetric(horizontal: md);

  /// Vertical margin
  static const EdgeInsets marginVSM = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets marginVMD = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets marginVLG = EdgeInsets.symmetric(vertical: lg);

  // =============================================
  // GAPS - Spacing antar items di row/column
  // =============================================

  static const SizedBox gapXXS = SizedBox(width: xxxs, height: xxxs);
  static const SizedBox gapXS = SizedBox(width: xxs, height: xxs);
  static const SizedBox gapSM = SizedBox(width: xs, height: xs);
  static const SizedBox gapMD = SizedBox(width: sm, height: sm);
  static const SizedBox gapLG = SizedBox(width: lg, height: lg);
  static const SizedBox gapXL = SizedBox(width: xl, height: xl);
  static const SizedBox gapXXL = SizedBox(width: xxl, height: xxl);

  // =============================================
  // INSETS - Safe area insets
  // =============================================

  static const EdgeInsets insetSM = EdgeInsets.all(sm);
  static const EdgeInsets insetMD = EdgeInsets.all(md);
  static const EdgeInsets insetLG = EdgeInsets.all(lg);

  // =============================================
  // BORDER RADIUS
  // =============================================

  /// Radius untuk rounded corners
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusXXXL = 28.0;

  /// BorderRadius objects
  static const BorderRadius borderRadiusSM = BorderRadius.all(
    Radius.circular(radiusSM),
  );
  static const BorderRadius borderRadiusMD = BorderRadius.all(
    Radius.circular(radiusMD),
  );
  static const BorderRadius borderRadiusLG = BorderRadius.all(
    Radius.circular(radiusLG),
  );
  static const BorderRadius borderRadiusXL = BorderRadius.all(
    Radius.circular(radiusXL),
  );
  static const BorderRadius borderRadiusXXL = BorderRadius.all(
    Radius.circular(radiusXXL),
  );

  /// Circular border radius (untuk badge, avatar circle)
  static const double radiusCircle = 999.0;

  // =============================================
  // RESPONSIVE SPACING
  // =============================================

  /// Get spacing based on screen width
  static double getResponsiveSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return sm; // Mobile
    } else if (width < 900) {
      return md; // Tablet
    } else {
      return lg; // Desktop
    }
  }

  /// Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final spacing = getResponsiveSpacing(context);
    return EdgeInsets.all(spacing);
  }

  /// Get responsive gap
  static SizedBox getResponsiveGap(BuildContext context) {
    return SizedBox(
      width: getResponsiveSpacing(context),
      height: getResponsiveSpacing(context),
    );
  }

  // =============================================
  // CARD SPACING
  // =============================================

  /// Padding untuk cards dengan shadow
  static const EdgeInsets cardPadding = EdgeInsets.all(md);

  /// Margin untuk cards
  static const EdgeInsets cardMargin = EdgeInsets.all(sm);

  /// Padding untuk compact cards
  static const EdgeInsets compactCardPadding = EdgeInsets.all(sm);

  // =============================================
  // LIST SPACING
  // =============================================

  /// Padding untuk list items
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// Gap antar list items
  static const SizedBox listItemGap = gapSM;

  // =============================================
  // BUTTON SPACING
  // =============================================

  /// Padding untuk primary buttons
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  /// Padding untuk small buttons
  static const EdgeInsets buttonSmallPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  // =============================================
  // INPUT FIELD SPACING
  // =============================================

  /// Padding untuk input fields
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// Gap antar input fields
  static const SizedBox inputGap = gapSM;

  // =============================================
  // UTILITIES
  // =============================================

  /// Create custom EdgeInsets
  static EdgeInsets all(double value) => EdgeInsets.all(value);

  static EdgeInsets symmetric({
    double horizontal = 0.0,
    double vertical = 0.0,
  }) =>
      EdgeInsets.symmetric(
        horizontal: horizontal,
        vertical: vertical,
      );

  static EdgeInsets only({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) =>
      EdgeInsets.only(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      );

  /// Calculate spacing based on multiplier
  static double spacing(int multiplier) => baseUnit * multiplier;
}

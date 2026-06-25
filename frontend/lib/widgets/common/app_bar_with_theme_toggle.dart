import 'package:flutter/material.dart';
import 'theme_toggle_button.dart';

/// Reusable AppBar dengan Theme Toggle Button
///
/// Fitur:
/// - Tombol theme di pojok kiri atas (leading)
/// - Title di tengah
/// - Optional actions di kanan
/// - Sync theme di semua screen
class AppBarWithThemeToggle extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final Widget? leading;
  final Color? backgroundColor;

  const AppBarWithThemeToggle({
    super.key,
    required this.title,
    this.actions,
    this.automaticallyImplyLeading = false,
    this.leading,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: 0,
      // Tombol theme di pojok kiri atas (leading position)
      leading: leading ?? const ThemeToggleButton(),
      automaticallyImplyLeading: automaticallyImplyLeading,
      // Tombol tambahan di pojok kanan (opsional)
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

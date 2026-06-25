import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../utils/shared_storage.dart';
import '../route_guards.dart';

/// BottomNavHandler - Handle bottom navigation untuk semua role
///
/// Features:
/// - Different navigation items per role
/// - Auto-routing based on role
/// - Active state management
/// - Theme support
class BottomNavHandler extends StatefulWidget {
  final String currentRole;
  final bool isDarkMode;

  const BottomNavHandler({
    super.key,
    required this.currentRole,
    this.isDarkMode = false,
  });

  @override
  State<BottomNavHandler> createState() => _BottomNavHandlerState();
}

class _BottomNavHandlerState extends State<BottomNavHandler> {
  int _currentIndex = 0;
  late List<NavItem> _navItems;

  @override
  void initState() {
    super.initState();
    _navItems = _getNavItemsForRole(widget.currentRole);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update current index when dependencies change
    // This is called after initState and when inherited widgets change
    _updateCurrentIndexFromRoute();
  }

  void _updateCurrentIndexFromRoute() {
    // Get current route name
    final currentRoute = ModalRoute.of(context)?.settings.name;

    // Find index matching current route
    for (int i = 0; i < _navItems.length; i++) {
      if (_navItems[i].route == currentRoute) {
        if (_currentIndex != i) {
          setState(() {
            _currentIndex = i;
          });
        }
        break;
      }
    }
  }

  @override
  void didUpdateWidget(BottomNavHandler oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRole != widget.currentRole) {
      setState(() {
        _navItems = _getNavItemsForRole(widget.currentRole);
        _currentIndex = 0;
      });
    }
  }

  List<NavItem> _getNavItemsForRole(String role) {
    switch (role) {
      case 'TEACHER':
        return [
          NavItem(
            icon: Icons.dashboard,
            label: 'Dashboard',
            route: '/teacher/dashboard',
          ),
          NavItem(
            icon: Icons.people,
            label: 'Siswa',
            route: '/teacher/students',
          ),
          NavItem(
            icon: Icons.approval,
            label: 'Persetujuan',
            route: '/teacher/approvals',
          ),
          NavItem(
            icon: Icons.person,
            label: 'Profil',
            route: '/profile',
          ),
        ];

      case 'SCHOOL_ADMIN':
        return [
          NavItem(
            icon: Icons.dashboard,
            label: 'Dashboard',
            route: '/school-admin/dashboard',
          ),
          NavItem(
            icon: Icons.people,
            label: 'Users',
            route: '/school-admin/users',
          ),
          NavItem(
            icon: Icons.school,
            label: 'Sekolah',
            route: '/school-admin/school-settings',
          ),
          NavItem(
            icon: Icons.assessment,
            label: 'Laporan',
            route: '/school-admin/reports',
          ),
          NavItem(
            icon: Icons.person,
            label: 'Profil',
            route: '/profile',
          ),
        ];

      case 'SUPER_ADMIN':
        return [
          NavItem(
            icon: Icons.dashboard,
            label: 'Dashboard',
            route: '/super-admin/dashboard',
          ),
          NavItem(
            icon: Icons.school,
            label: 'Sekolah',
            route: '/super-admin/schools',
          ),
          NavItem(
            icon: Icons.people,
            label: 'Users',
            route: '/super-admin/users',
          ),
          NavItem(
            icon: Icons.person,
            label: 'Profil',
            route: '/profile',
          ),
        ];

      case 'STUDENT':
      default:
        return [
          NavItem(
            icon: Icons.home,
            label: 'Beranda',
            route: '/home',
          ),
          NavItem(
            icon: Icons.history,
            label: 'Riwayat',
            route: '/history',
          ),
          NavItem(
            icon: Icons.person,
            label: 'Profil',
            route: '/profile',
          ),
        ];
    }
  }

  Future<void> _onItemTapped(NavItem item, int index) async {
    // Update current index
    setState(() {
      _currentIndex = index;
    });

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Check if user is still authenticated
    final userData = await SharedStorage.getUserData();
    if (userData == null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    // Navigate to route
    if (item.route != null && mounted) {
      // Check if we're already on this route
      final currentRoute = ModalRoute.of(context)?.settings.name;

      if (currentRoute == item.route) {
        // Already on this route, don't navigate
        return;
      }

      // Navigate to the route
      Navigator.pushReplacementNamed(context, item.route!);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Update current index based on current route
    _updateCurrentIndexFromRoute();

    return Container(
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? AppColors.darkSurface.withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => _onItemTapped(_navItems[index], index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: widget.isDarkMode
            ? AppColors.darkAccent
            : AppColors.formalNavy,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
        ),
        items: _navItems
            .map(
              (item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

/// NavItem - Model untuk navigation item
class NavItem {
  final IconData icon;
  final String label;
  final String? route;

  const NavItem({
    required this.icon,
    required this.label,
    this.route,
  });
}

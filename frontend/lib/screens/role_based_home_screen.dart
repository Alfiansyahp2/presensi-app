import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../screens/home_screen.dart';
import '../screens/teacher/teacher_dashboard_screen.dart';
import '../screens/school_admin/school_admin_dashboard_screen.dart';
import '../screens/super_admin/super_admin_dashboard_screen.dart';

/// RoleBasedHomeScreen - Central routing based on user role
///
/// Screen ini mengecek role user dan mengarahkan ke dashboard yang sesuai:
/// - STUDENT → StudentHomeScreen (HomeScreen)
/// - TEACHER → TeacherDashboardScreen
/// - SCHOOL_ADMIN → SchoolAdminDashboardScreen
/// - SUPER_ADMIN → SuperAdminDashboardScreen
class RoleBasedHomeScreen extends StatefulWidget {
  const RoleBasedHomeScreen({super.key});

  @override
  State<RoleBasedHomeScreen> createState() => _RoleBasedHomeScreenState();
}

class _RoleBasedHomeScreenState extends State<RoleBasedHomeScreen> {
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataStr = prefs.getString('user_data');

    if (userDataStr != null && mounted) {
      final userData = Map<String, dynamic>.from(
        json.decode(userDataStr) as Map,
      );
      setState(() {
        _currentUser = UserModel.fromJson(userData);
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (_currentUser == null) {
      // User tidak login - redirect ke login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return const SizedBox.shrink();
    }

    // Arahkan ke screen berdasarkan role
    final user = _currentUser!;

    switch (user.role) {
      case 'STUDENT':
        return const HomeScreen();

      case 'TEACHER':
        return const TeacherDashboardScreen();

      case 'SCHOOL_ADMIN':
        return const SchoolAdminDashboardScreen();

      case 'SUPER_ADMIN':
        return const SuperAdminDashboardScreen();

      default:
        // Fallback untuk role tidak dikenal
        return _buildUnknownRoleScreen(user);
    }
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildUnknownRoleScreen(UserModel user) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unknown Role'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            const Text(
              'Role Tidak Dikenal',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Role: ${user.role}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            const Text(
              'Silakan hubungi administrator',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

/// RoleBasedNavigation - Bottom navigation bar berdasarkan role
///
/// Widget ini menyediakan navigation bar yang berbeda untuk setiap role
class RoleBasedNavigation extends StatelessWidget {
  final UserModel user;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const RoleBasedNavigation({
    super.key,
    required this.user,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (user.role) {
      case 'STUDENT':
        return _StudentNavigation(
          currentIndex: currentIndex,
          onTap: onTap,
        );

      case 'TEACHER':
        return _TeacherNavigation(
          currentIndex: currentIndex,
          onTap: onTap,
        );

      case 'SCHOOL_ADMIN':
        return _SchoolAdminNavigation(
          currentIndex: currentIndex,
          onTap: onTap,
        );

      case 'SUPER_ADMIN':
        return _SuperAdminNavigation(
          currentIndex: currentIndex,
          onTap: onTap,
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

/// Student Navigation (3 items)
class _StudentNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _StudentNavigation({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Riwayat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}

/// Teacher Navigation (4 items)
class _TeacherNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _TeacherNavigation({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Siswa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.approval),
          label: 'Persetujuan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}

/// School Admin Navigation (5 items)
class _SchoolAdminNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _SchoolAdminNavigation({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Users',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Sekolah',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assessment),
          label: 'Laporan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}

/// Super Admin Navigation (4 items)
class _SuperAdminNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _SuperAdminNavigation({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          label: 'Sekolah',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Users',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}

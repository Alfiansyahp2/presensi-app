import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../screens/login_screen.dart';

/// AuthGuard - Proteksi routes berdasarkan authentication dan role
///
/// Widget ini mengecek:
/// 1. Apakah user sudah login?
/// 2. Apakah account aktif?
/// 3. Apakah user memiliki role yang sesuai?
class AuthGuard extends StatelessWidget {
  final Widget child;
  final List<String> allowedRoles;
  final bool requireActive;

  const AuthGuard({
    super.key,
    required this.child,
    this.allowedRoles = const [],
    this.requireActive = true,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Load user from SharedStorage
    // Untuk sekarang, return child dulu
    // Nanti kita akan integrate dengan actual user data

    return FutureBuilder<Map<String, dynamic>?>(
      future: _loadUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }

        final userData = snapshot.data;

        // 1. Not logged in
        if (userData == null) {
          return const LoginScreen();
        }

        // Parse user model
        final user = UserModel.fromJson(userData);

        // 2. Check account status
        if (requireActive) {
          if (user.isSuspended) {
            return _buildSuspendedScreen(user);
          }

          if (user.isPending && user.isStudent) {
            return _buildPendingScreen(user);
          }
        }

        // 3. Check role authorization
        if (allowedRoles.isNotEmpty && !allowedRoles.contains(user.role)) {
          return _buildUnauthorizedScreen(user);
        }

        // All checks passed - show the protected content
        return child;
      },
    );
  }

  Future<Map<String, dynamic>?> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataStr = prefs.getString('user_data');
    if (userDataStr != null) {
      return Map<String, dynamic>.from(
        json.decode(userDataStr) as Map
      );
    }
    return null;
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildUnauthorizedScreen(UserModel user) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unauthorized')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            const Text(
              'Akses Ditolak',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Anda login sebagai ${user.displayName}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            const Text(
              'Role ini tidak memiliki akses ke halaman ini',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuspendedScreen(UserModel user) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Suspended'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.block,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            const Text(
              'Akun Ditangguhkan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Hai ${user.fullname},',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            const Text(
              'Akun Anda telah ditangguhkan. Silakan hubungi administrator sekolah.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            Builder(
              builder: (btnContext) => ElevatedButton.icon(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  // Navigate back to login
                  if (btnContext.mounted) {
                    Navigator.of(btnContext).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Keluar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingScreen(UserModel user) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Pending'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.pending,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            const Text(
              'Akun Menunggu Persetujuan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Hai ${user.fullname},',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            const Text(
              'Akun Anda sedang menunggu persetujuan dari administrator sekolah. Anda akan menerima notifikasi ketika akun telah disetujui.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            Builder(
              builder: (btnContext) => ElevatedButton.icon(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  if (btnContext.mounted) {
                    Navigator.of(btnContext).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Keluar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// RoleGuard - Proteksi route berdasarkan role tertentu
///
/// Usage:
/// ```dart
/// RoleGuard(
///   allowedRoles: ['TEACHER', 'SCHOOL_ADMIN'],
///   child: TeacherDashboard(),
/// )
/// ```
class RoleGuard extends StatelessWidget {
  final Widget child;
  final List<String> allowedRoles;

  const RoleGuard({
    super.key,
    required this.child,
    required this.allowedRoles,
  });

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      allowedRoles: allowedRoles,
      child: child,
    );
  }
}

/// PermissionGuard - Proteksi berdasarkan permission
///
/// Usage:
/// ```dart
/// PermissionGuard(
///   requiredPermissions: ['attendance.approve'],
///   child: ApprovalScreen(),
/// )
/// ```
class PermissionGuard extends StatelessWidget {
  final Widget child;
  final List<String> requiredPermissions;
  final bool requireAll;

  const PermissionGuard({
    super.key,
    required this.child,
    required this.requiredPermissions,
    this.requireAll = false,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _loadUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }

        final userData = snapshot.data;
        if (userData == null) {
          return const LoginScreen();
        }

        final user = UserModel.fromJson(userData);

        // Check permissions
        final hasPermission = requireAll
            ? user.hasAllPermissions(requiredPermissions)
            : user.hasAnyPermission(requiredPermissions);

        if (!hasPermission) {
          return _buildUnauthorizedScreen(user);
        }

        return child;
      },
    );
  }

  Future<Map<String, dynamic>?> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataStr = prefs.getString('user_data');
    if (userDataStr != null) {
      return Map<String, dynamic>.from(
        json.decode(userDataStr) as Map
      );
    }
    return null;
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildUnauthorizedScreen(UserModel user) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unauthorized')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            const Text(
              'Permission Required',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Anda tidak memiliki permission yang cukup',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuspendedScreen(UserModel user) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Suspended'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.block,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            const Text(
              'Akun Ditangguhkan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Hai ${user.fullname},',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            const Text(
              'Akun Anda telah ditangguhkan. Silakan hubungi administrator sekolah.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            Builder(
              builder: (btnContext) => ElevatedButton.icon(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  // Navigate back to login
                  if (btnContext.mounted) {
                    Navigator.of(btnContext).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Keluar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingScreen(UserModel user) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Pending'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.pending,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            const Text(
              'Akun Menunggu Persetujuan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Hai ${user.fullname},',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            const Text(
              'Akun Anda sedang menunggu persetujuan dari administrator sekolah. Anda akan menerima notifikasi ketika akun telah disetujui.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            Builder(
              builder: (btnContext) => ElevatedButton.icon(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  if (btnContext.mounted) {
                    Navigator.of(btnContext).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Keluar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/history_screen.dart';
import 'screens/role_based_home_screen.dart';
import 'providers/theme_provider.dart';
// 🆕 School Admin Screens
import 'screens/school_admin/school_admin_dashboard_screen.dart';
import 'screens/school_admin/school_admin_users_screen.dart';
import 'screens/school_admin/school_admin_settings_screen.dart';
import 'screens/school_admin/school_admin_reports_screen.dart';
// 🆕 Super Admin Screens
import 'screens/super_admin/super_admin_dashboard_screen.dart';
import 'screens/super_admin/super_admin_schools_screen.dart';
import 'screens/super_admin/super_admin_users_screen.dart';
// 🆕 Teacher Dashboard
import 'screens/teacher/teacher_dashboard_screen.dart';

void main() async {
  // Load environment variables
  await dotenv.load(fileName: ".env");

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Absensi SMK - RBAC System',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 2,
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            appBarTheme: AppBarTheme(
              centerTitle: true,
              elevation: 2,
              backgroundColor: Colors.grey[900],
            ),
          ),
          // Sync theme mode dengan ThemeProvider
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/login', // Halaman pertama yang dibuka
          routes: {
            // 🆕 Authentication
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),

            // 🆕 Student Routes (Legacy)
            '/home': (context) => const HomeScreen(),
            '/history': (context) => const HistoryScreen(),
            '/profile': (context) => const ProfileScreen(),

            // 🆕 Role-Based Home (Auto-routing)
            '/role-home': (context) => const RoleBasedHomeScreen(),

            // 🆕 School Admin Routes
            '/school-admin/dashboard': (context) => const SchoolAdminDashboardScreen(),
            '/school-admin/users': (context) => const SchoolAdminUsersScreen(),
            '/school-admin/school-settings': (context) => const SchoolAdminSettingsScreen(),
            '/school-admin/reports': (context) => const SchoolAdminReportsScreen(),

            // 🆕 Super Admin Routes
            '/super-admin/dashboard': (context) => const SuperAdminDashboardScreen(),
            '/super-admin/schools': (context) => const SuperAdminSchoolsScreen(),
            '/super-admin/users': (context) => const SuperAdminUsersScreen(),

            // 🆕 Teacher Routes
            '/teacher/dashboard': (context) => const TeacherDashboardScreen(),
            // TODO: Add more teacher routes as needed
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

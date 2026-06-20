import 'package:flutter/material.dart';
import 'package:flutter_absensi/screens/history_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  // Load environment variables
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Absensi SMK',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue, // Warna utama biru (bisa diganti)
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
        ),
      ),
      initialRoute: '/login', // Halaman pertama yang dibuka
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) =>  RegisterScreen(),
        '/home': (context) =>  HomeScreen(),
        '/profile': (context) =>  ProfileScreen(),
        '/history': (context) =>  HistoryScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/user/screens/user_list_screen.dart';
import 'features/siswa/screens/siswa_list_screen.dart';
import 'features/attendance/screens/attendance_list_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Absensi RFID',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B82F6)),
        fontFamily: 'Poppins',
      ),
      initialRoute: '/', // Mulai dari login
      routes: {
        '/': (context) => LoginScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/siswa': (context) => SiswaListScreen(),
        '/users': (context) => UserListScreen(),
        '/attendance': (context) => AttendanceListScreen(),
      },
      // Optional: Jika ingin handle route lainnya
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => LoginScreen(),
        );
      },
    );
  }
}

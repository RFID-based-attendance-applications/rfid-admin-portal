import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/attendance/screens/attendance_list_screen.dart';
import '../features/siswa/screens/siswa_list_screen.dart';
import '../features/user/screens/user_list_screen.dart';
import '../features/splash/splash_screen.dart';
import '../providers/app_provider.dart';
import '../../core/constants/app_routes.dart';

class AppRouter {
  GoRouter get router => _router;

  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.namedSplash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.namedLogin,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: AppRoutes.namedDashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.attendance,
        name: AppRoutes.namedAttendance,
        builder: (context, state) => const AttendanceListScreen(),
      ),
      GoRoute(
        path: AppRoutes.siswa,
        name: AppRoutes.namedSiswa,
        builder: (context, state) => const SiswaListScreen(),
      ),
      GoRoute(
        path: AppRoutes.users,
        name: AppRoutes.namedUsers,
        builder: (context, state) => const UserListScreen(),
      ),
    ],
  );
}

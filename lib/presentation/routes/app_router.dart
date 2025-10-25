import 'package:admin_absensi_hasbi/presentation/features/screens/libur_list_screen.dart';
import 'package:go_router/go_router.dart';
import '../features/screens/login_screen.dart';
import '../features/screens/dashboard_screen.dart';
import '../features/screens/attendance_list_screen.dart';
import '../features/screens/siswa_list_screen.dart';
import '../features/screens/user_list_screen.dart';
import '../features/screens/splash_screen.dart';
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
      GoRoute(
        path: AppRoutes.libur,
        name: AppRoutes.namedLibur,
        builder: (context, state) => const LiburScreen(),
      ),
    ],
  );
}

// lib/presentation/routes/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/attendance/screens/attendance_list_screen.dart';
import '../features/siswa/screens/siswa_list_screen.dart';
import '../features/user/screens/user_list_screen.dart';
import '../features/splash/splash_screen.dart';
import '../providers/app_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isSplash = state.uri.path == '/splash';
      final isLogin = state.uri.path == '/login';

      if (!isAuthenticated && !isLogin && !isSplash) {
        return '/login';
      }

      if (isAuthenticated && (isLogin || isSplash)) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/attendance',
        name: 'attendance',
        builder: (context, state) => const AttendanceListScreen(),
      ),
      GoRoute(
        path: '/siswa',
        name: 'siswa',
        builder: (context, state) => const SiswaListScreen(),
      ),
      GoRoute(
        path: '/users',
        name: 'users',
        builder: (context, state) => const UserListScreen(),
      ),
    ],
  );
});

class AppRouter {
  Provider<GoRouter> get router => routerProvider;
}

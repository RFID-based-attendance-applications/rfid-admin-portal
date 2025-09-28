// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/providers/app_provider.dart';
import 'presentation/routes/app_router.dart';

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final AppRouter _appRouter = AppRouter();

  MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLightTheme = ref.watch(themeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: isLightTheme ? AppTheme.lightTheme : AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isLightTheme ? ThemeMode.light : ThemeMode.dark,
      routerConfig: _appRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}

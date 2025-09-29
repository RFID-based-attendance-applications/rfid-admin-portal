import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/api_service.dart';

// Global Service Providers
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Shared Preferences Provider - PERBAIKI: Provider, bukan FutureProvider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
      'SharedPreferences should be overridden in main.dart');
});

// Theme Provider (Global)
final themeProvider = StateProvider<bool>((ref) => true);

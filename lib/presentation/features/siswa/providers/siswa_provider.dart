import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../../../data/models/siswa.dart';
import '../../../providers/app_provider.dart';

final siswaProvider = StateNotifierProvider<SiswaNotifier, SiswaState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return SiswaNotifier(apiService);
});

class SiswaState {
  final bool isLoading;
  final List<Siswa> siswaList;
  final String? error;
  final bool isImporting;

  const SiswaState({
    this.isLoading = false,
    this.siswaList = const [],
    this.error,
    this.isImporting = false,
  });

  SiswaState copyWith({
    bool? isLoading,
    List<Siswa>? siswaList,
    String? error,
    bool? isImporting,
  }) {
    return SiswaState(
      isLoading: isLoading ?? this.isLoading,
      siswaList: siswaList ?? this.siswaList,
      error: error ?? this.error,
      isImporting: isImporting ?? this.isImporting,
    );
  }
}

class SiswaNotifier extends StateNotifier<SiswaState> {
  final ApiService _apiService;

  SiswaNotifier(this._apiService) : super(const SiswaState());

  Future<void> loadSiswa() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.getSiswa();
      final siswaList =
          (response as List).map((data) => Siswa.fromJson(data)).toList();

      state = state.copyWith(
        isLoading: false,
        siswaList: siswaList,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createSiswa(Siswa siswa) async {
    try {
      await _apiService.createSiswa(siswa.toJson());
      await loadSiswa();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> updateSiswa(Siswa siswa) async {
    try {
      await _apiService.updateSiswa(siswa.id.toString(), siswa.toJson());
      await loadSiswa();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteSiswa(String id) async {
    try {
      await _apiService.deleteSiswa(id);
      await loadSiswa();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> importSiswa(List<int> fileBytes, String filename) async {
    state = state.copyWith(isImporting: true, error: null);

    try {
      await _apiService.importSiswa(fileBytes, filename);
      await loadSiswa();
      state = state.copyWith(isImporting: false);
    } catch (e) {
      state = state.copyWith(
        isImporting: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> registerRFID(String siswaId, String rfidTag) async {
    try {
      await _apiService.registerRFID(siswaId, rfidTag);
      await loadSiswa();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }
}

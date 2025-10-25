import 'package:admin_absensi_hasbi/core/exceptions/api_exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../../data/models/libur.dart';
import '../../providers/app_provider.dart';

final liburProvider = StateNotifierProvider<LiburNotifier, LiburState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return LiburNotifier(apiService);
});

class LiburState {
  final bool isLoading;
  final List<Libur> liburList;
  final String? error;

  const LiburState({
    this.isLoading = false,
    this.liburList = const [],
    this.error,
  });

  LiburState copyWith({
    bool? isLoading,
    List<Libur>? liburList,
    String? error,
  }) {
    return LiburState(
      isLoading: isLoading ?? this.isLoading,
      liburList: liburList ?? this.liburList,
      error: error ?? this.error,
    );
  }
}

class LiburNotifier extends StateNotifier<LiburState> {
  final ApiService _apiService;

  LiburNotifier(this._apiService) : super(const LiburState());

  Future<void> loadLibur() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _apiService.getLibur();

      print('Libur response: $response');

      if (response is List) {
        final List<Libur> liburList = [];
        print('Raw response from getLibur: $response');
        for (final liburData in response) {
          print('Parsing libur data: $liburData');
          if (liburData is Map<String, dynamic>) {
            try {
              final libur = Libur.fromJson(liburData);
              liburList.add(libur);
            } catch (e) {
              print('Failed to parse libur data: $liburData | Error: $e');
            }
          } else {
            print(
                'Unexpected libur data type: $liburData (type: ${liburData.runtimeType})');
          }
        }
        state = state.copyWith(liburList: liburList, isLoading: false);
      } else {
        throw ApiException(
          message: 'Invalid response format from server: expected List',
          statusCode: 0,
        );
      }
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message, isLoading: false);
    } catch (e) {
      state =
          state.copyWith(error: 'Failed to load libur: $e', isLoading: false);
    }
  }

  Future<void> createLibur(Libur libur) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final liburData = {
        'tanggal': libur.tanggal.toIso8601String().split('T')[0]
      };

      final response = await _apiService.createLibur(liburData);

      await loadLibur(); // Refresh list setelah berhasil
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message, isLoading: false);
      rethrow;
    } catch (e) {
      state =
          state.copyWith(error: 'Failed to create libur: $e', isLoading: false);
      rethrow;
    }
  }

  Future<void> deleteLibur(int id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _apiService.deleteLibur(id);

      // Hapus langsung dari state tanpa reload
      final updatedLiburList =
          state.liburList.where((libur) => libur.id != id).toList();
      state = state.copyWith(liburList: updatedLiburList, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message, isLoading: false);
      rethrow;
    } catch (e) {
      state =
          state.copyWith(error: 'Failed to delete libur: $e', isLoading: false);
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

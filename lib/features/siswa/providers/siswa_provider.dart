import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/siswa.dart';

final siswaProvider = StateNotifierProvider<SiswaProvider, List<Siswa>>((ref) {
  return SiswaProvider();
});

class SiswaProvider extends StateNotifier<List<Siswa>> {
  SiswaProvider()
      : super([
          Siswa(
            id: 1,
            nis: "1001",
            name: "Ahmad Rizky",
            kelas: "X IPA 1",
            image: "",
            phone: "081234567890",
            wali: "Bapak Budi",
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Siswa(
            id: 2,
            nis: "1002",
            name: "Siti Nurhaliza",
            kelas: "X IPS 2",
            image: "",
            phone: "081298765432",
            wali: "Ibu Dian",
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Siswa(
            id: 3,
            nis: "1003",
            name: "Raka Pratama",
            kelas: "XI MIPA 3",
            image: "",
            phone: "081345678901",
            wali: "Bapak Agus",
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ]);

  void addSiswa(Siswa siswa) {
    state = [...state, siswa];
  }

  void updateSiswa(int index, Siswa updatedSiswa) {
    state = [
      ...state.take(index),
      updatedSiswa,
      ...state.skip(index + 1),
    ];
  }

  void deleteSiswa(int index) {
    state = [...state..removeAt(index)];
  }
}

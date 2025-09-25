import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/siswa.dart';
import '../providers/siswa_provider.dart';
import '../../../shared/widgets/side_nav.dart';
import '../../../shared/utils/responsive.dart';
import '../../../shared/widgets/siswa_action_menu.dart';

class SiswaListScreen extends ConsumerWidget {
  const SiswaListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final siswas = ref.watch(siswaProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        title: const Text(
          'Manage Siswa',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      drawer: !Responsive.isDesktop(context) ? const SideNav() : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Responsive.isMobile(context)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Daftar Siswa",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4), // 🔹 jarak kecil
                      const Text(
                        "Kelola data siswa berbasis RFID",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 12), // 🔹 jarak sebelum tombol
                      ElevatedButton.icon(
                        onPressed: () => _showAddSiswaDialog(context, ref),
                        icon: const Icon(Icons.add,
                            size: 18, color: Colors.white),
                        label: const Text(
                          "Tambah Siswa",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          minimumSize: const Size(
                              double.infinity, 48), // full width di mobile
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16), // 🔹 jarak sebelum search box
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Daftar Siswa",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4), // 🔹 jarak kecil antar teks
                              Text(
                                "Kelola data siswa berbasis RFID",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _showAddSiswaDialog(context, ref),
                            icon:
                                Icon(Icons.add, size: 18, color: Colors.white),
                            label: Text(
                              "Tambah Siswa",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF3B82F6),
                              minimumSize: Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16), // 🔹 jarak sebelum search box
                    ],
                  ),

            /// SEARCH & FILTER
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Cari nama atau NIS...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
            const SizedBox(height: 16),

            /// TABEL / LIST
            Expanded(
              child: siswas.isEmpty
                  ? _buildEmptyState(context, ref)
                  : Responsive.isDesktop(context)
                      ? _buildDataTable(siswas, ref)
                      : _buildListView(siswas, ref),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 DataTable (Desktop)
  Widget _buildDataTable(List<Siswa> siswas, WidgetRef ref) {
    return SingleChildScrollView(
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
        dividerThickness: 0.5,
        dataRowColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.hovered)) {
              return Colors.blue.shade50;
            }
            return null;
          },
        ),
        columns: const [
          DataColumn(label: Text("No")),
          DataColumn(label: Text("NIS")),
          DataColumn(label: Text("Nama")),
          DataColumn(label: Text("Kelas")),
          DataColumn(label: Text("Telepon")),
          DataColumn(label: Text("Wali")),
          DataColumn(label: Text("Aksi")),
        ],
        rows: List.generate(siswas.length, (index) {
          final siswa = siswas[index];
          return DataRow(
            cells: [
              DataCell(Text('${index + 1}')),
              DataCell(Text(siswa.nis)),
              DataCell(Text(siswa.name)),
              DataCell(Text(siswa.kelas)),
              DataCell(Text(siswa.phone)),
              DataCell(Text(siswa.wali)),
              DataCell(SiswaActionMenu(siswa: siswa, index: index)),
            ],
          );
        }),
      ),
    );
  }

  /// 🔹 ListTile (Mobile)
  Widget _buildListView(List<Siswa> siswas, WidgetRef ref) {
    return ListView.separated(
      itemCount: siswas.length,
      separatorBuilder: (_, __) => Divider(color: Colors.grey.shade300),
      itemBuilder: (context, index) {
        final siswa = siswas[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Text(
              "${index + 1}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                siswa.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "NIS: ${siswa.nis} | Kelas: ${siswa.kelas}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "📞 ${siswa.phone}",
                style: const TextStyle(fontSize: 13, color: Colors.blue),
              ),
              Text(
                "👨‍👩‍👧‍👦 Wali: ${siswa.wali}",
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          trailing: SiswaActionMenu(siswa: siswa, index: index),
        );
      },
    );
  }

  /// 🔹 Empty State
  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_rounded, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            "Belum ada siswa",
            style: TextStyle(fontFamily: 'Poppins', fontSize: 15),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _showAddSiswaDialog(context, ref),
            icon: const Icon(Icons.add, size: 18, color: Colors.white),
            label: const Text(
              "Tambah Siswa",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              minimumSize: const Size(0, 48), // lebar fleksibel, tinggi 48px
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
        ],
      ),
    );
  }

  /// 🔹 Add Siswa Dialog (lebih modern)
  void _showAddSiswaDialog(BuildContext context, WidgetRef? ref) {
    final nisController = TextEditingController();
    final nameController = TextEditingController();
    final kelasController = TextEditingController();
    final phoneController = TextEditingController();
    final waliController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Judul
              const Text(
                "Tambah Siswa Baru",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // NIS
              TextField(
                controller: nisController,
                decoration: InputDecoration(
                  labelText: "NIS",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 16),

              // Nama
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Nama Lengkap",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 16),

              // Kelas
              TextField(
                controller: kelasController,
                decoration: InputDecoration(
                  labelText: "Kelas",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 16),

              // Telepon
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: "Nomor Telepon",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 16),

              // Wali
              TextField(
                controller: waliController,
                decoration: InputDecoration(
                  labelText: "Nama Wali",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 30),

              // Button Tambah
              ElevatedButton(
                onPressed: () {
                  if (nisController.text.isNotEmpty &&
                      nameController.text.isNotEmpty &&
                      kelasController.text.isNotEmpty &&
                      phoneController.text.isNotEmpty &&
                      waliController.text.isNotEmpty) {
                    ref?.read(siswaProvider.notifier).addSiswa(
                          Siswa(
                            id: DateTime.now().millisecondsSinceEpoch,
                            nis: nisController.text,
                            name: nameController.text,
                            kelas: kelasController.text,
                            image: "", // Simulasi kosong
                            phone: phoneController.text,
                            wali: waliController.text,
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          ),
                        );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Tambah",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

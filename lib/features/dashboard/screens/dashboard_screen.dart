import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../shared/utils/responsive.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/side_nav.dart';
import '../widgets/stats_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Dashboard'),
      drawer: !Responsive.isDesktop(context) ? const SideNav() : null,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context)) const SideNav(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreeting(ref),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Statistik'),
                    const SizedBox(height: 16),
                    _buildStatsGrid(), // Menggunakan Grid yang responsif
                    const SizedBox(height: 32),
                    _buildSectionTitle('Aksi Cepat'),
                    const SizedBox(height: 16),
                    _buildQuickActions(context),
                    const SizedBox(height: 40),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Kumpulan Widget Builder untuk Kode yang Lebih Rapi ---

  Widget _buildGreeting(WidgetRef ref) {
    final user = ref.watch(authProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Halo, ${user?.username ?? 'Admin'} 👋', // ENHANCE: Tambah emoji
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selamat datang di sistem absensi berbasis RFID',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
        color: Colors.black87,
      ),
    );
  }

  Widget _buildStatsGrid() {
    // FIX: Gunakan Wrap agar kartu statistik responsif dan tidak overflow
    return const Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        StatsCard(
          title: 'Total User',
          value: '128',
          icon: Icons.people_outline_rounded,
          color: Colors.blue,
        ),
        StatsCard(
          title: 'Total Siswa',
          value: '128',
          icon: Icons.school_rounded,
          color: Colors.blue,
        ),
        StatsCard(
          title: 'Hadir Hari Ini',
          value: '115',
          icon: Icons.check_circle_outline_rounded,
          color: Colors.green,
        ),
        StatsCard(
          title: 'Izin',
          value: '8',
          icon: Icons.pending_outlined,
          color: Colors.orange,
        ),
        StatsCard(
          title: 'Alpha',
          value: '5',
          icon: Icons.cancel_outlined,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildActionButton(context, 'Manage Siswa', Icons.school_rounded,
            Colors.blue, () => Navigator.pushNamed(context, '/siswa')),
        _buildActionButton(
            context,
            'Manage User',
            Icons.person_add_alt_1_rounded,
            Colors.purple,
            () => Navigator.pushNamed(context, '/users')),
        _buildActionButton(context, 'Lihat Absensi', Icons.timeline_rounded,
            Colors.green, () => Navigator.pushNamed(context, '/attendance')),
        _buildActionButton(context, 'Import Siswa', Icons.file_upload_rounded,
            Colors.deepOrange, () => _importSiswa(context)),
      ],
    );
  }

  Widget _buildFooter() {
    // ENHANCE: Tahun dinamis sesuai tahun saat ini (2025)
    return Center(
      child: Text(
        '© ${DateTime.now().year} Aplikasi Absensi Siswa • Semua hak dilindungi',
        style: TextStyle(
            fontSize: 12, color: Colors.grey[500], fontFamily: 'Poppins'),
      ),
    );
  }

  // --- Widget Aksi Cepat yang Ditingkatkan ---

  Widget _buildActionButton(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    // ENHANCE: Gunakan InkWell untuk efek ripple saat disentuh
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(20), // Sesuaikan dengan radius Container
      child: Container(
        width: 160,
        height: 140,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            // ENHANCE: Efek shadow yang lebih lembut dan modern
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: color.withOpacity(0.3))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600, // Sedikit lebih tebal
                color: Colors.black.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _importSiswa(BuildContext context) async {
    ArtSweetAlert.show(
      context: context,
      artDialogArgs: ArtDialogArgs(
        type: ArtSweetAlertType.info,
        title: "Fitur Belum Tersedia",
        text: "Fitur import data siswa via Excel akan segera hadir.",
      ),
    );
  }
}

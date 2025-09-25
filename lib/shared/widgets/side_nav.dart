import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';

class SideNav extends ConsumerWidget {
  const SideNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Dapatkan rute saat ini untuk menandai item aktif
    final String? currentRoute = ModalRoute.of(context)?.settings.name;

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF3B82F6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Colors.white,
                  size: 36,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'RFID Absensi',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildNavItem(
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  isActive: currentRoute == '/dashboard',
                  onTap: () => _navigateTo(context, '/dashboard'),
                ),
                _buildNavItem(
                  icon: Icons.people_alt_rounded,
                  title: 'Manage User',
                  isActive: currentRoute == '/users',
                  onTap: () => _navigateTo(context, '/users'),
                ),
                _buildNavItem(
                  icon: Icons.school_rounded,
                  title: 'Manage Siswa',
                  isActive: currentRoute == '/siswa',
                  onTap: () => _navigateTo(context, '/siswa'),
                ),
                _buildNavItem(
                  icon: Icons.timeline_rounded,
                  title: 'Lihat Absensi',
                  isActive: currentRoute == '/attendance',
                  onTap: () => _navigateTo(context, '/attendance'),
                ),
                const Divider(
                  color: Color(0xFFE2E8F0),
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                  height: 32,
                ),
                _buildNavItem(
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  color: Colors.red.shade600,
                  isActive: false, // Logout tidak pernah aktif
                  onTap: () {
                    // Gunakan provider untuk logout, lebih konsisten
                    ref.read(authProvider.notifier).logout();
                    Navigator.pushReplacementNamed(context, '/');
                  },
                ),
              ],
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'v1.0 • Absensi RFID',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk navigasi agar tidak duplikat kode
  void _navigateTo(BuildContext context, String routeName) {
    if (ModalRoute.of(context)?.settings.name != routeName) {
      Navigator.pushReplacementNamed(context, routeName);
    }
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isActive,
    Color? color,
  }) {
    final activeColor = color ?? const Color(0xFF3B82F6);
    final inactiveColor = color ?? Colors.grey[700];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? activeColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? activeColor : inactiveColor,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Poppins',
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? activeColor : inactiveColor,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        dense: true,
      ),
    );
  }
}

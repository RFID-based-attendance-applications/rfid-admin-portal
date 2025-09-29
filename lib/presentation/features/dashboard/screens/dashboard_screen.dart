import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/shared/admin_layout.dart';
import '../../../widgets/stats_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdminLayout(
      title: 'Dashboard',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Cards
            const Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Total Siswa',
                    value: '250',
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: 'Hadir Hari Ini',
                    value: '230',
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: 'Tidak Hadir',
                    value: '20',
                    icon: Icons.cancel,
                    color: Colors.red,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: 'Admin Users',
                    value: '5',
                    icon: Icons.admin_panel_settings,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Recent Activity & Charts
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recent Activity
                  Expanded(
                    flex: 2,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Aktivitas Terkini',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.builder(
                                itemCount: 10,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    title: Text(
                                        'Siswa ${index + 1} melakukan check-in'),
                                    subtitle: Text(
                                        '${DateTime.now().subtract(Duration(minutes: index * 10))}'),
                                    trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Quick Actions
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Quick Actions',
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 16),
                                _QuickActionButton(
                                  icon: Icons.person_add,
                                  label: 'Tambah Siswa',
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SiswaFormModal(),
                                    ),
                                  ),
                                ),
                                _QuickActionButton(
                                  icon: Icons.upload_file,
                                  label: 'Import Excel',
                                  onTap: () {},
                                ),
                                _QuickActionButton(
                                  icon: Icons.bar_chart,
                                  label: 'Laporan',
                                  onTap: () {},
                                ),
                                _QuickActionButton(
                                  icon: Icons.settings,
                                  label: 'Pengaturan',
                                  onTap: () {},
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label),
      onTap: onTap,
      visualDensity: VisualDensity.compact,
    );
  }
}

// Placeholder for Siswa Form Modal
class SiswaFormModal extends StatelessWidget {
  const SiswaFormModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Siswa'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Form tambah siswa akan diimplementasi nanti'),
      ),
    );
  }
}

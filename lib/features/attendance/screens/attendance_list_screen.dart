import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/attendance.dart';
import '../providers/attendance_provider.dart';
import '../../../shared/widgets/side_nav.dart';
import '../../../shared/utils/responsive.dart';

class AttendanceListScreen extends ConsumerWidget {
  const AttendanceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendances = ref.watch(attendanceProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        title: const Text(
          'Manage Absensi',
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
                        "Daftar Absensi",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Kelola catatan absensi siswa berbasis RFID",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => _showAddAttendanceDialog(context, ref),
                        icon: const Icon(Icons.add,
                            size: 18, color: Colors.white),
                        label: const Text(
                          "Tambah Absensi",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
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
                                "Daftar Absensi",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Kelola catatan absensi siswa berbasis RFID",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () =>
                                _showAddAttendanceDialog(context, ref),
                            icon:
                                Icon(Icons.add, size: 18, color: Colors.white),
                            label: Text(
                              "Tambah Absensi",
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
                      const SizedBox(height: 16),
                    ],
                  ),

            /// SEARCH & FILTER
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Cari NIS atau status...",
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
              child: attendances.isEmpty
                  ? _buildEmptyState(context, ref)
                  : Responsive.isDesktop(context)
                      ? _buildDataTable(attendances, ref)
                      : _buildListView(attendances, ref),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 DataTable (Desktop)
  Widget _buildDataTable(List<Attendance> attendances, WidgetRef ref) {
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
          DataColumn(label: Text("Kegiatan")),
          DataColumn(label: Text("Status")),
          DataColumn(label: Text("Waktu")),
          DataColumn(label: Text("Aksi")),
        ],
        rows: List.generate(attendances.length, (index) {
          final att = attendances[index];
          String displayTime =
              "${att.createdAt.hour}:${att.createdAt.minute.toString().padLeft(2, '0')} ${att.createdAt.day}/${att.createdAt.month}";
          String activityText = att.activity ?? '-';

          return DataRow(
            cells: [
              DataCell(Text('${index + 1}')),
              DataCell(Text(att.nis)),
              DataCell(Text(activityText)),
              DataCell(
                _buildStatusChip(att.status),
              ),
              DataCell(Text(displayTime)),
              DataCell(AttendanceActionMenu(attendance: att, index: index)),
            ],
          );
        }),
      ),
    );
  }

  /// 🔹 ListTile (Mobile)
  Widget _buildListView(List<Attendance> attendances, WidgetRef ref) {
    return ListView.separated(
      itemCount: attendances.length,
      separatorBuilder: (_, __) => Divider(color: Colors.grey.shade300),
      itemBuilder: (context, index) {
        final att = attendances[index];
        String displayTime =
            "${att.createdAt.hour}:${att.createdAt.minute.toString().padLeft(2, '0')} ${att.createdAt.day}/${att.createdAt.month}";
        String activityText = att.activity ?? '-';

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
                "NIS: ${att.nis}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Kegiatan: $activityText",
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Status: ${_getStatusLabel(att.status)}",
                style: TextStyle(
                  color: _getStatusColor(att.status),
                  fontSize: 13,
                ),
              ),
              Text(
                "Waktu: $displayTime",
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          trailing: AttendanceActionMenu(attendance: att, index: index),
        );
      },
    );
  }

  /// 🔹 Status Chip / Label
  Widget _buildStatusChip(String status) {
    Color bgColor = Colors.grey;
    Color textColor = Colors.white;

    switch (status) {
      case 'hadir':
        bgColor = Colors.green;
        break;
      case 'izin':
        bgColor = Colors.orange;
        break;
      case 'sakit':
        bgColor = Colors.yellow;
        break;
      case 'alpha':
        bgColor = Colors.red;
        break;
      default:
        bgColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusLabel(status),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getStatusLabel(String status) {
    Map<String, String> labels = {
      'hadir': 'Hadir',
      'izin': 'Izin',
      'sakit': 'Sakit',
      'alpha': 'Alpha',
    };
    return labels[status] ?? status;
  }

  Color _getStatusColor(String status) {
    Map<String, Color> colors = {
      'hadir': Colors.green,
      'izin': Colors.orange,
      'sakit': Colors.yellow,
      'alpha': Colors.red,
    };
    return colors[status] ?? Colors.grey;
  }

  /// 🔹 Empty State
  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timeline_rounded, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            "Belum ada absensi",
            style: TextStyle(fontFamily: 'Poppins', fontSize: 15),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _showAddAttendanceDialog(context, ref),
            icon: const Icon(Icons.add, size: 18, color: Colors.white),
            label: const Text(
              "Tambah Absensi",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
        ],
      ),
    );
  }

  /// 🔹 Add/Edit Attendance Dialog
  void _showAddAttendanceDialog(BuildContext context, WidgetRef? ref) {
    final nisController = TextEditingController();
    final activityController = TextEditingController();
    final statusController = ValueNotifier<String>('hadir');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Absensi Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nisController,
              decoration: const InputDecoration(
                labelText: 'NIS Siswa',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: activityController,
              decoration: const InputDecoration(
                labelText: 'Kegiatan (opsional)',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Status',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatusOption(
                    'hadir', 'Hadir', Colors.green, statusController),
                _buildStatusOption(
                    'izin', 'Izin', Colors.orange, statusController),
                _buildStatusOption(
                    'sakit', 'Sakit', Colors.yellow, statusController),
                _buildStatusOption(
                    'alpha', 'Alpha', Colors.red, statusController),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (nisController.text.isNotEmpty) {
                ref?.read(attendanceProvider.notifier).addAttendance(
                      Attendance(
                        id: DateTime.now().millisecondsSinceEpoch,
                        nis: nisController.text,
                        activity: activityController.text.isEmpty
                            ? null
                            : activityController.text,
                        status: statusController.value,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOption(
      String value, String label, Color color, ValueNotifier<String> notifier) {
    return GestureDetector(
      onTap: () => notifier.value = value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: notifier.value == value
              ? color.withOpacity(0.2)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notifier.value == value ? color : Colors.grey,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: notifier.value == value ? color : Colors.grey,
            fontWeight:
                notifier.value == value ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// 🔹 Action Menu untuk Attendance
class AttendanceActionMenu extends ConsumerWidget {
  final Attendance attendance;
  final int index;

  const AttendanceActionMenu(
      {super.key, required this.attendance, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'update') {
          _showUpdateDialog(context, ref, attendance, index);
        } else if (value == 'delete') {
          _confirmDelete(context, ref, index);
        }
      },
      icon: const Icon(Icons.more_vert, color: Colors.grey),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'update',
          child: Row(
            children: [
              const Icon(Icons.edit, color: Colors.blue),
              const SizedBox(width: 10),
              Text('Ubah', style: TextStyle(color: Colors.blue)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Icons.delete, color: Colors.red),
              const SizedBox(width: 10),
              Text('Hapus', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  void _showUpdateDialog(
      BuildContext context, WidgetRef ref, Attendance att, int index) {
    final nisController = TextEditingController(text: att.nis);
    final activityController = TextEditingController(text: att.activity ?? '');
    final statusController = ValueNotifier<String>(att.status);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Absensi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nisController,
              decoration: const InputDecoration(
                labelText: 'NIS Siswa',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: activityController,
              decoration: const InputDecoration(
                labelText: 'Kegiatan (opsional)',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Status',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatusOption(
                    'hadir', 'Hadir', Colors.green, statusController),
                _buildStatusOption(
                    'izin', 'Izin', Colors.orange, statusController),
                _buildStatusOption(
                    'sakit', 'Sakit', Colors.yellow, statusController),
                _buildStatusOption(
                    'alpha', 'Alpha', Colors.red, statusController),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (nisController.text.isNotEmpty) {
                ref.read(attendanceProvider.notifier).updateAttendance(
                      index,
                      Attendance(
                        id: att.id,
                        nis: nisController.text,
                        activity: activityController.text.isEmpty
                            ? null
                            : activityController.text,
                        status: statusController.value,
                        createdAt: att.createdAt,
                        updatedAt: DateTime.now(),
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOption(
      String value, String label, Color color, ValueNotifier<String> notifier) {
    return GestureDetector(
      onTap: () => notifier.value = value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: notifier.value == value
              ? color.withOpacity(0.2)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notifier.value == value ? color : Colors.grey,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: notifier.value == value ? color : Colors.grey,
            fontWeight:
                notifier.value == value ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Absensi?'),
        content:
            const Text('Apakah Anda yakin ingin menghapus data absensi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              ref.read(attendanceProvider.notifier).deleteAttendance(index);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/shared/admin_layout.dart';
import '../provider/attendance_provider.dart';
import '../../../data/models/attendance.dart';

class AttendanceListScreen extends ConsumerStatefulWidget {
  const AttendanceListScreen({super.key});

  @override
  ConsumerState<AttendanceListScreen> createState() =>
      _AttendanceListScreenState();
}

class _AttendanceListScreenState extends ConsumerState<AttendanceListScreen> {
  @override
  void initState() {
    super.initState();
    // Load data saat screen pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(attendanceProvider.notifier).loadAttendance();
    });
  }

  void _handleFilterChange({
    String? month,
    String? kelas,
    DateTime? date,
  }) {
    ref.read(attendanceProvider.notifier).loadAttendance(
          month: month,
          kelas: kelas,
          date: date,
        );
  }

  void _showDatePicker() {
    final currentState = ref.read(attendanceProvider);

    showDatePicker(
      context: context,
      initialDate: currentState.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    ).then((date) {
      if (date != null) {
        _handleFilterChange(date: date);
      }
    });
  }

  void _handleExport() {
    final notifier = ref.read(attendanceProvider.notifier);
    final state = ref.read(attendanceProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('Data kehadiran akan diexport ke format Excel.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await notifier.exportToExcel(
                  kelas: state.selectedClass != 'Semua Kelas'
                      ? state.selectedClass
                      : null,
                  startDate: state.selectedDate,
                  endDate: state.selectedDate,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data berhasil diexport'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final attendanceState = ref.watch(attendanceProvider);
    final attendanceNotifier = ref.read(attendanceProvider.notifier);

    final months = List.generate(12, (index) => (index + 1).toString());
    final classes = [
      'Semua Kelas',
      'X IPA 1',
      'X IPA 2',
      'XI IPA 1',
      'XI IPA 2',
      'XII IPA 1',
      'XII IPA 2',
    ];

    return AdminLayout(
      title: 'Manajemen Kehadiran',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Filter Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Month Filter
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Bulan'),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: attendanceState.selectedMonth.isEmpty
                                ? DateTime.now().month.toString()
                                : attendanceState.selectedMonth,
                            items: months.map((month) {
                              return DropdownMenuItem(
                                value: month,
                                child: Text('Bulan $month'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              _handleFilterChange(month: value);
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Class Filter
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Kelas'),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: attendanceState.selectedClass,
                            items: classes.map((classItem) {
                              return DropdownMenuItem(
                                value: classItem,
                                child: Text(classItem),
                              );
                            }).toList(),
                            onChanged: (value) {
                              _handleFilterChange(kelas: value);
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Date Filter
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tanggal'),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _showDatePicker,
                            child: Container(
                              height: 56,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '${attendanceState.selectedDate.day}/${attendanceState.selectedDate.month}/${attendanceState.selectedDate.year}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.calendar_today),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Export Button
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Aksi'),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.download),
                            label: const Text('Export Excel'),
                            onPressed: attendanceState.isLoading
                                ? null
                                : _handleExport,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(56),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Error Handling
            if (attendanceState.error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(child: Text(attendanceState.error!)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => attendanceNotifier.clearError(),
                    ),
                  ],
                ),
              ),

            // Statistics
            if (attendanceState.statistics != null)
              Row(
                children: [
                  _AttendanceStatCard(
                    title: 'Total',
                    value: attendanceState.statistics!['total'].toString(),
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 16),
                  _AttendanceStatCard(
                    title: 'Hadir',
                    value: attendanceState.statistics!['hadir'].toString(),
                    color: Colors.green,
                  ),
                  const SizedBox(width: 16),
                  _AttendanceStatCard(
                    title: 'Terlambat',
                    value: attendanceState.statistics!['terlambat'].toString(),
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 16),
                  _AttendanceStatCard(
                    title: 'Tidak Hadir',
                    value: attendanceState.statistics!['alpha'].toString(),
                    color: Colors.red,
                  ),
                ],
              ),
            const SizedBox(height: 24),

            // Attendance List
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Data Kehadiran - ${attendanceState.selectedDate.day}/${attendanceState.selectedDate.month}/${attendanceState.selectedDate.year}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      if (attendanceState.isLoading)
                        const Expanded(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else
                        Expanded(
                          child: attendanceState.attendanceList.isEmpty
                              ? const Center(
                                  child: Text('Tidak ada data kehadiran'))
                              : _AttendanceTable(
                                  attendanceList:
                                      attendanceState.attendanceList),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceTable extends StatelessWidget {
  final List<Attendance> attendanceList;

  const _AttendanceTable({required this.attendanceList});

  String _getStudentName(String nis) {
    // In real app, this would come from database
    final names = {
      '2024001': 'Ahmad Rizki',
      '2024002': 'Siti Nurhaliza',
      '2024003': 'Budi Santoso',
      '2024004': 'Dewi Lestari',
      '2024005': 'Rudi Hermawan',
    };
    return names[nis] ?? 'Unknown';
  }

  String _getStudentClass(String nis) {
    // In real app, this would come from database
    final classes = {
      '2024001': 'X IPA 1',
      '2024002': 'X IPA 1',
      '2024003': 'X IPA 2',
      '2024004': 'XI IPA 1',
      '2024005': 'XI IPA 2',
    };
    return classes[nis] ?? 'Unknown';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Hadir':
        return Colors.green;
      case 'Terlambat':
        return Colors.orange;
      case 'Izin':
        return Colors.blue;
      case 'Sakit':
        return Colors.purple;
      case 'Alpha':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Expanded(
                  flex: 1,
                  child: Text('NIS',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(
                  flex: 2,
                  child: Text('Nama',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(
                  flex: 1,
                  child: Text('Kelas',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(
                  flex: 2,
                  child: Text('Waktu',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(
                  flex: 1,
                  child: Text('Status',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(
                  flex: 1,
                  child: Text('Aktivitas',
                      style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Table Body
        Expanded(
          child: ListView.builder(
            itemCount: attendanceList.length,
            itemBuilder: (context, index) {
              final attendance = attendanceList[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: index.isEven
                      ? Theme.of(context).colorScheme.surface
                      : Theme.of(context)
                          .colorScheme
                          .surfaceVariant
                          .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(flex: 1, child: Text(attendance.nis)),
                    Expanded(
                        flex: 2, child: Text(_getStudentName(attendance.nis))),
                    Expanded(
                        flex: 1, child: Text(_getStudentClass(attendance.nis))),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${attendance.createdAt.hour}:${attendance.createdAt.minute.toString().padLeft(2, '0')}',
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(attendance.status)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          attendance.status,
                          style: TextStyle(
                            color: _getStatusColor(attendance.status),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(flex: 1, child: Text(attendance.activity ?? '-')),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AttendanceStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _AttendanceStatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// lib/presentation/features/attendance/screens/attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/shared/admin_layout.dart';
import '../../../../data/models/attendance.dart';

class AttendanceListScreen extends ConsumerStatefulWidget {
  const AttendanceListScreen({super.key});

  @override
  ConsumerState<AttendanceListScreen> createState() =>
      _AttendanceListScreenState();
}

class _AttendanceListScreenState extends ConsumerState<AttendanceListScreen> {
  final List<Attendance> _attendances = [
    Attendance(
      id: 1,
      nis: '2024001',
      activity: 'Check-in Pagi',
      status: 'Hadir',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Attendance(
      id: 2,
      nis: '2024002',
      activity: 'Check-in Pagi',
      status: 'Terlambat',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    // Add more sample data...
  ];

  String _selectedMonth = '${DateTime.now().month}';
  String _selectedClass = 'Semua Kelas';
  DateTime _selectedDate = DateTime.now();

  List<String> get _months =>
      ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'];

  List<String> get _classes => [
        'Semua Kelas',
        'X IPA 1',
        'X IPA 2',
        'XI IPA 1',
        'XI IPA 2',
        'XII IPA 1',
        'XII IPA 2',
      ];

  List<Attendance> get _filteredAttendances {
    return _attendances.where((attendance) {
      final matchesMonth = _selectedMonth == '${attendance.createdAt.month}';
      final matchesClass = _selectedClass == 'Semua Kelas' ||
          attendance.nis.startsWith(_getClassPrefix(_selectedClass));
      final matchesDate = attendance.createdAt.year == _selectedDate.year &&
          attendance.createdAt.month == _selectedDate.month &&
          attendance.createdAt.day == _selectedDate.day;

      return matchesMonth && matchesClass && matchesDate;
    }).toList();
  }

  String _getClassPrefix(String className) {
    switch (className) {
      case 'X IPA 1':
        return '2024';
      case 'X IPA 2':
        return '2024';
      case 'XI IPA 1':
        return '2023';
      case 'XI IPA 2':
        return '2023';
      case 'XII IPA 1':
        return '2022';
      case 'XII IPA 2':
        return '2022';
      default:
        return '';
    }
  }

  String _getStatusColor(String status) {
    switch (status) {
      case 'Hadir':
        return 'Green';
      case 'Terlambat':
        return 'Orange';
      case 'Izin':
        return 'Blue';
      case 'Sakit':
        return 'Purple';
      case 'Alpha':
        return 'Red';
      default:
        return 'Gray';
    }
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    ).then((date) {
      if (date != null) {
        setState(() {
          _selectedDate = date;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                            value: _selectedMonth,
                            items: _months.map((month) {
                              return DropdownMenuItem(
                                value: month,
                                child: Text('Bulan $month'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedMonth = value!;
                              });
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
                            value: _selectedClass,
                            items: _classes.map((classItem) {
                              return DropdownMenuItem(
                                value: classItem,
                                child: Text(classItem),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedClass = value!;
                              });
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
                                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
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
                            onPressed: () {
                              // Implement export functionality
                            },
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

            // Statistics
            const Row(
              children: [
                Expanded(
                    child: _AttendanceStatCard(
                        title: 'Total', value: '250', color: Colors.blue)),
                SizedBox(width: 16),
                Expanded(
                    child: _AttendanceStatCard(
                        title: 'Hadir', value: '230', color: Colors.green)),
                SizedBox(width: 16),
                Expanded(
                    child: _AttendanceStatCard(
                        title: 'Terlambat', value: '15', color: Colors.orange)),
                SizedBox(width: 16),
                Expanded(
                    child: _AttendanceStatCard(
                        title: 'Tidak Hadir', value: '5', color: Colors.red)),
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
                        'Data Kehadiran - ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),

                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceVariant
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text('NIS',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text('Nama',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text('Kelas',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text('Waktu',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text('Status',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text('Aktivitas',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Table Body
                      Expanded(
                        child: _filteredAttendances.isEmpty
                            ? const Center(
                                child: Text('Tidak ada data kehadiran'))
                            : ListView.builder(
                                itemCount: _filteredAttendances.length,
                                itemBuilder: (context, index) {
                                  final attendance =
                                      _filteredAttendances[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: index.isEven
                                          ? Theme.of(context)
                                              .colorScheme
                                              .surface
                                          : Theme.of(context)
                                              .colorScheme
                                              .surfaceVariant
                                              .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: Text(attendance.nis)),
                                        Expanded(
                                            flex: 2,
                                            child: Text(_getStudentName(
                                                attendance.nis))),
                                        Expanded(
                                            flex: 1,
                                            child: Text(_getStudentClass(
                                                attendance.nis))),
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
                                              color: _getStatusColor(
                                                              attendance.status)
                                                          .toLowerCase() ==
                                                      'green'
                                                  ? Colors.green
                                                      .withOpacity(0.1)
                                                  : _getStatusColor(attendance.status)
                                                              .toLowerCase() ==
                                                          'orange'
                                                      ? Colors.orange
                                                          .withOpacity(0.1)
                                                      : _getStatusColor(attendance.status)
                                                                  .toLowerCase() ==
                                                              'blue'
                                                          ? Colors.blue
                                                              .withOpacity(0.1)
                                                          : _getStatusColor(attendance.status)
                                                                      .toLowerCase() ==
                                                                  'red'
                                                              ? Colors.red
                                                                  .withOpacity(
                                                                      0.1)
                                                              : Colors.grey
                                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              attendance.status,
                                              style: TextStyle(
                                                color: _getStatusColor(
                                                                attendance
                                                                    .status)
                                                            .toLowerCase() ==
                                                        'green'
                                                    ? Colors.green
                                                    : _getStatusColor(attendance
                                                                    .status)
                                                                .toLowerCase() ==
                                                            'orange'
                                                        ? Colors.orange
                                                        : _getStatusColor(attendance
                                                                        .status)
                                                                    .toLowerCase() ==
                                                                'blue'
                                                            ? Colors.blue
                                                            : _getStatusColor(attendance
                                                                            .status)
                                                                        .toLowerCase() ==
                                                                    'red'
                                                                ? Colors.red
                                                                : Colors.grey,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                            flex: 1,
                                            child: Text(
                                                attendance.activity ?? '-')),
                                      ],
                                    ),
                                  );
                                },
                              ),
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
    return Card(
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
    );
  }
}

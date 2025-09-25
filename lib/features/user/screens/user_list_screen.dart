import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user.dart';
import '../providers/user_provider.dart';
import '../../../shared/widgets/user_action_menu.dart';
import '../../../shared/widgets/side_nav.dart';
import '../../../shared/utils/responsive.dart';

class UserListScreen extends ConsumerWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        title: const Text(
          'Manage User',
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
                        "Daftar User",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4), // 🔹 kasih jarak kecil
                      const Text(
                        "Kelola akun pengguna aplikasi absensi",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 12), // 🔹 jarak sebelum tombol
                      ElevatedButton.icon(
                        onPressed: () => _showAddUserDialog(context, ref),
                        icon: const Icon(Icons.add,
                            size: 18, color: Colors.white),
                        label: const Text(
                          "Tambah User",
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
                                "Daftar User",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4), // 🔹 jarak kecil antar teks
                              Text(
                                "Kelola akun pengguna aplikasi absensi",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _showAddUserDialog(context, ref),
                            icon:
                                Icon(Icons.add, size: 18, color: Colors.white),
                            label: Text(
                              "Tambah User",
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
                      hintText: "Cari user...",
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
              child: users.isEmpty
                  ? _buildEmptyState(context)
                  : Responsive.isDesktop(context)
                      ? _buildDataTable(users, ref)
                      : _buildListView(users, ref),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 DataTable (Desktop)
  Widget _buildDataTable(List<User> users, WidgetRef ref) {
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
          DataColumn(label: Text("Username")),
          DataColumn(label: Text("Password")),
          DataColumn(label: Text("Aksi")),
        ],
        rows: List.generate(users.length, (index) {
          final user = users[index];
          return DataRow(
            cells: [
              DataCell(Text('${index + 1}')),
              DataCell(Text(user.username)), // 🔹 Role badge
              const DataCell(Text("••••••")),
              DataCell(UserActionMenu(user: user, index: index)),
            ],
          );
        }),
      ),
    );
  }

  /// 🔹 ListTile (Mobile)
  Widget _buildListView(List<User> users, WidgetRef ref) {
    return ListView.separated(
      itemCount: users.length,
      separatorBuilder: (_, __) => Divider(color: Colors.grey.shade300),
      itemBuilder: (context, index) {
        final user = users[index];
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
          title: Text(user.username),
          subtitle: const Row(
            children: [
              SizedBox(width: 8),
              Text("••••••"),
            ],
          ),
          trailing: UserActionMenu(user: user, index: index),
        );
      },
    );
  }

  /// 🔹 Empty State
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_alt_rounded, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            "Belum ada user",
            style: TextStyle(fontFamily: 'Poppins', fontSize: 15),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _showAddUserDialog(context, null),
            icon: const Icon(Icons.add, size: 18, color: Colors.white),
            label: const Text(
              "Tambsaah User",
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

  /// 🔹 Add User Dialog (lebih modern)
  void _showAddUserDialog(BuildContext context, WidgetRef? ref) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

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
                "Tambah User Baru",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Username
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 20),

              // Password
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
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
                  if (usernameController.text.isNotEmpty &&
                      passwordController.text.isNotEmpty) {
                    ref?.read(userProvider.notifier).addUser(
                          User(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            username: usernameController.text,
                            password: passwordController.text,
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

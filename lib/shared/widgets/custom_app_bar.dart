import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/auth_provider.dart';
import '../utils/responsive.dart'; // Import helper responsif

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      shadowColor: Colors.black,
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      foregroundColor: Colors.black,
      centerTitle: false,
      // Tampilkan tombol drawer hanya di mobile
      leading: Responsive.isMobile(context)
          ? IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      actions: [
        const _UserMenu(),
        const SizedBox(width: 24),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class _UserMenu extends ConsumerWidget {
  const _UserMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    if (user == null) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'logout') {
          ref.read(authProvider.notifier).logout();
          Navigator.pushReplacementNamed(context, '/');
        }
      },
      // Gunakan child untuk tampilan yang lebih custom
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        // child: CircleAvatar(
        //   radius: 18,
        //   backgroundColor: const Color(0xFF3B82F6),
        //   // Fallback jika tidak ada avatar URL
        //   backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
        //       ? NetworkImage(user.avatarUrl!)
        //       : null,
        //   child: user.avatarUrl == null || user.avatarUrl!.isEmpty
        //       ? Text(
        //           user.username.isNotEmpty
        //               ? user.username[0].toUpperCase()
        //               : 'A',
        //           style: const TextStyle(
        //               color: Colors.white, fontWeight: FontWeight.bold),
        //         )
        //       : null,
        // ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false, // Tidak bisa diklik
          child: Row(
            children: [
              const Icon(Icons.person_rounded, size: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.red.shade600, size: 20),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.red.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

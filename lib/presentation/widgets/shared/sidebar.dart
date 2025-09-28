// lib/presentation/widgets/shared/sidebar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_provider.dart';

class Sidebar extends ConsumerWidget {
  final bool isCollapsed;

  const Sidebar({
    super.key,
    required this.isCollapsed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute = GoRouterState.of(context).uri.path;

    return Column(
      children: [
        // Logo & App Name - TANPA HAMBURGER MENU
        Container(
          height: 70,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const FlutterLogo(size: 32),
              if (!isCollapsed) ...[
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'RFID Admin',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        const Divider(height: 1),

        // Navigation Items
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              _NavItem(
                isCollapsed: isCollapsed,
                icon: Icons.dashboard,
                label: 'Dashboard',
                isActive: currentRoute == '/dashboard',
                onTap: () => context.go('/dashboard'),
              ),
              _NavItem(
                isCollapsed: isCollapsed,
                icon: Icons.verified_user_outlined,
                label: 'Kehadiran',
                isActive: currentRoute == '/attendance',
                onTap: () => context.go('/attendance'),
              ),
              _NavItem(
                isCollapsed: isCollapsed,
                icon: Icons.people,
                label: 'Data Siswa',
                isActive: currentRoute == '/siswa',
                onTap: () => context.go('/siswa'),
              ),
              _NavItem(
                isCollapsed: isCollapsed,
                icon: Icons.admin_panel_settings,
                label: 'Admin Users',
                isActive: currentRoute == '/users',
                onTap: () => context.go('/users'),
              ),
            ],
          ),
        ),

        // Logout Button
        Container(
          padding: const EdgeInsets.all(16),
          child: _NavItem(
            isCollapsed: isCollapsed,
            icon: Icons.logout,
            label: 'Logout',
            isActive: false,
            onTap: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final bool isCollapsed;
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.isCollapsed,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
        title: isCollapsed
            ? null
            : Text(
                label,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
        onTap: onTap,
        dense: true,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

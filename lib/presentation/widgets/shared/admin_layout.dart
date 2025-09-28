// lib/presentation/widgets/shared/admin_layout.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'sidebar.dart';
import 'header.dart';

class AdminLayout extends ConsumerStatefulWidget {
  final Widget child;
  final String title;

  const AdminLayout({
    super.key,
    required this.child,
    required this.title,
  });

  @override
  ConsumerState<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends ConsumerState<AdminLayout> {
  bool _isSidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isSidebarCollapsed ? 70 : 250,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Sidebar(
              isCollapsed: _isSidebarCollapsed,
              onToggle: () {
                setState(() {
                  _isSidebarCollapsed = !_isSidebarCollapsed;
                });
              },
            ),
          ),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Header
                Header(
                  title: widget.title,
                  onMenuToggle: () {
                    setState(() {
                      _isSidebarCollapsed = !_isSidebarCollapsed;
                    });
                  },
                ),

                // Page Content
                Expanded(
                  child: widget.child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

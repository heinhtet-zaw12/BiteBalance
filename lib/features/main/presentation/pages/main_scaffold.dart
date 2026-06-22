import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bite_balance/core/constants/app_theme.dart';
import 'package:bite_balance/core/utils/responsive.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateIndex();
  }

  void _updateIndex() {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) {
      _currentIndex = 0;
    } else if (location.startsWith('/dashboard')) {
      _currentIndex = 1;
    } else if (location.startsWith('/analytics')) {
      _currentIndex = 2;
    }
  }

  void _onTabTapped(int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/dashboard');
        break;
      case 2:
        context.go('/analytics');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Desktop: sidebar + centered content
    if (Responsive.isDesktop(context)) {
      return _buildDesktopLayout();
    }

    // Mobile & Tablet: bottom navigation bar
    return _buildMobileLayout();
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: Responsive.sidebarWidth,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              border: Border(
                right: BorderSide(color: AppTheme.divider, width: 1),
              ),
            ),
            child: Column(
              children: [
                // Logo header
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primary, AppTheme.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.restaurant_rounded,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Bite Balance',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                const SizedBox(height: 8),

                // Navigation items
                _SidebarItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: _currentIndex == 0,
                  onTap: () => _onTabTapped(0),
                ),
                _SidebarItem(
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  isSelected: _currentIndex == 1,
                  onTap: () => _onTabTapped(1),
                ),
                _SidebarItem(
                  icon: Icons.analytics_outlined,
                  selectedIcon: Icons.analytics_rounded,
                  label: 'Analytics',
                  isSelected: _currentIndex == 2,
                  onTap: () => _onTabTapped(2),
                ),
              ],
            ),
          ),

          // Main content area — centered with max width
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: Responsive.maxContentWidth,
                ),
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppTheme.divider, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabTapped,
          backgroundColor: AppTheme.surface,
          indicatorColor: AppTheme.primary.withValues(alpha: 0.12),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          animationDuration: const Duration(milliseconds: 400),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.analytics_outlined),
              selectedIcon: Icon(Icons.analytics_rounded),
              label: 'Analytics',
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  size: 22,
                  color:
                      isSelected ? AppTheme.primary : AppTheme.textSecondary,
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

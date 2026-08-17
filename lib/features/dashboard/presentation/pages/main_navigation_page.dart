import 'package:flutter/material.dart';
import 'package:dndn/core/widgets/offline_banner.dart';
import 'package:dndn/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:dndn/features/reports/presentation/pages/reports_page.dart';
import 'package:dndn/features/tracking/presentation/pages/tracking_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 1; // Default to Live Tracking tab

  void _navigateToIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final pages = [
      DashboardPage(
        onNavigateToTracking: () => _navigateToIndex(1),
        onNavigateToReports: () => _navigateToIndex(2),
      ),
      const TrackingPage(),
      const ReportsPage(),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: IndexedStack(index: _currentIndex, children: pages),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _navigateToIndex,
        indicatorColor: theme.colorScheme.primaryContainer,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.navigation_outlined),
            selectedIcon: Icon(Icons.navigation_rounded),
            label: 'Tracking',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'analysis_screen.dart';
import 'settings_screen.dart';
import 'source_selection_screen.dart';

class AppNavigationScreen extends StatefulWidget {
  const AppNavigationScreen({
    super.key,
  });

  @override
  State<AppNavigationScreen> createState() =>
      _AppNavigationScreenState();
}

class _AppNavigationScreenState
    extends State<AppNavigationScreen> {

  int selectedIndex = 0;

  // ============================================================
  // PAGES
  // ============================================================

  final List<Widget> pages = const [
    SourceSelectionScreen(),
    AnalysisScreen(),
    SettingsScreen(),
  ];

  // ============================================================
  // NAVIGATION
  // ============================================================

  void onNavigationItemSelected(
    int index,
  ) {
    setState(() {
      selectedIndex = index;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(

      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),

      bottomNavigationBar:
          NavigationBar(
        selectedIndex:
            selectedIndex,

        onDestinationSelected:
            onNavigationItemSelected,

        destinations: const [

          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home,
            ),
            label: "Home",
          ),

          NavigationDestination(
            icon: Icon(
              Icons.analytics_outlined,
            ),
            selectedIcon: Icon(
              Icons.analytics,
            ),
            label: "Analysis",
          ),

          NavigationDestination(
            icon: Icon(
              Icons.settings_outlined,
            ),
            selectedIcon: Icon(
              Icons.settings,
            ),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
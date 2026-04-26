import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3A8A).withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFEA580C).withOpacity(0.2),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined, color: Color(0xFF1E3A8A)),
              selectedIcon: Icon(Icons.menu_book, color: Color(0xFFEA580C)),
              label: 'Bacaan',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined, color: Color(0xFF1E3A8A)),
              selectedIcon: Icon(Icons.bar_chart, color: Color(0xFFEA580C)),
              label: 'Statistik',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, color: Color(0xFF1E3A8A)),
              selectedIcon: Icon(Icons.settings, color: Color(0xFFEA580C)),
              label: 'Pengaturan',
            ),
          ],
        ),
      ),
    );
  }
}

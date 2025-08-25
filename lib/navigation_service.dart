import 'package:flutter/material.dart';
import 'my_records_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';

class NavigationService {
  static void navigateToTab(BuildContext context, int index) {
    // Get the current route name to avoid unnecessary navigation
    final currentRoute = ModalRoute.of(context)?.settings.name;
    
    switch (index) {
      case 0: // Home
        if (currentRoute != '/records') {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const MyRecordsScreen(),
              settings: const RouteSettings(name: '/records'),
            ),
            (route) => false,
          );
        }
        break;
      case 1: // Notifications
        if (currentRoute != '/notifications') {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const NotificationsScreen(),
              settings: const RouteSettings(name: '/notifications'),
            ),
            (route) => false,
          );
        }
        break;
      case 2: // Settings
        if (currentRoute != '/settings') {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const SettingsScreen(),
              settings: const RouteSettings(name: '/settings'),
            ),
            (route) => false,
          );
        }
        break;
    }
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  
  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index != currentIndex) {
          NavigationService.navigateToTab(context, index);
        }
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF4285F4),
      unselectedItemColor: const Color(0xFF9CA3AF),
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          activeIcon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}

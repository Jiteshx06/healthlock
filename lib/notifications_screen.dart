import 'package:flutter/material.dart';
import 'navigation_service.dart';

class NotificationsScreen extends StatefulWidget {
  final bool showBottomNav;

  const NotificationsScreen({
    super.key,
    this.showBottomNav = true,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Medical', 'Security', 'Updates'];

  final List<NotificationItem> _notifications = [
    NotificationItem(
      icon: Icons.person_outline,
      title: 'Dr. Rao viewed your CBC Report',
      time: '10:32 AM',
      isUnread: true,
      category: 'Medical',
    ),
    NotificationItem(
      icon: Icons.security_outlined,
      title: 'New sign-in from Chrome Browser',
      time: '9:45 AM',
      isUnread: true,
      category: 'Security',
    ),
    NotificationItem(
      icon: Icons.calendar_today_outlined,
      title: 'Upcoming appointment with Dr. Smith tomorrow at 10:00 AM',
      time: 'Yesterday',
      isUnread: false,
      category: 'Medical',
    ),
    NotificationItem(
      icon: Icons.assignment_outlined,
      title: 'Your blood test results are ready to view',
      time: 'Yesterday',
      isUnread: false,
      category: 'Medical',
    ),
    NotificationItem(
      icon: Icons.healing_outlined,
      title: 'Prescription refill request approved',
      time: '2 days ago',
      isUnread: false,
      category: 'Medical',
    ),
    NotificationItem(
      icon: Icons.receipt_outlined,
      title: 'Payment of \$150 processed successfully',
      time: '2 days ago',
      isUnread: false,
      category: 'Updates',
    ),
  ];

  List<NotificationItem> get _filteredNotifications {
    if (_selectedCategory == 'All') {
      return _notifications;
    }
    return _notifications.where((notification) => notification.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildContent(context);

    if (!widget.showBottomNav) {
      return content;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: content,
      bottomNavigationBar: const CustomBottomNavigationBar(
        currentIndex: 1,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Clear all notifications
                      setState(() {
                        _notifications.clear();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All notifications cleared'),
                          backgroundColor: Color(0xFF10B981),
                        ),
                      );
                    },
                    child: const Text(
                      'Clear All',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF4285F4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Category Filter Tabs
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < _categories.length - 1 ? 12.0 : 0,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF4285F4) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF4285F4) : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Notifications List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                itemCount: _filteredNotifications.length,
                itemBuilder: (context, index) {
                  final notification = _filteredNotifications[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildNotificationItem(notification),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    return GestureDetector(
      onTap: () {
        // Mark notification as read when tapped
        if (notification.isUnread) {
          setState(() {
            notification.isUnread = false;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF6B7280).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                notification.icon,
                color: const Color(0xFF6B7280),
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: notification.isUnread ? FontWeight.w600 : FontWeight.w500,
                      color: const Color(0xFF1A1A1A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: const Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          notification.time,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Unread indicator
            if (notification.isUnread)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF4285F4),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class NotificationItem {
  final IconData icon;
  final String title;
  final String time;
  bool isUnread;
  final String category;

  NotificationItem({
    required this.icon,
    required this.title,
    required this.time,
    required this.isUnread,
    required this.category,
  });
}

import 'package:flutter/material.dart';
import 'navigation_service.dart';
import 'audit_log_screen.dart';
import 'api_service.dart';
import 'token_service.dart';

class NotificationsScreen extends StatefulWidget {
  final bool showBottomNav;

  const NotificationsScreen({super.key, this.showBottomNav = true});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedCategory = 'All';
<<<<<<< HEAD
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  final List<String> _categories = ['All', 'Medical', 'Security', 'Updates'];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final userId = await TokenService.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final auditLogs = await ApiService.getAllLogs();

      // Filter logs by patient ID (only show logs for this patient)
      final filteredLogs = auditLogs.where((log) => log.patientId == userId).toList();

      // Convert audit logs to notifications
      final notifications = filteredLogs.map((log) => NotificationItem(
        icon: Icons.person_outline,
        title: 'Dr. ${log.doctorName} viewed your ${log.fileName}',
        time: log.formattedDateTime,
        isUnread: _isRecentLog(log),
        category: 'Medical',
      )).toList();

      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  bool _isRecentLog(AuditLogEntry log) {
    try {
      final logDate = DateTime.parse(log.createdAt);
      final now = DateTime.now();
      final difference = now.difference(logDate);
      return difference.inHours < 24; // Consider logs from last 24 hours as unread
    } catch (e) {
      return false;
    }
  }
=======

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
>>>>>>> f5945bda9cd598212d24485cf3d8ddb19e5edaee

  List<NotificationItem> get _filteredNotifications {
    if (_selectedCategory == 'All') {
      return _notifications;
    }
    return _notifications
        .where((notification) => notification.category == _selectedCategory)
        .toList();
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
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 1),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AuditLogScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.history_outlined,
                            size: 16,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Audit Log',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4285F4),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
<<<<<<< HEAD
                            // Mark all notifications as read
                            setState(() {
                              for (var notification in _notifications) {
                                notification.isUnread = false;
                              }
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('All notifications marked as read'),
=======
                            // Clear all notifications
                            setState(() {
                              _notifications.clear();
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('All notifications cleared'),
>>>>>>> f5945bda9cd598212d24485cf3d8ddb19e5edaee
                                backgroundColor: Color(0xFF10B981),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF4285F4)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: const Text(
<<<<<<< HEAD
                            'Mark All Read',
=======
                            'Clear All',
>>>>>>> f5945bda9cd598212d24485cf3d8ddb19e5edaee
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4285F4),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
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
                          color: isSelected
                              ? const Color(0xFF4285F4)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF4285F4)
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF6B7280),
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
<<<<<<< HEAD
              child: _buildNotificationsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4285F4)),
            ),
            SizedBox(height: 16),
            Text(
              'Loading notifications...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
=======
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
>>>>>>> f5945bda9cd598212d24485cf3d8ddb19e5edaee
              ),
            ),
          ],
        ),
<<<<<<< HEAD
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 16),
            const Text(
              'Error loading notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadNotifications,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4285F4),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredNotifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.notifications_none_outlined,
              size: 64,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 16),
            const Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You\'ll see notifications when doctors view your files',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
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
=======
>>>>>>> f5945bda9cd598212d24485cf3d8ddb19e5edaee
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
              color: Colors.black.withValues(alpha: 0.05),
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
                color: const Color(0xFF6B7280).withValues(alpha: 0.1),
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
                      fontWeight: notification.isUnread
                          ? FontWeight.w600
                          : FontWeight.w500,
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

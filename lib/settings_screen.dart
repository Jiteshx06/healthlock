import 'package:flutter/material.dart';
import 'navigation_service.dart';

class SettingsScreen extends StatefulWidget {
  final bool showBottomNav;

  const SettingsScreen({
    super.key,
    this.showBottomNav = true,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricEnabled = true;
  bool _pushNotificationsEnabled = false;
  bool _emailAlertsEnabled = false;

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
        currentIndex: 2,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Profile Section
              Column(
                children: [
                  // Profile Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: const Color(0xFF4285F4),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Name
                  const Text(
                    'John Anderson',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Age
                  const Text(
                    '42 years old',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Settings Sections
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Account Section
                    _buildSectionHeader('Account'),
                    const SizedBox(height: 12),
                    
                    _buildSettingItem(
                      icon: Icons.person_outline,
                      title: 'Personal Information',
                      hasArrow: true,
                      onTap: () {
                        print('Personal Information tapped');
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildSettingItem(
                      icon: Icons.email_outlined,
                      title: 'Contact Details',
                      hasArrow: true,
                      onTap: () {
                        print('Contact Details tapped');
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Security Section
                    _buildSectionHeader('Security'),
                    const SizedBox(height: 12),
                    
                    _buildSettingItem(
                      icon: Icons.lock_outline,
                      title: 'Change PIN',
                      hasArrow: true,
                      onTap: () {
                        print('Change PIN tapped');
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildSettingItem(
                      icon: Icons.fingerprint,
                      title: 'Enable Biometric',
                      hasSwitch: true,
                      switchValue: _biometricEnabled,
                      onSwitchChanged: (value) {
                        setState(() {
                          _biometricEnabled = value;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildSettingItem(
                      icon: Icons.shield_outlined,
                      title: 'Recovery Contact',
                      hasArrow: true,
                      onTap: () {
                        print('Recovery Contact tapped');
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Notifications Section
                    _buildSectionHeader('Notifications'),
                    const SizedBox(height: 12),
                    
                    _buildSettingItem(
                      icon: Icons.notifications_outlined,
                      title: 'Push Notifications',
                      hasSwitch: true,
                      switchValue: _pushNotificationsEnabled,
                      onSwitchChanged: (value) {
                        setState(() {
                          _pushNotificationsEnabled = value;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildSettingItem(
                      icon: Icons.email_outlined,
                      title: 'Email Alerts',
                      hasSwitch: true,
                      switchValue: _emailAlertsEnabled,
                      onSwitchChanged: (value) {
                        setState(() {
                          _emailAlertsEnabled = value;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Logout Button
                    Container(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showLogoutDialog();
                        },
                        icon: const Icon(
                          Icons.logout,
                          color: Color(0xFFEF4444),
                        ),
                        label: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444).withOpacity(0.1),
                          foregroundColor: const Color(0xFFEF4444),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 100), // Space for bottom navigation
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF6B7280),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    bool hasArrow = false,
    bool hasSwitch = false,
    bool switchValue = false,
    VoidCallback? onTap,
    ValueChanged<bool>? onSwitchChanged,
  }) {
    return GestureDetector(
      onTap: hasSwitch ? null : onTap,
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
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF4285F4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF4285F4),
                size: 20,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            
            if (hasArrow)
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF9CA3AF),
                size: 20,
              ),
            
            if (hasSwitch)
              Switch(
                value: switchValue,
                onChanged: onSwitchChanged,
                activeColor: const Color(0xFF4285F4),
                inactiveThumbColor: const Color(0xFF9CA3AF),
                inactiveTrackColor: const Color(0xFFE5E7EB),
              ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate back to login screen
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Color(0xFFEF4444)),
              ),
            ),
          ],
        );
      },
    );
  }
}

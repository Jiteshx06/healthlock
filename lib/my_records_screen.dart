import 'package:flutter/material.dart';
import 'my_records_detail_screen.dart';
import 'upload_document_screen.dart';
import 'share_history_screen.dart';
import 'navigation_service.dart';
import 'responsive_utils.dart';
import 'api_service.dart';
import 'analyze_records_screen.dart';

class MyRecordsScreen extends StatefulWidget {
  final bool showBottomNav;

  const MyRecordsScreen({super.key, this.showBottomNav = true});

  @override
  State<MyRecordsScreen> createState() => _MyRecordsScreenState();
}

class _MyRecordsScreenState extends State<MyRecordsScreen> {
  int _totalFiles = 0;
  bool _isLoadingCount = true;

  @override
  void initState() {
    super.initState();
    _loadFileCount();
  }

  Future<void> _loadFileCount() async {
    try {
      final response = await ApiService.getUserFiles();
      if (mounted) {
        setState(() {
          _totalFiles = response.totalFiles;
          _isLoadingCount = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _totalFiles = 0;
          _isLoadingCount = false;
        });
      }
    }
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
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 0),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: ResponsiveUtils.getResponsivePadding(context),
              child: Row(
                children: [
                  // Profile Avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: const Color(0xFF4285F4),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // App Title
                  Expanded(
                    child: Text(
                      'HealthLock',
                      style: AppTextStyles.heading3(context),
                    ),
                  ),
                ],
              ),
            ),

            // Greeting Section
            Padding(
              padding: ResponsiveUtils.getResponsiveHorizontalPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello, Sarah', style: AppTextStyles.heading2(context)),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 4),
                  ),
                  Text(
                    'Manage your health records securely',
                    style: AppTextStyles.bodyMedium(
                      context,
                    ).copyWith(color: const Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action Cards Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  // My Records Card
                  _buildActionCard(
                    icon: Icons.description_outlined,
                    iconColor: const Color(0xFF4285F4),
                    title: 'My Records',
                    subtitle: _isLoadingCount
                        ? 'Loading...'
                        : '$_totalFiles document${_totalFiles != 1 ? 's' : ''}',
                    onTap: () {
                      // Navigate to My Records Detail Screen
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const MyRecordsDetailScreen(),
                            ),
                          )
                          .then((_) {
                            // Refresh count when returning
                            _loadFileCount();
                          });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Upload New Report Card
                  _buildActionCard(
                    icon: Icons.cloud_upload_outlined,
                    iconColor: const Color(0xFF4285F4),
                    title: 'Upload New Report',
                    subtitle: 'Last upload: 2 days ago',
                    onTap: () {
                      // Navigate to Upload Document Screen
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const UploadDocumentScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Share History Card
                  _buildActionCard(
                    icon: Icons.lock_outline,
                    iconColor: const Color(0xFF4285F4),
                    title: 'Share History',
                    subtitle: '3 recent shares',
                    onTap: () {
                      // Show file selection for sharing
                      _showFileSelectionForSharing();
                    },
                  ),

                  const SizedBox(height: 16),

                  // Analyze Records Card
                  _buildActionCard(
                    icon: Icons.analytics_outlined,
                    iconColor: const Color(0xFF10B981),
                    title: 'Analyze Records',
                    subtitle: 'AI health insights',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AnalyzeRecordsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Recent Activity Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Activity Items
                  _buildActivityItem(
                    title: 'Blood Test Results',
                    subtitle: '2 hours ago',
                    description: 'Shared with Dr. Smith',
                    icon: Icons.access_time,
                  ),

                  const SizedBox(height: 20),

                  _buildActivityItem(
                    title: 'X-Ray Report',
                    subtitle: 'Yesterday',
                    description: 'Uploaded new document',
                    icon: Icons.access_time,
                  ),

                  const SizedBox(height: 20),

                  _buildActivityItem(
                    title: 'Vaccination Record',
                    subtitle: '2 days ago',
                    description: 'Updated information',
                    icon: Icons.access_time,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100), // Space for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
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
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF6B7280).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: const Color(0xFF6B7280), size: 16),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showFileSelectionForSharing() async {
    try {
      // Fetch user files
      final userFilesResponse = await ApiService.getUserFiles();

      if (userFilesResponse.files.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No files available to share'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Show file selection dialog
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select File to Share',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: userFilesResponse.files.length,
                    itemBuilder: (context, index) {
                      final file = userFilesResponse.files[index];
                      return _buildFileSelectionItem(file);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load files: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildFileSelectionItem(UserFileData file) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF4285F4).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getFileIcon(file.fileName),
            color: const Color(0xFF4285F4),
            size: 24,
          ),
        ),
        title: Text(
          file.fileName,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Uploaded: ${_formatDate(file.uploadedAt)}',
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
        onTap: () {
          Navigator.of(context).pop(); // Close the selection dialog
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ShareHistoryScreen(file: file),
            ),
          );
        },
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

import 'package:flutter/material.dart';
import 'my_records_detail_screen.dart';
import 'upload_document_screen.dart';
import 'share_history_screen.dart';
import 'navigation_service.dart';
import 'api_service.dart';
import 'token_service.dart';
import 'analyze_records_screen.dart';
import 'chat_screen.dart';
import 'qr_scanner_screen.dart';
import 'audit_log_screen.dart';
import 'doctor_shared_files_screen.dart';
import 'patient_shared_files_screen.dart';
import 'notifications_screen.dart';

class MyRecordsScreen extends StatefulWidget {
  final bool showBottomNav;

  const MyRecordsScreen({super.key, this.showBottomNav = true});

  @override
  State<MyRecordsScreen> createState() => _MyRecordsScreenState();
}

class _MyRecordsScreenState extends State<MyRecordsScreen> {
  int _totalFiles = 0;
  int _sharedFilesCount = 0;
  bool _isLoadingCount = true;
  bool _isDoctor = false;
  String _userName = 'HealthLock User';

  @override
  void initState() {
    super.initState();
    _loadFileCount();
    _loadSharedFilesCount();
    _loadUserName();
    _checkUserRole();
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

  Future<void> _loadSharedFilesCount() async {
    try {
      final userRole = await TokenService.getUserRole();
      if (userRole == 'doctor') {
        final userId = await TokenService.getUserId();
        if (userId != null) {
          final allSharedFiles = await ApiService.getAllSharedFiles();

          // Filter files to count only those shared by this doctor
          final doctorFiles = allSharedFiles.where((file) => file.doctorId == userId).toList();

          if (mounted) {
            setState(() {
              _sharedFilesCount = doctorFiles.length;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _sharedFilesCount = 0;
        });
      }
    }
  }

  Future<void> _loadUserName() async {
    try {
      final name = await TokenService.getUserName();
      if (mounted && name != null) {
        setState(() {
          _userName = name;
        });
      }
    } catch (e) {
      // Keep default name if error
    }
  }

  Future<void> _checkUserRole() async {
    try {
      final role = await TokenService.getUserRole();
      if (mounted) {
        setState(() {
          _isDoctor = role == 'doctor';
        });
      }
    } catch (e) {
      print('Error checking user role: $e');
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
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row with Profile and Notifications
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const AuditLogScreen(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.history_outlined,
                              color: Color(0xFF6B7280),
                              size: 24,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // Navigate to notifications
                            },
                            icon: const Icon(
                              Icons.notifications_outlined,
                              color: Color(0xFF6B7280),
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Main Title
                  const Text(
                    'Health solution\nmade simple 🏥',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: Color(0xFF9CA3AF),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Search health records...',
                            style: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.tune,
                          color: Color(0xFF9CA3AF),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Stats Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4285F4), Color(0xFF1E40AF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.folder_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isLoadingCount
                                ? 'Loading...'
                                : '$_totalFiles Records',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(
                            'Stored securely in your account',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Health Services Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Health Services',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'See all',
                          style: TextStyle(
                            color: Color(0xFF4285F4),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Services Grid
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                    children: _buildServiceCards(),
                  ),

                  const SizedBox(height: 16),

                  // Share History Card
                  _buildFeatureCard(
                    icon: Icons.share_outlined,
                    iconColor: const Color(0xFFF59E0B),
                    title: 'Share Medical Files',
                    subtitle: 'Securely share with healthcare providers',
                    onTap: () {
                      _showFileSelectionForSharing();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),



            const SizedBox(height: 100), // Space for bottom navigation
          ],
        ),
      ),
    );
  }



  void _showFileSelectionForSharing() async {
    try {
      // Fetch user files
      final userFilesResponse = await ApiService.getUserFiles();

      if (!mounted) return;

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
          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    Flexible(
                      child: ListView.builder(
                        controller: scrollController,
                        shrinkWrap: true,
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
        },
      );
    } catch (e) {
      if (!mounted) return;
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
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop(); // Close the selection dialog
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ShareHistoryScreen(file: file),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF4285F4).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getFileIcon(file.fileName),
                  color: const Color(0xFF4285F4),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      file.fileName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Uploaded: ${_formatDate(file.uploadedAt)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF9CA3AF),
                size: 20,
              ),
            ],
          ),
        ),
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

  List<Widget> _buildServiceCards() {
    List<Widget> cards = [];

    if (_isDoctor) {
      // Doctor-specific services
      cards.addAll([
        _buildServiceCard(
          icon: Icons.folder_outlined,
          iconColor: const Color(0xFF3B82F6),
          title: 'Own Records',
          onTap: () {
            Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (context) => const MyRecordsDetailScreen(),
                  ),
                )
                .then((_) {
                  _loadFileCount();
                });
          },
        ),
        _buildServiceCard(
          icon: Icons.folder_shared_outlined,
          iconColor: const Color(0xFF10B981),
          title: 'Patients Records',
          count: _sharedFilesCount,
          onTap: () {
            Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (context) => const DoctorSharedFilesScreen(),
                  ),
                )
                .then((_) {
                  _loadFileCount();
                  _loadSharedFilesCount();
                });
          },
        ),
        _buildServiceCard(
          icon: Icons.qr_code_scanner,
          iconColor: const Color(0xFF8B5CF6),
          title: 'Receive File',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const QRScannerScreen()),
            );
          },
        ),
        _buildServiceCard(
          icon: Icons.share_outlined,
          iconColor: const Color(0xFFF59E0B),
          title: 'Share Medical Files',
          onTap: () {
            _showFileSelectionForSharing();
          },
        ),
      ]);
    } else {
      // Patient-specific services
      cards.addAll([
        _buildServiceCard(
          icon: Icons.folder_outlined,
          iconColor: const Color(0xFF3B82F6),
          title: 'My Records',
          onTap: () {
            Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (context) => const MyRecordsDetailScreen(),
                  ),
                )
                .then((_) {
                  _loadFileCount();
                });
          },
        ),
        _buildServiceCard(
          icon: Icons.upload_file_outlined,
          iconColor: const Color(0xFFEF4444),
          title: 'Upload',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const UploadDocumentScreen(),
              ),
            );
          },
        ),
        _buildServiceCard(
          icon: Icons.analytics_outlined,
          iconColor: const Color(0xFF10B981),
          title: 'Analyze',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AnalyzeRecordsScreen(),
              ),
            );
          },
        ),
        _buildServiceCard(
          icon: Icons.smart_toy_outlined,
          iconColor: const Color(0xFF8B5CF6),
          title: 'AI Chat',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatScreen()),
            );
          },
        ),
        _buildServiceCard(
          icon: Icons.folder_shared_outlined,
          iconColor: const Color(0xFF10B981),
          title: 'Shared Files',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const PatientSharedFilesScreen(),
              ),
            );
          },
        ),
        _buildServiceCard(
          icon: Icons.qr_code_scanner,
          iconColor: const Color(0xFFF59E0B),
          title: 'Recive File',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const QRScannerScreen()),
            );
          },
        ),
      ]);
    }

    return cards;
  }

  Widget _buildServiceCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    int? count,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                if (count != null && count > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
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
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
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
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF9CA3AF),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

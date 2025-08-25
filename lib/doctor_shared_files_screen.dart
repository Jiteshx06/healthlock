import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_service.dart';
import 'token_service.dart';
import 'my_records_detail_screen.dart';

class DoctorSharedFilesScreen extends StatefulWidget {
  const DoctorSharedFilesScreen({super.key});

  @override
  State<DoctorSharedFilesScreen> createState() => _DoctorSharedFilesScreenState();
}

class _DoctorSharedFilesScreenState extends State<DoctorSharedFilesScreen> {
  List<SharedFileEntry> _sharedFiles = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSharedFiles();
  }

  Future<void> _loadSharedFiles() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final userId = await TokenService.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final allFiles = await ApiService.getAllSharedFiles();

      // Filter files to show only those shared by this doctor
      final doctorFiles = allFiles.where((file) => file.doctorId == userId).toList();

      if (mounted) {
        setState(() {
          _sharedFiles = doctorFiles;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Shared Patient Files',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF4285F4),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MyRecordsDetailScreen(),
                ),
              );
            },
            tooltip: 'My Records',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSharedFiles,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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
              'Loading shared files...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
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
            Text(
              'Error loading files',
              style: const TextStyle(
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
              onPressed: _loadSharedFiles,
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

    if (_sharedFiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.folder_outlined,
              size: 64,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 16),
            const Text(
              'No shared files yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Files downloaded from patient QR codes will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan QR Code'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4285F4),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSharedFiles,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _sharedFiles.length,
        itemBuilder: (context, index) {
          final file = _sharedFiles[index];
          return _buildFileCard(file);
        },
      ),
    );
  }

  Widget _buildFileCard(SharedFileEntry file) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _viewFile(file),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4285F4).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getFileTypeIcon(file.fileName),
                      color: const Color(0xFF4285F4),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.fileName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Patient: ${file.patientName}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showFileOptions(file),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Shared on ${file.formattedDate} at ${file.formattedTime}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFileTypeIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _viewFile(SharedFileEntry file) async {
    try {
      // Validate URL first
      if (file.fileUrl.isEmpty) {
        _showErrorMessage('File URL is empty');
        return;
      }

      // Check if URL is valid
      if (!file.fileUrl.startsWith('http://') && !file.fileUrl.startsWith('https://')) {
        _showErrorMessage('Invalid file URL format: ${file.fileUrl}');
        return;
      }

      // Add log entry when doctor views the file
      final userId = await TokenService.getUserId();
      final userName = await TokenService.getUserName();

      if (userId != null && userName != null) {
        await ApiService.addViewLog(
          doctorId: userId,
          doctorName: userName,
          patientId: file.patientId,
          fileName: file.fileName,
        );
      }

      print('Attempting to open URL: ${file.fileUrl}');
      final uri = Uri.parse(file.fileUrl);
      print('Parsed URI: $uri');

      // Try to open in-app first, then fallback to external
      try {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
        print('URL launched with inAppBrowserView');
      } catch (browserError) {
        print('Failed to launch with inAppBrowserView, trying externalApplication...');
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          print('URL launched with externalApplication');
        } catch (externalError) {
          print('Failed to launch with externalApplication, trying platformDefault...');
          try {
            await launchUrl(uri, mode: LaunchMode.platformDefault);
            print('URL launched with platformDefault');
          } catch (platformError) {
            print('All launch methods failed. Errors:');
            print('Browser: $browserError');
            print('External: $externalError');
            print('Platform: $platformError');
            _showErrorMessage('Cannot open file. Please install a browser or file viewer app.');
          }
        }
      }
    } catch (e) {
      print('Error opening file: $e');
      _showErrorMessage('Error opening file: $e');
    }
  }

  void _showFileOptions(SharedFileEntry file) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.open_in_browser),
              title: const Text('Open File'),
              onTap: () {
                Navigator.pop(context);
                _viewFile(file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('File Details'),
              onTap: () {
                Navigator.pop(context);
                _showFileDetails(file);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFileDetails(SharedFileEntry file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('File Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('File Name', file.fileName),
            _buildDetailRow('Patient ID', file.patientId),
            _buildDetailRow('Shared On', '${file.formattedDate} at ${file.formattedTime}'),
            _buildDetailRow('Last Accessed', file.formattedLastAccessed),
            _buildDetailRow('File URL', file.fileUrl),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

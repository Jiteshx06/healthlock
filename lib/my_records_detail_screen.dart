import 'package:flutter/material.dart';
import 'upload_document_screen.dart';
import 'api_service.dart';
import 'responsive_utils.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'file_viewer_screen.dart';

class MyRecordsDetailScreen extends StatefulWidget {
  const MyRecordsDetailScreen({super.key});

  @override
  State<MyRecordsDetailScreen> createState() => _MyRecordsDetailScreenState();
}

class _MyRecordsDetailScreenState extends State<MyRecordsDetailScreen> {
  List<UserFileData> _userFiles = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserFiles();
  }

  Future<void> _fetchUserFiles() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await ApiService.getUserFiles();

      if (mounted) {
        setState(() {
          _userFiles = response.files;
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

  Future<void> _refreshFiles() async {
    await _fetchUserFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF1A1A1A),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'My Records',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Color(0xFF1A1A1A),
            ),
            onPressed: _refreshFiles,
          ),
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Color(0xFF1A1A1A),
            ),
            onPressed: () {
              // Implement search functionality
              print('Search tapped');
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Records count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Text(
              _isLoading ? 'Loading...' : '${_userFiles.length} Records',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          
          // Records list
          Expanded(
            child: _buildRecordsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Upload Document Screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const UploadDocumentScreen(),
            ),
          ).then((_) {
            // Refresh the files list when returning from upload
            _refreshFiles();
          });
        },
        backgroundColor: const Color(0xFF4285F4),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildRecordsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF4285F4),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: ResponsiveUtils.getResponsiveSpacing(context, 64),
              color: Colors.red.shade400,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
            Text(
              'Error loading files',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700,
              ),
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                color: Colors.red.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
            ElevatedButton(
              onPressed: _refreshFiles,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4285F4),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_userFiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: ResponsiveUtils.getResponsiveSpacing(context, 64),
              color: Colors.grey.shade400,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
            Text(
              'No files uploaded yet',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
            Text(
              'Upload your first medical document to get started',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const UploadDocumentScreen(),
                  ),
                ).then((_) => _refreshFiles());
              },
              icon: const Icon(Icons.cloud_upload_outlined),
              label: const Text('Upload Document'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4285F4),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      itemCount: _userFiles.length,
      itemBuilder: (context, index) {
        final file = _userFiles[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildFileItem(file),
        );
      },
    );
  }

  Widget _buildFileItem(UserFileData file) {
    return GestureDetector(
      onTap: () {
        // Handle file tap - directly open the file
        print('Opening file: ${file.fileName}');
        _viewFile(file);
      },
      onLongPress: () {
        // Long press shows file options menu
        _showFileDetails(file);
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
          children: [
            // Icon based on file type
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getFileTypeColor(file.fileName).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getFileTypeIcon(file.fileName),
                color: _getFileTypeColor(file.fileName),
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // Content
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getFileTypeColor(file.fileName).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getFileTypeCategory(file.fileName),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getFileTypeColor(file.fileName),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _formatUploadDate(file.uploadedAt),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // More options
            IconButton(
              icon: const Icon(
                Icons.more_vert,
                color: Color(0xFF9CA3AF),
                size: 20,
              ),
              onPressed: () {
                _showFileOptions(context, file);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for file type detection
  IconData _getFileTypeIcon(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
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
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileTypeColor(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return const Color(0xFFDC2626);
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return const Color(0xFF10B981);
      case 'doc':
      case 'docx':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getFileTypeCategory(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return 'PDF';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return 'Image';
      case 'doc':
      case 'docx':
        return 'Document';
      default:
        return 'File';
    }
  }

  String _formatUploadDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Uploaded today';
      } else if (difference.inDays == 1) {
        return 'Uploaded yesterday';
      } else if (difference.inDays < 7) {
        return 'Uploaded ${difference.inDays} days ago';
      } else {
        return 'Uploaded ${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Upload date unknown';
    }
  }

  void _showFileDetails(UserFileData file) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getFileTypeColor(file.fileName).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getFileTypeIcon(file.fileName),
                      color: _getFileTypeColor(file.fileName),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.fileName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatUploadDate(file.uploadedAt),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Actions
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildActionTile(
                    icon: Icons.visibility_outlined,
                    title: 'View File',
                    onTap: () {
                      Navigator.pop(context);
                      _viewFile(file);
                    },
                  ),
                  _buildActionTile(
                    icon: Icons.open_in_browser,
                    title: 'Open in Browser',
                    onTap: () {
                      Navigator.pop(context);
                      _openInBrowser(file);
                    },
                  ),
                  _buildActionTile(
                    icon: Icons.share_outlined,
                    title: 'Share File',
                    onTap: () {
                      Navigator.pop(context);
                      _shareFile(file);
                    },
                  ),
                  _buildActionTile(
                    icon: Icons.download_outlined,
                    title: 'Download File',
                    onTap: () {
                      Navigator.pop(context);
                      _downloadFile(file);
                    },
                  ),
                  _buildActionTile(
                    icon: Icons.info_outline,
                    title: 'File Details',
                    onTap: () {
                      Navigator.pop(context);
                      _showFileInfo(file);
                    },
                  ),
                  _buildActionTile(
                    icon: Icons.delete_outline,
                    title: 'Delete File',
                    textColor: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      _confirmDeleteFile(file);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? const Color(0xFF4285F4),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? const Color(0xFF1A1A1A),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showFileInfo(UserFileData file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('File Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('File Name', file.fileName),
            _buildInfoRow('File ID', file.id),
            _buildInfoRow('Upload Date', _formatUploadDate(file.uploadedAt)),
            if (file.lastAccessed != null)
              _buildInfoRow('Last Accessed', _formatUploadDate(file.lastAccessed!)),
            _buildInfoRow('File URL', file.fileUrl),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteFile(UserFileData file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete "${file.fileName}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement file deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('File deletion will be implemented')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showFileOptions(BuildContext context, UserFileData file) {
    // This method is now handled by _showFileDetails
    _showFileDetails(file);
  }

  // View file using WebView-based viewer
  Future<void> _viewFile(UserFileData file) async {
    try {
      // Navigate to the WebView-based file viewer
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FileViewerScreen(file: file),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open file: ${file.fileName}'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _viewFile(file),
          ),
        ),
      );
    }
  }

  // Open file in external browser as fallback
  Future<void> _openInBrowser(UserFileData file) async {
    try {
      final Uri fileUri = Uri.parse(file.fileUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening ${file.fileName} in browser...'),
          backgroundColor: const Color(0xFF4285F4),
          duration: const Duration(seconds: 2),
        ),
      );

      if (await canLaunchUrl(fileUri)) {
        await launchUrl(
          fileUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        await launchUrl(
          fileUri,
          mode: LaunchMode.platformDefault,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open in browser: ${file.fileName}'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Copy Link',
            textColor: Colors.white,
            onPressed: () => _shareFile(file),
          ),
        ),
      );
    }
  }



  // Share file URL
  Future<void> _shareFile(UserFileData file) async {
    try {
      await Clipboard.setData(ClipboardData(text: file.fileUrl));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${file.fileName} link copied to clipboard'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Download file
  Future<void> _downloadFile(UserFileData file) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Downloading ${file.fileName}...'),
            ],
          ),
        ),
      );

      // Get downloads directory
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          downloadsDir = await getExternalStorageDirectory();
        }
      } else {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      if (downloadsDir == null) {
        throw Exception('Could not access downloads directory');
      }

      // Create file path
      final filePath = '${downloadsDir.path}/${file.fileName}';

      // Download file using Dio
      final dio = Dio();
      await dio.download(file.fileUrl, filePath);

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${file.fileName} downloaded successfully'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Open',
            textColor: Colors.white,
            onPressed: () => _viewFile(file),
          ),
        ),
      );
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _downloadFile(file),
          ),
        ),
      );
    }
  }
}

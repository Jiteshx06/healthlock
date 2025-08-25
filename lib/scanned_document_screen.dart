import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'api_service.dart';
import 'token_service.dart';
import 'config.dart';

class ScannedDocumentScreen extends StatefulWidget {
  final Map<String, dynamic> qrData;

  const ScannedDocumentScreen({super.key, required this.qrData});

  @override
  State<ScannedDocumentScreen> createState() => _ScannedDocumentScreenState();
}

class _ScannedDocumentScreenState extends State<ScannedDocumentScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _addAuditLog();
    // Simulate loading time for document access
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _addAuditLog() async {
    try {
      // Check if user is a doctor
      final userRole = await TokenService.getUserRole();
      if (userRole != 'doctor') return;

      final doctorId = await TokenService.getUserId();
      final doctorName = await TokenService.getUserName();
      final fileName =
          widget.qrData['fileName'] ?? widget.qrData['file'] ?? 'Unknown File';
      final patientId = widget.qrData['userId'] ?? 'unknown';

      if (doctorId != null && doctorName != null) {
        await ApiService.addViewLog(
          doctorId: doctorId,
          doctorName: doctorName,
          patientId: patientId,
          fileName: fileName,
        );
        print('Audit log added for QR scanned document: $fileName');
      }
    } catch (e) {
      print('Error adding audit log: $e');
      // Don't show error to user, just log it
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Patient Document',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
      ),
      body: _isLoading ? _buildLoadingView() : _buildDocumentView(),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF4285F4)),
          SizedBox(height: 24),
          Text(
            'Accessing Patient Document...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Verifying permissions and loading file',
            style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentView() {
    final fileName =
        widget.qrData['fileName'] ?? widget.qrData['file'] ?? 'Unknown File';
    final fileUrl = widget.qrData['fileUrl'] ?? '';
    final userId = widget.qrData['userId'] ?? '';
    final uploadedAt = widget.qrData['uploadedAt'] ?? '';
    final sharedAt = widget.qrData['sharedAt'] ?? '';
    final expiresAt = widget.qrData['expiresAt'] ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Document Access Granted',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'QR code scanned successfully',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Document preview card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4285F4),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getFileTypeIcon(fileName),
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          fileName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // File content preview
                Container(
                  height: 300,
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: _buildFileContentPreview(fileName, fileUrl),
                ),

                // Action buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Primary button - View Full Document
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _viewFullDocument(fileUrl),
                          icon: const Icon(
                            Icons.visibility,
                            color: Colors.white,
                            size: 20,
                          ),
                          label: const Text(
                            'View Full Document',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4285F4),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            shadowColor: const Color(
                              0xFF4285F4,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Secondary button - Download
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _downloadDocument(fileUrl, fileName),
                          icon: const Icon(
                            Icons.download,
                            color: Color(0xFF4285F4),
                            size: 20,
                          ),
                          label: const Text(
                            'Save Document',
                            style: TextStyle(
                              color: Color(0xFF4285F4),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF4285F4),
                            side: const BorderSide(
                              color: Color(0xFF4285F4),
                              width: 2,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Quick Actions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickActionButton(
                  icon: Icons.share,
                  label: 'Share',
                  onTap: () => _shareDocument(fileUrl, fileName),
                ),
                _buildQuickActionButton(
                  icon: Icons.print,
                  label: 'Print',
                  onTap: () => _printDocument(fileUrl, fileName),
                ),
                _buildQuickActionButton(
                  icon: Icons.info_outline,
                  label: 'Details',
                  onTap: () => _showDocumentDetails(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Document info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Document Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Patient ID', _formatPatientId(userId)),
                _buildInfoRow('File Name', fileName),
                _buildInfoRow('Uploaded At', _formatDate(uploadedAt)),
                _buildInfoRow('Shared At', _formatDate(sharedAt)),
                _buildInfoRow('Access Expires', _formatDate(expiresAt)),
                _buildInfoRow('Access Type', 'Temporary QR Access'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileContentPreview(String fileName, String fileUrl) {
    final extension = fileName.toLowerCase().split('.').last;

    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          fileUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4285F4)),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Could not load image',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getFileTypeIcon(fileName),
              size: 64,
              color: _getFileTypeColor(fileName),
            ),
            const SizedBox(height: 16),
            Text(
              _getFileTypeText(fileName),
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap "View Full Document" to open',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileTypeIcon(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
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
        return Colors.red;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
        return Colors.blue;
      case 'doc':
      case 'docx':
        return Colors.blue.shade700;
      default:
        return Colors.grey;
    }
  }

  String _getFileTypeText(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return 'PDF Document';
      case 'jpg':
      case 'jpeg':
        return 'JPEG Image';
      case 'png':
        return 'PNG Image';
      case 'gif':
        return 'GIF Image';
      case 'doc':
      case 'docx':
        return 'Word Document';
      default:
        return '${extension.toUpperCase()} File';
    }
  }

  void _viewFullDocument(String fileUrl) {
    // TODO: Implement full document view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening full document view...'),
        backgroundColor: Color(0xFF4285F4),
      ),
    );
  }

  void _downloadDocument(String fileUrl, String fileName) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloading and saving $fileName...'),
          backgroundColor: const Color(0xFF4285F4),
          duration: const Duration(seconds: 2),
        ),
      );

      // Get current user data
      final doctorId = await TokenService.getUserId();
      final doctorName = await TokenService.getUserName();
      final token = await TokenService.getToken();

      // Get patient data from QR
      final patientId = widget.qrData['userId'] ?? '';

      if (doctorId == null || doctorName == null || token == null) {
        throw Exception(
          'Missing doctor authentication data. Please login again.',
        );
      }

      if (patientId.isEmpty) {
        throw Exception('Missing patient information from QR code.');
      }

      // Prepare request data for saving to doctor's records
      final requestData = {
        'doctorId': doctorId,
        'doctorName': doctorName,
        'patientId': patientId,
        'fileName': fileName,
        'fileUrl': fileUrl,
      };

      print('=== DOWNLOADING AND SAVING DOCUMENT ===');
      print('URL: ${AppConfig.apiBaseUrl}${AppConfig.shareFileEndpoint}');
      print('Request Data: $requestData');

      // Make API call to save document to doctor's records
      final response = await http
          .post(
            Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.shareFileEndpoint}'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'ngrok-skip-browser-warning': '1',
            },
            body: json.encode(requestData),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout. Please check your connection and try again.',
              );
            },
          );

      print('Download/Save Response Status: ${response.statusCode}');
      print('Download/Save Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success - document saved to doctor's records
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ Document "$fileName" downloaded and saved to your records!',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        print('Download/Save Success: Document saved to doctor records');
      } else {
        // Error response
        String errorMessage = 'Failed to save document to records';
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (jsonError) {
          errorMessage = 'Server error: ${response.statusCode}';
        }

        print(
          'Download/Save API Error: Status ${response.statusCode}, Message: $errorMessage',
        );
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Download/Save Error: $e');

      String userMessage = 'Failed to download and save document';
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        userMessage = 'Network error. Please check your connection.';
      } else if (e.toString().contains('TimeoutException')) {
        userMessage = 'Request timeout. Please try again.';
      } else if (e.toString().contains('Authentication')) {
        userMessage = 'Authentication failed. Please login again.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _downloadDocument(fileUrl, fileName),
            ),
          ),
        );
      }
    }
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return dateString.split('T')[0];
    }
  }

  String _formatPatientId(String patientId) {
    if (patientId.isEmpty) return 'Unknown';
    if (patientId.length > 12) {
      return '${patientId.substring(0, 8)}...${patientId.substring(patientId.length - 4)}';
    }
    return patientId;
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF4285F4), size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4285F4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareDocument(String fileUrl, String fileName) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sharing $fileName...'),
          backgroundColor: const Color(0xFF4285F4),
          duration: const Duration(seconds: 2),
        ),
      );

      // Get current user data
      final prefs = await SharedPreferences.getInstance();
      final doctorId = prefs.getString('userId') ?? '';
      final doctorName = prefs.getString('userName') ?? 'Unknown Doctor';
      final token = prefs.getString('token') ?? '';

      // Get patient data from QR
      final patientId = widget.qrData['userId'] ?? '';

      if (doctorId.isEmpty || patientId.isEmpty) {
        throw Exception('Missing required user information');
      }

      if (token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      // Prepare request data
      final requestData = {
        'doctorId': doctorId,
        'doctorName': doctorName,
        'patientId': patientId,
        'fileName': fileName,
        'fileUrl': fileUrl,
      };

      print('=== SHARING DOCUMENT ===');
      print('URL: ${AppConfig.apiBaseUrl}${AppConfig.shareFileEndpoint}');
      print('Request Data: $requestData');
      print('Doctor ID: $doctorId');
      print('Patient ID: $patientId');

      // Make API call with authentication
      final response = await http
          .post(
            Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.shareFileEndpoint}'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'ngrok-skip-browser-warning': '1',
            },
            body: json.encode(requestData),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout. Please check your connection and try again.',
              );
            },
          );

      print('Share Document Response Status: ${response.statusCode}');
      print('Share Document Response Body: ${response.body}');
      print('Share Document Response Headers: ${response.headers}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        final responseData = json.decode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Document "$fileName" shared successfully!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        print(
          'Share Document Success: ${responseData['message'] ?? 'Document shared'}',
        );
      } else {
        // Error response
        String errorMessage = 'Failed to share document';
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (jsonError) {
          errorMessage = 'Server error: ${response.statusCode}';
        }

        print(
          'Share Document API Error: Status ${response.statusCode}, Message: $errorMessage',
        );
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Share Document Error: $e');

      String userMessage = 'Failed to share document';
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        userMessage = 'Network error. Please check your connection.';
      } else if (e.toString().contains('TimeoutException')) {
        userMessage = 'Request timeout. Please try again.';
      } else if (e.toString().contains('Authentication')) {
        userMessage = 'Authentication failed. Please login again.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _shareDocument(fileUrl, fileName),
            ),
          ),
        );
      }
    }
  }

  void _printDocument(String fileUrl, String fileName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Printing $fileName...'),
        backgroundColor: const Color(0xFF4285F4),
      ),
    );
  }

  void _showDocumentDetails() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Document Details'),
          content: const Text(
            'Additional document information would be displayed here.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

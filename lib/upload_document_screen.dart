import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'responsive_utils.dart';
import 'api_service.dart';
import 'token_service.dart';

class UploadDocumentScreen extends StatefulWidget {
  const UploadDocumentScreen({super.key});

  @override
  State<UploadDocumentScreen> createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  File? _selectedFile;
  String? _fileName;
  final ImagePicker _imagePicker = ImagePicker();

  // Pick file from gallery
  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedFile = File(image.path);
          _fileName = image.name;
        });
        _uploadFile();
      }
    } catch (e) {
      _showErrorMessage('Failed to pick image from gallery: $e');
    }
  }

  // Take photo with camera
  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedFile = File(image.path);
          _fileName = image.name;
        });
        _uploadFile();
      }
    } catch (e) {
      _showErrorMessage('Failed to take photo: $e');
    }
  }

  // Pick file (PDF, DOC, etc.)
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _fileName = result.files.single.name;
        });
        _uploadFile();
      }
    } catch (e) {
      _showErrorMessage('Failed to pick file: $e');
    }
  }

  // Upload file to server
  Future<void> _uploadFile() async {
    if (_selectedFile == null || _fileName == null) {
      _showErrorMessage('No file selected');
      return;
    }

    // Check if user is authenticated
    final isAuthenticated = await TokenService.isTokenValid();
    if (!isAuthenticated) {
      _showErrorMessage('Please login again to upload files');
      return;
    }

    // Check network connectivity
    try {
      final testConnection = await ApiService.testConnection();
      if (!testConnection) {
        _showErrorMessage('No internet connection. Please check your network and try again.');
        return;
      }
    } catch (e) {
      print('Network test failed: $e');
      // Continue with upload attempt even if test fails
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final response = await ApiService.uploadFile(
        file: _selectedFile!,
        fileName: _fileName!,
      );

      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 1.0;
          _selectedFile = null;
          _fileName = null;
        });

        // Show success message and go back
        _showSuccessMessage('Document uploaded successfully!');

        // Wait a moment then go back to previous screen
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
        _showErrorMessage(e.toString());
      }
    }
  }

  void _cancelUpload() {
    setState(() {
      _isUploading = false;
      _uploadProgress = 0.0;
      _selectedFile = null;
      _fileName = null;
    });
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Upload Document',
          style: AppTextStyles.heading4(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Simple Title
              Text(
                'Upload Document',
                style: AppTextStyles.heading3(context),
              ),

              const SizedBox(height: 8),

              Text(
                'Choose how to add your medical document',
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),

              const SizedBox(height: 40),
                  
              // Upload Options
              if (!_isUploading) ...[
                _buildSimpleUploadButton(
                  icon: Icons.photo_library_outlined,
                  title: 'Gallery',
                  onTap: _pickFromGallery,
                ),

                const SizedBox(height: 16),

                _buildSimpleUploadButton(
                  icon: Icons.camera_alt_outlined,
                  title: 'Camera',
                  onTap: _takePhoto,
                ),

                const SizedBox(height: 16),

                _buildSimpleUploadButton(
                  icon: Icons.insert_drive_file_outlined,
                  title: 'Files',
                  onTap: _pickFile,
                ),
              ],
                  
              // Upload Progress
              if (_isUploading) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Uploading...',
                            style: AppTextStyles.bodyMedium(context).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${(_uploadProgress * 100).toInt()}%',
                            style: AppTextStyles.bodyMedium(context).copyWith(
                              color: const Color(0xFF4285F4),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      if (_fileName != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _fileName!,
                          style: AppTextStyles.bodySmall(context).copyWith(
                            color: const Color(0xFF6B7280),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Progress bar
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _uploadProgress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF4285F4),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Cancel button
                      GestureDetector(
                        onTap: _cancelUpload,
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.bodySmall(context).copyWith(
                            color: const Color(0xFF6B7280),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              // Simple security note at bottom
              Row(
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 16,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Files are encrypted and secure',
                    style: AppTextStyles.bodySmall(context).copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleUploadButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF4285F4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
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
                style: AppTextStyles.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const Icon(
              Icons.chevron_right,
              color: Color(0xFF9CA3AF),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

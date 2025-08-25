import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api_service.dart';
import 'responsive_utils.dart';

class UploadResultScreen extends StatelessWidget {
  final FileUploadResponse uploadResponse;

  const UploadResultScreen({
    super.key,
    required this.uploadResponse,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Upload Results',
          style: TextStyle(
            color: Colors.black87,
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Success Header
              _buildSuccessHeader(context),
              
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
              
              // File Information
              if (uploadResponse.file != null) ...[
                _buildSectionCard(
                  context,
                  title: 'File Information',
                  icon: Icons.description_outlined,
                  child: _buildFileInfo(context),
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
              ],
              
              // Analysis Results
              if (uploadResponse.analysis != null) ...[
                _buildSectionCard(
                  context,
                  title: 'Analysis Results',
                  icon: Icons.analytics_outlined,
                  child: _buildAnalysisInfo(context),
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
              ],
              
              // OCR Text
              if (uploadResponse.analysis?.ocrText.isNotEmpty == true) ...[
                _buildSectionCard(
                  context,
                  title: 'Extracted Text',
                  icon: Icons.text_fields_outlined,
                  child: _buildOcrText(context),
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
              ],
              
              // Medical Entities
              if (uploadResponse.analysis?.medicalEntities.isNotEmpty == true) ...[
                _buildSectionCard(
                  context,
                  title: 'Medical Entities',
                  icon: Icons.medical_services_outlined,
                  child: _buildMedicalEntities(context),
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
              ],
              
              // Action Buttons
              _buildActionButtons(context),
              
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 32)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context, 24)),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Container(
            width: ResponsiveUtils.getResponsiveSpacing(context, 60),
            height: ResponsiveUtils.getResponsiveSpacing(context, 60),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: ResponsiveUtils.getResponsiveSpacing(context, 30),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
          Text(
            uploadResponse.message,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
              fontWeight: FontWeight.w600,
              color: Colors.green.shade800,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context, 16)),
            decoration: BoxDecoration(
              color: const Color(0xFF4285F4).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF4285F4),
                  size: ResponsiveUtils.getResponsiveSpacing(context, 20),
                ),
                SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4285F4),
                  ),
                ),
              ],
            ),
          ),
          // Section Content
          Padding(
            padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context, 16)),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildFileInfo(BuildContext context) {
    final file = uploadResponse.file!;
    return Column(
      children: [
        _buildInfoRow(context, 'File Name', file.fileName),
        _buildInfoRow(context, 'File ID', file.id),
        _buildInfoRow(context, 'Upload Date', _formatDate(file.uploadedAt)),
        _buildInfoRow(context, 'Last Accessed', _formatDate(file.lastAccessed)),
        if (file.fileUrl.isNotEmpty)
          _buildInfoRow(context, 'File URL', file.fileUrl, copyable: true),
      ],
    );
  }

  Widget _buildAnalysisInfo(BuildContext context) {
    final analysis = uploadResponse.analysis!;
    return Column(
      children: [
        _buildInfoRow(context, 'Analysis ID', analysis.id),
        _buildInfoRow(context, 'Analysis Date', _formatDate(analysis.analysisDate)),
        _buildInfoRow(context, 'User ID', analysis.userId),
        if (analysis.fileUrl.isNotEmpty)
          _buildInfoRow(context, 'Analysis URL', analysis.fileUrl, copyable: true),
      ],
    );
  }

  Widget _buildOcrText(BuildContext context) {
    final ocrText = uploadResponse.analysis!.ocrText;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context, 16)),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Extracted Text:',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              IconButton(
                onPressed: () => _copyToClipboard(context, ocrText),
                icon: Icon(
                  Icons.copy,
                  size: ResponsiveUtils.getResponsiveSpacing(context, 18),
                  color: const Color(0xFF4285F4),
                ),
                tooltip: 'Copy text',
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
          Text(
            ocrText,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalEntities(BuildContext context) {
    final entities = uploadResponse.analysis!.medicalEntities;
    
    if (entities.isEmpty) {
      return Text(
        'No medical entities detected',
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
          color: Colors.grey.shade600,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: entities.map((entity) {
        return Container(
          margin: EdgeInsets.only(bottom: ResponsiveUtils.getResponsiveSpacing(context, 8)),
          padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context, 12)),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Text(
            entity.toString(),
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
              color: Colors.blue.shade800,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {bool copyable = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUtils.getResponsiveSpacing(context, 12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: ResponsiveUtils.getResponsiveSpacing(context, 100),
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (copyable) ...[
                  SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8)),
                  GestureDetector(
                    onTap: () => _copyToClipboard(context, value),
                    child: Icon(
                      Icons.copy,
                      size: ResponsiveUtils.getResponsiveSpacing(context, 16),
                      color: const Color(0xFF4285F4),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // View File Button (if URL available)
        if (uploadResponse.file?.fileUrl.isNotEmpty == true) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement file viewing
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('File viewing will be implemented')),
                );
              },
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('View File'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4285F4),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveUtils.getResponsiveSpacing(context, 16),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12)),
        ],
        
        // Done Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveUtils.getResponsiveSpacing(context, 16),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

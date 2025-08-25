import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'scanned_document_screen.dart';
import 'api_service.dart';
import 'token_service.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Scan Patient QR Code',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Main scanner view
          AiBarcodeScanner(
            onDetect: (BarcodeCapture capture) {
              final String? scannedValue = capture.barcodes.first.rawValue;
              if (scannedValue != null && !_isProcessing) {
                _processQRCode(scannedValue);
              }
            },
            onDispose: () {
              debugPrint("Barcode scanner disposed!");
            },
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.noDuplicates,
            ),
          ),

          // Processing overlay
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF4285F4)),
                    SizedBox(height: 16),
                    Text(
                      'Processing QR Code...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom instructions overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Position the QR code within the frame',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Scan patient-generated QR codes to access medical documents',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _processQRCode(String qrData) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      print('Raw QR Data: $qrData');

      // Parse the QR code data
      final Map<String, dynamic> data = json.decode(qrData);
      print('Parsed QR Data: $data');

      // Validate the QR code structure for new format
      if (data.containsKey('type') &&
          data['type'] == 'medical_document' &&
          data.containsKey('fileName') &&
          data.containsKey('fileUrl') &&
          data.containsKey('userId') &&
          data.containsKey('fileId')) {
        // Add audit log when doctor scans QR code
        await _addAuditLog(data);

        // Navigate to scanned document screen with new format
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ScannedDocumentScreen(qrData: data),
            ),
          );
        }
      } else {
        print('Invalid QR code structure: $data');
        _showErrorMessage(
          'Invalid QR code format. Please scan a valid medical document QR code.',
        );
      }
    } catch (e) {
      print('QR Code parsing error: $e');
      _showErrorMessage('Failed to process QR code: ${e.toString()}');
    }

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _addAuditLog(Map<String, dynamic> qrData) async {
    try {
      // Check if user is a doctor
      final userRole = await TokenService.getUserRole();
      if (userRole != 'doctor') return;

      final doctorId = await TokenService.getUserId();
      final doctorName = await TokenService.getUserName();

      if (doctorId != null && doctorName != null) {
        await ApiService.addLog(
          doctorId: doctorId,
          doctorName: doctorName,
          patientId: qrData['userId'] ?? 'unknown',
          fileName: qrData['fileName'] ?? 'Unknown File',
        );
        print('Audit log added for QR scan: ${qrData['fileName']}');
      }
    } catch (e) {
      print('Error adding audit log: $e');
      // Don't show error to user, just log it
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

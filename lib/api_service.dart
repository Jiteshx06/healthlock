import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'config.dart';
import 'token_service.dart';

class ApiService {
  // Using configuration from config.dart
  static String get baseUrl => AppConfig.apiBaseUrl;
  static String get loginEndpoint => AppConfig.loginEndpoint;
  static String get registerEndpoint => AppConfig.registerEndpoint;
  static String get doctorLoginEndpoint => AppConfig.doctorLoginEndpoint;
  static String get doctorRegisterEndpoint => AppConfig.doctorRegisterEndpoint;
  static String get fileUploadEndpoint => AppConfig.fileUploadEndpoint;

  // Audit log endpoints
  static String get addLogEndpoint => '/api/logs/add';
  static String get getAllLogsEndpoint => '/api/logs/all';

  // Delete file endpoint
  static String deleteFileEndpoint(String fileId) => '/delete-file/$fileId';

  // Login method
  static Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$loginEndpoint');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          "ngrok-skip-browser-warning": "1",
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Login API Response Status: ${response.statusCode}');
      print('Login API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(data);

        // Save token if login successful
        if (loginResponse.success && loginResponse.token != null) {
          await TokenService.saveToken(loginResponse.token!);

          // Save additional user info from response
          if (loginResponse.name != null) {
            await TokenService.saveUserName(loginResponse.name!);
          }
        }

        return loginResponse;
      } else if (response.statusCode == 401) {
        throw ApiException('Invalid email or password');
      } else if (response.statusCode == 422) {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw ApiException(errorData['message'] ?? 'Validation error');
      } else {
        throw ApiException('Login failed. Please try again.');
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      print('Login API Error: $e');
      throw ApiException('Network error. Please check your connection.');
    }
  }

  // Register method
  static Future<RegisterResponse> register({
    required String name,
    required String email,
    required String password,
    required int age,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$registerEndpoint');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': '1',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'age': age,
        }),
      );

      print('Register API Response Status: ${response.statusCode}');
      print('Register API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return RegisterResponse.fromJson(data);
      } else if (response.statusCode == 422) {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw ApiException(errorData['message'] ?? 'Validation error');
      } else if (response.statusCode == 409) {
        throw ApiException('Email already exists');
      } else {
        throw ApiException('Registration failed. Please try again.');
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      print('Register API Error: $e');
      throw ApiException('Network error. Please check your connection.');
    }
  }

  // Doctor Login method
  static Future<DoctorLoginResponse> doctorLogin({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$doctorLoginEndpoint');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          "ngrok-skip-browser-warning": "1",
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Doctor Login API Response Status: ${response.statusCode}');
      print('Doctor Login API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('Doctor Login: Processing 200 response...');
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('Doctor Login: JSON decoded successfully');

        // For successful 200 responses, create a successful login response
        // The backend only returns 200 for verified doctors
        print('Doctor Login: Creating DoctorLoginResponse...');
        final loginResponse = DoctorLoginResponse(
          success: true,
          message: data['message'] ?? 'Login successful',
          token: data['token'],
          name: data['doctor']?['name'],
          role: 'doctor',
          doctor: data['doctor'] != null
              ? DoctorData.fromJson(data['doctor'])
              : null,
        );
        print('Doctor Login: DoctorLoginResponse created successfully');

        // Save token if login successful
        if (loginResponse.token != null) {
          print('Doctor Login: Saving token...');
          await TokenService.saveToken(loginResponse.token!);

          // Save additional user info from response
          if (loginResponse.name != null) {
            await TokenService.saveUserName(loginResponse.name!);
          }
          print('Doctor Login: Token saved successfully');
        }

        print('Doctor Login: Returning successful response');
        return loginResponse;
      } else if (response.statusCode == 401) {
        throw ApiException('Invalid email or password');
      } else if (response.statusCode == 403) {
        // Handle pending doctor approval
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw DoctorPendingException(
          errorData['message'] ??
              'Your account is pending admin approval. Please wait for approval before logging in.',
        );
      } else if (response.statusCode == 422) {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw ApiException(errorData['message'] ?? 'Validation error');
      } else {
        throw ApiException('Login failed. Please try again.');
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      if (e is DoctorPendingException) {
        // If we get here but the response was 200, it means the backend approved the doctor
        // but there's some client-side verification logic that's incorrectly throwing this exception
        // In this case, we should ignore the exception and return a successful response
        print('Doctor Login API Error: $e');
        print(
          'Ignoring DoctorPendingException because API returned 200 status',
        );
        rethrow;
      }
      print('Doctor Login API Error: $e');
      throw ApiException('Network error. Please check your connection.');
    }
  }

  // Doctor Register method
  static Future<DoctorRegisterResponse> doctorRegister({
    required String name,
    required String email,
    required String password,
    required String specialization,
    File? degreeFile,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$doctorRegisterEndpoint');

      if (degreeFile != null) {
        // Use multipart form data for file upload
        final dio = Dio();

        final formData = FormData.fromMap({
          'name': name,
          'email': email,
          'password': password,
          'specialization': specialization,
          'degreeFile': await MultipartFile.fromFile(
            degreeFile.path,
            filename: 'degree.${degreeFile.path.split('.').last}',
          ),
        });

        final response = await dio.post(
          url.toString(),
          data: formData,
          options: Options(
            headers: {
              'Accept': 'application/json',
              'ngrok-skip-browser-warning': '1',
            },
          ),
        );

        print('Doctor Register API Response Status: ${response.statusCode}');
        print('Doctor Register API Response Body: ${response.data}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final registerResponse = DoctorRegisterResponse.fromJson(
            response.data,
          );

          // Check if doctor registration is pending approval
          if (registerResponse.isPending == true ||
              (registerResponse.doctor != null &&
                  registerResponse.doctor!.isVerified == false)) {
            throw DoctorPendingException(
              registerResponse.message.isNotEmpty
                  ? registerResponse.message
                  : 'Registration submitted successfully! Your account is pending admin approval. You will be able to login once approved.',
            );
          }

          return registerResponse;
        } else if (response.statusCode == 422) {
          final errorData = response.data;
          throw ApiException(errorData['message'] ?? 'Validation error');
        } else if (response.statusCode == 409) {
          throw ApiException('Email already exists');
        } else {
          throw ApiException('Registration failed. Please try again.');
        }
      } else {
        // Use regular JSON for registration without file
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'ngrok-skip-browser-warning': '1',
          },
          body: jsonEncode({
            'name': name,
            'email': email,
            'password': password,
            'specialization': specialization,
          }),
        );

        print('Doctor Register API Response Status: ${response.statusCode}');
        print('Doctor Register API Response Body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final registerResponse = DoctorRegisterResponse.fromJson(data);

          // Check if doctor registration is pending approval
          if (registerResponse.isPending == true ||
              (registerResponse.doctor != null &&
                  registerResponse.doctor!.isVerified == false)) {
            throw DoctorPendingException(
              registerResponse.message.isNotEmpty
                  ? registerResponse.message
                  : 'Registration submitted successfully! Your account is pending admin approval. You will be able to login once approved.',
            );
          }

          return registerResponse;
        } else if (response.statusCode == 422) {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          throw ApiException(errorData['message'] ?? 'Validation error');
        } else if (response.statusCode == 409) {
          throw ApiException('Email already exists');
        } else {
          throw ApiException('Registration failed. Please try again.');
        }
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      print('Doctor Register API Error: $e');
      throw ApiException('Network error. Please check your connection.');
    }
  }

  // File upload method - simplified version
  static Future<FileUploadResponse> uploadFile({
    required File file,
    required String fileName,
  }) async {
    // Use simple 'file' field name as most servers expect this
    return await _uploadWithFieldName(file, fileName, 'file');
  }

  // Helper method to get authentication headers for JSON requests
  static Future<Map<String, String>?> _getAuthHeaders() async {
    final token = await TokenService.getToken();
    if (token == null) {
      return null;
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'ngrok-skip-browser-warning': '1',
    };
  }

  // Helper method to get authentication headers for GET requests
  static Future<Map<String, String>?> _getAuthHeadersForGet() async {
    final token = await TokenService.getToken();
    if (token == null) {
      return null;
    }

    return {
      'Authorization': 'Bearer $token',
      'ngrok-skip-browser-warning': '1',
    };
  }

  // Get user files method
  static Future<UserFilesResponse> getUserFiles() async {
    try {
      // Get user ID from token
      final userId = await TokenService.getUserId();
      if (userId == null) {
        throw ApiException('User not authenticated. Please login again.');
      }

      // Get auth headers for GET request
      final headers = await _getAuthHeadersForGet();
      if (headers == null) {
        throw ApiException('Authentication failed. Please login again.');
      }

      final url = '$baseUrl${AppConfig.userFilesEndpoint}/$userId';
      print('=== FETCHING USER FILES ===');
      print('URL: $url');
      print('User ID: $userId');
      print('Headers: $headers');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('=== USER FILES RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final userFilesResponse = UserFilesResponse.fromJson(jsonData);

        print('=== USER FILES PARSED ===');
        print('Total Files: ${userFilesResponse.totalFiles}');
        print('Files Count: ${userFilesResponse.files.length}');

        return userFilesResponse;
      } else if (response.statusCode == 401) {
        throw ApiException('Authentication failed. Please login again.');
      } else if (response.statusCode == 404) {
        throw ApiException('No files found for this user.');
      } else {
        throw ApiException(
          'Failed to fetch files (${response.statusCode}). Please try again.',
        );
      }
    } catch (e) {
      print('Get User Files Error: $e');
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        'Network error. Please check your connection and try again.',
      );
    }
  }

  // Generate temporary QR code URL for file sharing
  static Future<QRGenerateResponse> generateTempUrl(
    String userId,
    String fileId,
  ) async {
    try {
      // Get auth headers for POST request
      final headers = await _getAuthHeaders();
      if (headers == null) {
        throw ApiException('Authentication failed. Please login again.');
      }

      final url = '$baseUrl/qr/generate-temp-url/$userId/$fileId';
      print('=== GENERATING QR CODE ===');
      print('URL: $url');
      print('User ID: $userId');
      print('File ID: $fileId');
      print('Headers: $headers');

      final response = await http.post(Uri.parse(url), headers: headers);

      print('=== QR GENERATION RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final qrResponse = QRGenerateResponse.fromJson(jsonData);

        print('=== QR CODE GENERATED ===');
        print('Temp URL: ${qrResponse.tempUrl}');
        print('Expires In: ${qrResponse.expiresIn}');

        return qrResponse;
      } else if (response.statusCode == 401) {
        throw ApiException('Authentication failed. Please login again.');
      } else if (response.statusCode == 404) {
        throw ApiException('File not found.');
      } else {
        throw ApiException(
          'Failed to generate QR code (${response.statusCode}). Please try again.',
        );
      }
    } catch (e) {
      print('Generate QR Code Error: $e');
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        'Network error. Please check your connection and try again.',
      );
    }
  }

  // Helper method to upload with specific field name
  static Future<FileUploadResponse> _uploadWithFieldName(
    File file,
    String fileName,
    String fieldName,
  ) async {
    try {
      // Get user ID from token
      final userId = await TokenService.getUserId();
      if (userId == null) {
        throw ApiException('User not authenticated. Please login again.');
      }

      // Create Dio instance for multipart upload
      final dio = Dio();

      // Get auth headers
      final headers = await TokenService.getMultipartAuthHeaders();

      // Determine content type based on file extension
      String? contentType;
      final extension = fileName.toLowerCase().split('.').last;
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          contentType = 'image/jpeg';
          break;
        case 'png':
          contentType = 'image/png';
          break;
        case 'pdf':
          contentType = 'application/pdf';
          break;
        case 'doc':
          contentType = 'application/msword';
          break;
        case 'docx':
          contentType =
              'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
          break;
        default:
          contentType = 'application/octet-stream';
      }

      // Create form data with dynamic field name and proper content type
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: MediaType.parse(contentType),
        ),
      });

      // Upload file
      final url = '$baseUrl$fileUploadEndpoint/$userId';
      print('=== FILE UPLOAD DEBUG ===');
      print('File Upload URL: $url');
      print('File Name: $fileName');
      print('File Path: ${file.path}');
      print('File Size: ${await file.length()} bytes');
      print('User ID: $userId');
      print('Auth Headers: $headers');

      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: headers,
          validateStatus: (status) => status! < 500,
        ),
        onSendProgress: (sent, total) {
          print('Upload progress: ${(sent / total * 100).toStringAsFixed(1)}%');
        },
      );

      print('=== UPLOAD RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.data}');
      print('Request URL: ${response.requestOptions.uri}');
      print('Request Headers: ${response.requestOptions.headers}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('=== ERROR DETAILS ===');
        print('Error Response Type: ${response.data.runtimeType}');
        if (response.data is String) {
          print('Error Response String: ${response.data}');
        } else if (response.data is Map) {
          print('Error Response Map: ${response.data}');
        }
      } else {
        print('=== SUCCESS - PARSING RESPONSE ===');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final uploadResponse = FileUploadResponse.fromJson(response.data);
          print('=== FILE UPLOAD RESPONSE MAPPED ===');
          print('Message: ${uploadResponse.message}');

          if (uploadResponse.file != null) {
            print('File Data:');
            print('  - ID: ${uploadResponse.file!.id}');
            print('  - Name: ${uploadResponse.file!.fileName}');
            print('  - URL: ${uploadResponse.file!.fileUrl}');
            print('  - Uploaded: ${uploadResponse.file!.uploadedAt}');
          }

          if (uploadResponse.analysis != null) {
            print('Analysis Data:');
            print('  - ID: ${uploadResponse.analysis!.id}');
            print(
              '  - OCR Text Length: ${uploadResponse.analysis!.ocrText.length} chars',
            );
            print(
              '  - Medical Entities: ${uploadResponse.analysis!.medicalEntities.length} items',
            );
            print(
              '  - Analysis Date: ${uploadResponse.analysis!.analysisDate}',
            );
          }

          return uploadResponse;
        } catch (parseError) {
          print('Error parsing upload response: $parseError');
          print('Raw response data: ${response.data}');
          throw ApiException(
            'Server response format error. Please contact support.',
          );
        }
      } else if (response.statusCode == 400) {
        print('400 Bad Request Response: ${response.data}');
        throw ApiException(
          'Bad request. Please check file format and try again.',
        );
      } else if (response.statusCode == 401) {
        throw ApiException('Authentication failed. Please login again.');
      } else if (response.statusCode == 413) {
        throw ApiException('File too large. Please select a smaller file.');
      } else if (response.statusCode == 422) {
        final errorData = response.data;
        throw ApiException(errorData['message'] ?? 'Invalid file format');
      } else if (response.statusCode == 500) {
        throw ApiException(
          'Server error. Please try again later or contact support.',
        );
      } else {
        throw ApiException(
          'File upload failed (${response.statusCode}). Please try again.',
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      print('File Upload Error: $e');

      // Handle different types of errors more specifically
      if (e.toString().contains('DioException')) {
        if (e.toString().contains('status code of 500')) {
          throw ApiException('Server error occurred. Please try again later.');
        } else if (e.toString().contains('status code of 404')) {
          throw ApiException(
            'Upload endpoint not found. Please check server configuration.',
          );
        } else if (e.toString().contains('status code of 413')) {
          throw ApiException('File too large. Please select a smaller file.');
        } else if (e.toString().contains('SocketException') ||
            e.toString().contains('HandshakeException')) {
          throw ApiException(
            'Network connection failed. Please check your internet connection.',
          );
        } else {
          throw ApiException(
            'Upload failed: ${e.toString().split(':').last.trim()}',
          );
        }
      } else {
        throw ApiException('Network error. Please check your connection.');
      }
    }
  }

  // Test connection method
  static Future<bool> testConnection() async {
    try {
      // Try to reach a simple endpoint or the base URL
      final url = Uri.parse(
        baseUrl.replaceAll('/api', ''),
      ); // Remove /api to test base domain
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      // Accept any response that's not a network error (even 404 means server is reachable)
      return response.statusCode < 500;
    } catch (e) {
      print('Connection test failed: $e');
      // Try alternative connectivity test
      try {
        final googleTest = await http
            .get(Uri.parse('https://www.google.com'))
            .timeout(const Duration(seconds: 3));
        return googleTest.statusCode == 200;
      } catch (e2) {
        print('Google connectivity test also failed: $e2');
        return false;
      }
    }
  }

  // Analyze Records API
  static Future<AnalyzeRecordsResponse> analyzeRecords(String userId) async {
    try {
      print('=== ANALYZING RECORDS ===');
      print('User ID: $userId');

      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';
      dio.options.headers['Content-Type'] = 'application/json';

      final url = '$baseUrl/analysis/analyze/$userId';
      print('Making request to: $url');

      final response = await dio.get(url);

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        return AnalyzeRecordsResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to analyze records: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error analyzing records: $e');
      throw Exception('Failed to analyze records: $e');
    }
  }

  // Add audit log entry
  static Future<AuditLogResponse> addLog({
    required String doctorId,
    required String doctorName,
    required String patientId,
    required String fileName,
  }) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw ApiException('Authentication required');
      }

      final url = Uri.parse('$baseUrl$addLogEndpoint');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': '1',
        },
        body: jsonEncode({
          'doctorId': doctorId,
          'doctorName': doctorName,
          'patientId': patientId,
          'fileName': fileName,
        }),
      );

      print('Add Log API Response Status: ${response.statusCode}');
      print('Add Log API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return AuditLogResponse.fromJson(data);
      } else {
        throw ApiException('Failed to add audit log');
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      print('Add Log API Error: $e');
      throw ApiException('Network error. Please check your connection.');
    }
  }

  // Get all audit logs for current user (doctor or patient)
  static Future<List<AuditLogEntry>> getAllLogs() async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw ApiException('Authentication required');
      }

      final userId = await TokenService.getUserId();
      final userRole = await TokenService.getUserRole();
      if (userId == null) {
        throw ApiException('User ID not found');
      }

      final url = Uri.parse('$baseUrl$getAllLogsEndpoint');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': '1',
        },
      );

      print('Get All Logs API Response Status: ${response.statusCode}');
      print('Get All Logs API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Filter logs based on user role
        List<dynamic> filteredLogs;
        if (userRole == 'doctor') {
          // For doctors: show logs where they are the doctor
          filteredLogs = data
              .where((log) => log['doctorId'] == userId)
              .toList();
        } else {
          // For patients: show logs where they are the patient
          filteredLogs = data
              .where((log) => log['patientId'] == userId)
              .toList();
        }

        return filteredLogs.map((log) => AuditLogEntry.fromJson(log)).toList();
      } else {
        throw ApiException('Failed to fetch audit logs');
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      print('Get All Logs API Error: $e');
      throw ApiException('Network error. Please check your connection.');
    }
  }

  // Delete file by ID
  static Future<bool> deleteFile(String fileId) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw ApiException('Authentication required');
      }

      final url = Uri.parse('$baseUrl${deleteFileEndpoint(fileId)}');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': '1',
        },
      );

      print('Delete File API Response Status: ${response.statusCode}');
      print('Delete File API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw ApiException('Failed to delete file');
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      print('Delete File API Error: $e');
      throw ApiException('Network error. Please check your connection.');
    }
  }
}

// Login response model
class LoginResponse {
  final bool success;
  final String message;
  final String? token;
  final String? role;
  final String? name;
  final PatientData? patient;

  LoginResponse({
    required this.success,
    required this.message,
    this.token,
    this.role,
    this.name,
    this.patient,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? true,
      message: json['message'] ?? 'Login successful',
      token: json['token'],
      role: json['role'],
      name: json['name'],
      patient: json['patient'] != null
          ? PatientData.fromJson(json['patient'])
          : null,
    );
  }
}

// Register response model
class RegisterResponse {
  final bool success;
  final String message;
  final String? token;
  final PatientData? patient;

  RegisterResponse({
    required this.success,
    required this.message,
    this.token,
    this.patient,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json['success'] ?? true,
      message: json['message'] ?? 'Registration successful',
      token: json['token'],
      patient: json['patient'] != null
          ? PatientData.fromJson(json['patient'])
          : null,
    );
  }
}

// Patient data model
class PatientData {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final int? age;

  PatientData({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.age,
  });

  factory PatientData.fromJson(Map<String, dynamic> json) {
    return PatientData(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
      age: json['age']?.toInt(),
    );
  }
}

// File upload response model
class FileUploadResponse {
  final String message;
  final FileData? file;
  final AnalysisData? analysis;

  FileUploadResponse({required this.message, this.file, this.analysis});

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) {
    return FileUploadResponse(
      message: json['message'] ?? 'File uploaded successfully',
      file: json['file'] != null ? FileData.fromJson(json['file']) : null,
      analysis: json['analysis'] != null
          ? AnalysisData.fromJson(json['analysis'])
          : null,
    );
  }

  @override
  String toString() {
    return 'FileUploadResponse(message: $message, hasFile: ${file != null}, hasAnalysis: ${analysis != null})';
  }
}

// File data model
class FileData {
  final String id;
  final String userId;
  final String fileName;
  final String fileUrl;
  final String uploadedAt;
  final String lastAccessed;
  final int? version;

  FileData({
    required this.id,
    required this.userId,
    required this.fileName,
    required this.fileUrl,
    required this.uploadedAt,
    required this.lastAccessed,
    this.version,
  });

  factory FileData.fromJson(Map<String, dynamic> json) {
    return FileData(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      fileName: json['fileName'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      uploadedAt: json['uploadedAt'] ?? '',
      lastAccessed: json['lastAccessed'] ?? '',
      version: json['__v']?.toInt(),
    );
  }

  @override
  String toString() {
    return 'FileData(id: $id, fileName: $fileName, uploadedAt: $uploadedAt)';
  }
}

// Analysis data model
class AnalysisData {
  final String id;
  final String? userFileId;
  final String userId;
  final String fileUrl;
  final String ocrText;
  final List<dynamic> medicalEntities;
  final String analysisDate;
  final int? version;

  AnalysisData({
    required this.id,
    this.userFileId,
    required this.userId,
    required this.fileUrl,
    required this.ocrText,
    required this.medicalEntities,
    required this.analysisDate,
    this.version,
  });

  factory AnalysisData.fromJson(Map<String, dynamic> json) {
    // Handle ocrText which can be either a string or an object with 'text' field
    String extractedText = '';
    if (json['ocrText'] != null) {
      if (json['ocrText'] is String) {
        extractedText = json['ocrText'];
      } else if (json['ocrText'] is Map && json['ocrText']['text'] != null) {
        extractedText = json['ocrText']['text'].toString();
      }
    }

    return AnalysisData(
      id: json['_id'] ?? '',
      userFileId: json['userFileId'],
      userId: json['userId'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      ocrText: extractedText,
      medicalEntities: json['medicalEntities'] ?? [],
      analysisDate: json['analysisDate'] ?? '',
      version: json['__v']?.toInt(),
    );
  }

  @override
  String toString() {
    return 'AnalysisData(id: $id, ocrTextLength: ${ocrText.length}, entitiesCount: ${medicalEntities.length})';
  }
}

// User files response model
class UserFilesResponse {
  final int totalFiles;
  final List<UserFileData> files;

  UserFilesResponse({required this.totalFiles, required this.files});

  factory UserFilesResponse.fromJson(Map<String, dynamic> json) {
    return UserFilesResponse(
      totalFiles: json['totalFiles'] ?? 0,
      files:
          (json['files'] as List<dynamic>?)
              ?.map((fileJson) => UserFileData.fromJson(fileJson))
              .toList() ??
          [],
    );
  }

  @override
  String toString() {
    return 'UserFilesResponse(totalFiles: $totalFiles, filesCount: ${files.length})';
  }
}

// User file data model (similar to FileData but for the files list endpoint)
class UserFileData {
  final String id;
  final String userId;
  final String fileName;
  final String fileUrl;
  final String uploadedAt;
  final String? lastAccessed;
  final int? version;

  UserFileData({
    required this.id,
    required this.userId,
    required this.fileName,
    required this.fileUrl,
    required this.uploadedAt,
    this.lastAccessed,
    this.version,
  });

  factory UserFileData.fromJson(Map<String, dynamic> json) {
    return UserFileData(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      fileName: json['fileName'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      uploadedAt: json['uploadedAt'] ?? '',
      lastAccessed: json['lastAccessed'],
      version: json['__v']?.toInt(),
    );
  }

  @override
  String toString() {
    return 'UserFileData(id: $id, fileName: $fileName, uploadedAt: $uploadedAt)';
  }
}

// QR code generation response model
class QRGenerateResponse {
  final String tempUrl;
  final String expiresIn;
  final String fileUrl;
  final String userId;
  final String file;

  QRGenerateResponse({
    required this.tempUrl,
    required this.expiresIn,
    required this.fileUrl,
    required this.userId,
    required this.file,
  });

  factory QRGenerateResponse.fromJson(Map<String, dynamic> json) {
    return QRGenerateResponse(
      tempUrl: json['tempUrl'] ?? '',
      expiresIn: json['expiresIn'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      userId: json['userId'] ?? '',
      file: json['file'] ?? '',
    );
  }

  @override
  String toString() {
    return 'QRGenerateResponse(tempUrl: $tempUrl, expiresIn: $expiresIn, file: $file)';
  }
}

// Custom exception class
class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}

// Doctor pending approval exception
class DoctorPendingException implements Exception {
  final String message;

  DoctorPendingException(this.message);

  @override
  String toString() => message;
}

// Analyze Records API
class AnalyzeRecordsResponse {
  final String message;
  final String userId;
  final int totalChunks;
  final String shortSummary;
  final List<Map<String, dynamic>> detailedResults;

  AnalyzeRecordsResponse({
    required this.message,
    required this.userId,
    required this.totalChunks,
    required this.shortSummary,
    required this.detailedResults,
  });

  factory AnalyzeRecordsResponse.fromJson(Map<String, dynamic> json) {
    return AnalyzeRecordsResponse(
      message: json['message'] ?? '',
      userId: json['userId'] ?? '',
      totalChunks: json['totalChunks'] ?? 0,
      shortSummary: json['shortSummary'] ?? '',
      detailedResults: List<Map<String, dynamic>>.from(
        json['detailedResults'] ?? [],
      ),
    );
  }
}

// Doctor login response model
class DoctorLoginResponse {
  final bool success;
  final String message;
  final String? token;
  final String? role;
  final String? name;
  final DoctorData? doctor;

  DoctorLoginResponse({
    required this.success,
    required this.message,
    this.token,
    this.role,
    this.name,
    this.doctor,
  });

  factory DoctorLoginResponse.fromJson(Map<String, dynamic> json) {
    return DoctorLoginResponse(
      success: json['success'] ?? true,
      message: json['message'] ?? 'Login successful',
      token: json['token'],
      role: json['role'],
      name: json['name'],
      doctor: json['doctor'] != null
          ? DoctorData.fromJson(json['doctor'])
          : null,
    );
  }
}

// Doctor register response model
class DoctorRegisterResponse {
  final bool success;
  final String message;
  final String? token;
  final DoctorData? doctor;
  final bool? isPending;
  final String? status;

  DoctorRegisterResponse({
    required this.success,
    required this.message,
    this.token,
    this.doctor,
    this.isPending,
    this.status,
  });

  factory DoctorRegisterResponse.fromJson(Map<String, dynamic> json) {
    return DoctorRegisterResponse(
      success: json['success'] ?? true,
      message: json['message'] ?? 'Registration successful',
      token: json['token'],
      doctor: json['doctor'] != null
          ? DoctorData.fromJson(json['doctor'])
          : null,
      isPending: json['isPending'] ?? (json['status'] == 'pending'),
      status: json['status'],
    );
  }
}

// Doctor data model
class DoctorData {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String specialization;
  final String? degreeFileUrl;
  final bool? isVerified;

  DoctorData({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    required this.specialization,
    this.degreeFileUrl,
    this.isVerified,
  });

  factory DoctorData.fromJson(Map<String, dynamic> json) {
    return DoctorData(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
      specialization: json['specialization'] ?? '',
      degreeFileUrl: json['degreeFileUrl'],
      isVerified: json['isVerified'] ?? false,
    );
  }
}

// Audit Log Response model
class AuditLogResponse {
  final String message;
  final AuditLogEntry data;

  AuditLogResponse({required this.message, required this.data});

  factory AuditLogResponse.fromJson(Map<String, dynamic> json) {
    return AuditLogResponse(
      message: json['message'] ?? '',
      data: AuditLogEntry.fromJson(json['data']),
    );
  }
}

// Audit Log Entry model
class AuditLogEntry {
  final String id;
  final String doctorId;
  final String doctorName;
  final String patientId;
  final String fileName;
  final String date;
  final String time;
  final String createdAt;
  final String updatedAt;

  AuditLogEntry({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.patientId,
    required this.fileName,
    required this.date,
    required this.time,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    return AuditLogEntry(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      doctorId: json['doctorId'] ?? '',
      doctorName: json['doctorName'] ?? '',
      patientId: json['patientId'] ?? '',
      fileName: json['fileName'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  // Helper method to format the log entry for display
  String get formattedDateTime {
    try {
      final dateTime = DateTime.parse(date);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at $time';
    } catch (e) {
      return '$date at $time';
    }
  }
}

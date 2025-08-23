class AppConfig {
  // API Configuration
  // Update this with your actual API base URL

  // For local development (if your API is running locally):
  // Option 1: Use your computer's IP address (found with ipconfig)
  // static const String apiBaseUrl = 'http://172.25.158.195:3000/api'; // Your actual IP address
  // Option 2: Use 10.0.2.2 for Android emulator (doesn't work for physical devices)
  // static const String apiBaseUrl = 'http://10.0.2.2:3000/api';

  // For production/testing (using ngrok tunnel - UPDATED WITH NEW NGROK URL):
  static const String apiBaseUrl = 'https://backendhealthlock.onrender.com';

  // API Endpoints
  static const String loginEndpoint = '/api/patients/login';
  static const String registerEndpoint = '/patients/register';
  static const String doctorLoginEndpoint = '/api/doctors/login';
  static const String doctorRegisterEndpoint = '/api/doctors/register';
  static const String fileUploadEndpoint = '/api/files/upload';
  static const String userFilesEndpoint = '/api/accessdata/uploads';

  // Other configuration
  static const int apiTimeoutSeconds = 30;
  static const bool enableApiLogging = true;

  // Demo credentials (remove in production)
  static const String demoEmail = 'jiteshp277@gmail.com';
  static const String demoPassword = 'Jitesh@@321';

  // Demo doctor credentials (remove in production)
  static const String demoDoctorEmail = 'doctor@healthlock.com';
  static const String demoDoctorPassword = 'Doctor123!';
}

class AppConfig {
  // API Configuration
  // Update this with your actual API base URL
  
  // For local development (if your API is running locally):
  // Option 1: Use your computer's IP address (found with ipconfig)
  // static const String apiBaseUrl = 'http://172.25.158.195:3000/api'; // Your actual IP address
  // Option 2: Use 10.0.2.2 for Android emulator (doesn't work for physical devices)
  // static const String apiBaseUrl = 'http://10.0.2.2:3000/api';

  // For production/testing (using ngrok tunnel - UPDATED WITH NEW NGROK URL):
  static const String apiBaseUrl = 'https://backendhealthlock.onrender.com/api';
  
  // API Endpoints
  static const String loginEndpoint = '/patients/login';
  static const String registerEndpoint = '/patients/register';
  static const String fileUploadEndpoint = '/files/upload';
  static const String userFilesEndpoint = '/accessdata/uploads';
  
  // Other configuration
  static const int apiTimeoutSeconds = 30;
  static const bool enableApiLogging = true;
  
  // Demo credentials (remove in production)
  static const String demoEmail = 'demo@healthlock.com';
  static const String demoPassword = 'password123';
}

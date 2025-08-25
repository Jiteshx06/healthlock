# API Setup Instructions

## Quick Setup

1. **Update API Base URL**
   - Open `lib/config.dart`
   - Update `apiBaseUrl` with your actual API URL:
   ```dart
   // For local development:
   static const String apiBaseUrl = 'http://localhost:3000/api';
   
   // For production:
   static const String apiBaseUrl = 'https://your-api-domain.com/api';
   ```

2. **API Endpoint**
   - The login endpoint is already configured as `https://a2a3d670e57d.ngrok-free.app/api/patients/login`
   - Full URL will be: `{https://a2a3d670e57d.ngrok-free.app}/api/patients/login`

3. **Request Format**
   ```json
   {
     "email": "user@example.com",
     "password": "userpassword"
   }
   ```

4. **Expected Response Format**
   ```json
   {
     "success": true,
     "message": "Login successful",
     "token": "jwt-token-here",
     "patient": {
       "id": "123",
       "name": "John Doe",
       "email": "user@example.com",
       "phone": "+1234567890",
       "avatar": "https://example.com/avatar.jpg"
     }
   }
   ```

## Testing

1. **Demo Credentials**
   - Email: `demo@healthlock.com`
   - Password: `password123`
   - These are pre-filled in the login form for testing

2. **Error Handling**
   - 401: Invalid credentials
   - 422: Validation error
   - Network errors are handled gracefully

3. **Loading States**
   - Login button shows loading spinner during API call
   - Button is disabled while loading

## Running on Device

1. **For Android/iOS Physical Device:**
   - Make sure your device is on the same network as your API server
   - Use your computer's IP address instead of `localhost`
   - Example: `http://192.168.1.100:3000/api`

2. **For Web (Chrome):**
   - Can use `localhost` if API is running locally
   - Make sure CORS is enabled on your API server

3. **Network Permissions**
   - Android: Internet permission is already included
   - iOS: No additional setup needed for HTTP requests

## API Server Requirements

Your API server should:
1. Accept POST requests to `/api/patients/login`
2. Accept JSON content type
3. Return appropriate HTTP status codes
4. Enable CORS for web requests
5. Return the expected JSON response format

## Troubleshooting

1. **Network Error**: Check if API server is running and accessible
2. **CORS Error**: Enable CORS on your API server for web requests
3. **Invalid Response**: Ensure API returns the expected JSON format
4. **Timeout**: Default timeout is 30 seconds, adjust in `config.dart` if needed

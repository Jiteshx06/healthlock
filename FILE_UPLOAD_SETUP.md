# File Upload Setup Documentation

## Overview
The HealthLock app now supports file upload functionality that connects to your API endpoint `http://localhost:3000/api/files/upload/<user_id>`. The implementation includes:

- **Token Management**: JWT tokens are automatically stored and managed
- **File Picking**: Support for gallery, camera, and file picker
- **Secure Upload**: Files are uploaded with proper authentication
- **Progress Tracking**: Real-time upload progress display
- **Error Handling**: Comprehensive error handling and user feedback

## API Integration

### Endpoint Format
```
POST http://localhost:3000/api/files/upload/{user_id}
```

### Authentication
- Uses JWT token from login response
- Token is automatically extracted and stored after successful login
- User ID is extracted from JWT token payload
- Authorization header: `Bearer <jwt_token>`

### Request Format
- **Content-Type**: `multipart/form-data`
- **File Field**: `file`
- **Supported Formats**: PDF, DOC, DOCX, JPG, JPEG, PNG

### Expected Response Format
```json
{
    "message": "✅ File uploaded & stored",
    "file": {
        "userId": "68a77c9f41720a5dd4ac0046",
        "fileName": "WhatsApp Image 2025-08-22 at 11.28.05_414c4f74 (1).jpg",
        "fileUrl": "https://cdn.filestackcontent.com/a347x9TQkGyKgPpBcU9G",
        "_id": "68a82cb541982b712def3567",
        "lastAccessed": "2025-08-22T08:39:17.458Z",
        "uploadedAt": "2025-08-22T08:39:17.463Z",
        "__v": 0
    },
    "analysis": {
        "userFileId": null,
        "userId": "68a77c9f41720a5dd4ac0046",
        "fileUrl": "https://cdn.filestackcontent.com/a347x9TQkGyKgPpBcU9G",
        "ocrText": "DRLOCY PATHOLOGY LAB...",
        "medicalEntities": [],
        "_id": "68a82cb941982b712def3568",
        "analysisDate": "2025-08-22T08:39:21.547Z",
        "__v": 0
    }
}
```

## Implementation Details

### New Files Added
1. **`lib/token_service.dart`** - JWT token management
2. **Updated `lib/api_service.dart`** - Added file upload method
3. **Updated `lib/upload_document_screen.dart`** - Implemented file picking and upload

### Dependencies Added
```yaml
dependencies:
  file_picker: ^10.3.2      # File selection
  image_picker: ^1.2.0      # Camera and gallery access
  shared_preferences: ^2.5.3 # Token storage
  jwt_decoder: ^2.0.1       # JWT token decoding
  dio: ^5.9.0              # HTTP client for multipart uploads
```

### Permissions Added

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs access to camera to capture medical documents</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to photo library to select medical documents</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to microphone for video recording</string>
```

## How It Works

### 1. User Login
- User logs in with credentials
- JWT token is received and automatically stored
- User ID is extracted from token payload

### 2. File Upload Process
1. User navigates to Upload Document screen
2. Selects upload method (Gallery, Camera, or File)
3. File is selected/captured
4. App checks authentication status
5. File is uploaded with progress tracking
6. Success/error feedback is displayed

### 3. Token Management
- Tokens are stored securely using SharedPreferences
- Automatic token validation before API calls
- User ID extraction from JWT payload
- Authorization headers automatically added

## Usage Instructions

### For Users
1. **Login**: Use your credentials to login
2. **Navigate**: Go to "My Records" → "Upload New Report"
3. **Select Method**:
   - **Gallery**: Choose existing photos
   - **Camera**: Take new photos
   - **File**: Select PDF/DOC files
4. **Upload**: File uploads automatically after selection
5. **Feedback**: Success/error messages are displayed

### For Developers
1. **Update API URL**: Modify `lib/config.dart` with your API base URL
2. **Test Connection**: Use demo credentials for testing
3. **Error Handling**: Check console logs for debugging
4. **Customization**: Modify upload options in `upload_document_screen.dart`

## Error Handling

### Common Errors
- **Authentication Failed**: User needs to login again
- **File Too Large**: Select smaller file (handled by server)
- **Invalid Format**: Only supported formats allowed
- **Network Error**: Check internet connection
- **Permission Denied**: Grant camera/storage permissions

### Debugging
- Check console logs for detailed error messages
- Verify API endpoint is accessible
- Ensure proper permissions are granted
- Test with demo credentials first

## Testing

### Prerequisites
1. API server running on configured URL
2. Valid user account or demo credentials
3. Device/emulator with camera and storage access

### Test Steps
1. Login with valid credentials
2. Navigate to upload screen
3. Try each upload method (Gallery, Camera, File)
4. Verify file uploads successfully
5. Check server receives files with correct user ID

## Configuration

### API Configuration (`lib/config.dart`)
```dart
static const String apiBaseUrl = 'http://localhost:3000/api';
static const String fileUploadEndpoint = '/files/upload';
```

### Supported File Types
- **Images**: JPG, JPEG, PNG
- **Documents**: PDF, DOC, DOCX
- **Size Limit**: Determined by server configuration

## Security Features

- **JWT Authentication**: Secure token-based authentication
- **Automatic Token Management**: Tokens stored securely
- **Permission Validation**: Proper Android/iOS permissions
- **Error Sanitization**: User-friendly error messages
- **Secure Headers**: Proper authorization headers

## Next Steps

1. **Test thoroughly** with your API endpoint
2. **Customize UI** as needed for your brand
3. **Add file management** features (view, delete uploaded files)
4. **Implement offline support** if required
5. **Add file compression** for large images

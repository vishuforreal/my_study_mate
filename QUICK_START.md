# Quick Start Guide - My Study Mate

## 🎯 Goal
Build a working APK for the My Study Mate educational platform.

## ⚡ Quick Steps to APK

### 1. Install Flutter (if not already installed)

**Windows:**
```powershell
# Download Flutter SDK from https://flutter.dev/docs/get-started/install/windows
# Extract to C:\src\flutter
# Add to PATH: C:\src\flutter\bin

# Verify installation
flutter doctor
```

### 2. Setup Project

```bash
# Navigate to Flutter app directory
cd C:\Users\vishu\Downloads\antigravity\MyStudyMate\flutter_app

# Install dependencies
flutter pub get

# Check for issues
flutter doctor
```

### 3. Configure API Endpoint

Edit `lib/config/constants.dart`:
```dart
// For local testing with backend
static const String baseUrl = 'http://localhost:5000/api';

// For physical device (replace X with your IP)
static const String baseUrl = 'http://192.168.1.X:5000/api';

// For production (when backend is deployed)
static const String baseUrl = 'https://your-api.com/api';
```

### 4. Build APK

```bash
# Build release APK
flutter build apk --release

# APK location:
# build/app/outputs/flutter-apk/app-release.apk
```

**Or build smaller APKs:**
```bash
# Split by architecture (recommended)
flutter build apk --split-per-abi --release

# Creates 3 APKs:
# - app-armeabi-v7a-release.apk (most Android phones)
# - app-arm64-v8a-release.apk (newer phones)
# - app-x86_64-release.apk (emulators)
```

### 5. Install APK

**On Physical Device:**
1. Copy APK to phone
2. Enable "Install from Unknown Sources"
3. Tap APK file to install

**On Emulator:**
```bash
flutter install
```

## 🖥️ Setup Backend (Optional for Testing)

### 1. Install Node.js
Download from: https://nodejs.org/

### 2. Setup Backend
```bash
cd C:\Users\vishu\Downloads\antigravity\MyStudyMate\backend

# Install dependencies
npm install

# Create .env file
copy .env.example .env

# Edit .env with your MongoDB and Cloudinary credentials

# Start server
npm start
```

Server runs on: `http://localhost:5000`

### 3. Test API
Visit: `http://localhost:5000`

You should see:
```json
{
  "success": true,
  "message": "My Study Mate API Server"
}
```

## 📱 Test the App

### Without Backend (UI Only)
The app will show UI but API calls will fail. You can still test:
- Login/Register screens
- UI navigation
- Theme switching

### With Backend
1. Start backend server
2. Update API URL in `constants.dart`
3. Run app: `flutter run`
4. Login with: `admin@mystudymate.com` / `admin123`

## 🎨 Customize Before Building

### Change App Name
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:label="My Study Mate"
    ...>
```

### Change Colors
Edit `lib/config/constants.dart`:
```dart
static const Color primaryColor = Color(0xFF6C63FF);
static const Color secondaryColor = Color(0xFF4CAF50);
```

## 🐛 Common Issues

### "Flutter not found"
- Add Flutter to PATH
- Restart terminal
- Run: `flutter doctor`

### "Android license not accepted"
```bash
flutter doctor --android-licenses
```

### "Gradle build failed"
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --release
```

### "Connection refused" in app
- Check backend is running
- Update API URL in constants.dart
- Use computer's IP for physical device

## 📦 APK File Locations

After building, find your APK at:

**Single APK:**
```
flutter_app/build/app/outputs/flutter-apk/app-release.apk
```

**Split APKs:**
```
flutter_app/build/app/outputs/flutter-apk/
├── app-armeabi-v7a-release.apk
├── app-arm64-v8a-release.apk
└── app-x86_64-release.apk
```

## ✅ Checklist

- [ ] Flutter SDK installed
- [ ] Android Studio installed (optional but recommended)
- [ ] Dependencies installed (`flutter pub get`)
- [ ] API endpoint configured
- [ ] APK built successfully
- [ ] APK tested on device/emulator

## 🚀 You're Done!

Your APK is ready to install and test!

**APK Size:** ~20-30 MB (release build)

**Supported:** Android 5.0+ (API 21+)

---

For detailed documentation, see:
- `README.md` - Main project overview
- `flutter_app/README.md` - Flutter app details
- `backend/README.md` - Backend API details
- `project_details.md` - Complete feature list

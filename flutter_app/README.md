# My Study Mate - Flutter Application

Complete educational platform mobile application built with Flutter for Android and iOS.

## 📱 Features

### For Students
- ✅ User Registration & Login
- ✅ Profile Management with Photo Upload
- ✅ Access to Notes, Books, Tests, PPTs, Projects, and Assignments
- ✅ Permission-based Content Access
- ✅ Dark/Light Theme Support
- ✅ Modern Material Design 3 UI

### For Admins
- ✅ Admin Dashboard
- ✅ Student Management
- ✅ Content Upload and Management
- ✅ Permission Control
- ✅ Analytics (Coming Soon)

## 🚀 Getting Started

### Prerequisites

1. **Flutter SDK** (3.0.0 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Add Flutter to your PATH

2. **Android Studio** (for Android development)
   - Download from: https://developer.android.com/studio
   - Install Android SDK and emulator

3. **VS Code** (Optional but recommended)
   - Download from: https://code.visualstudio.com/
   - Install Flutter and Dart extensions

### Installation Steps

1. **Clone or navigate to the project**
   ```bash
   cd MyStudyMate/flutter_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Endpoint**
   - Open `lib/config/constants.dart`
   - Update `baseUrl` with your backend server URL:
   ```dart
   // For local development
   static const String baseUrl = 'http://localhost:5000/api';
   
   // For physical device (replace with your computer's IP)
   static const String baseUrl = 'http://192.168.1.X:5000/api';
   
   // For production
   static const String baseUrl = 'https://your-api-domain.com/api';
   ```

4. **Run the app**
   ```bash
   # Check connected devices
   flutter devices
   
   # Run on connected device/emulator
   flutter run
   
   # Run in debug mode
   flutter run --debug
   
   # Run in release mode
   flutter run --release
   ```

## 📦 Building APK

### Debug APK (for testing)
```bash
flutter build apk --debug
```
Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Release APK (for distribution)
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Split APKs by ABI (smaller file size)
```bash
flutter build apk --split-per-abi --release
```
Outputs:
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM)
- `app-x86_64-release.apk` (64-bit x86)

### App Bundle (for Google Play Store)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

## 🔧 Configuration

### App Name and Icon

1. **Change App Name**
   - Edit `android/app/src/main/AndroidManifest.xml`
   - Update `android:label` attribute

2. **Change App Icon**
   - Replace icons in `android/app/src/main/res/mipmap-*/`
   - Or use flutter_launcher_icons package

### Signing APK (for production)

1. **Create keystore**
   ```bash
   keytool -genkey -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias
   ```

2. **Create `android/key.properties`**
   ```properties
   storePassword=<your-store-password>
   keyPassword=<your-key-password>
   keyAlias=my-key-alias
   storeFile=<path-to-keystore>/my-release-key.jks
   ```

3. **Update `android/app/build.gradle`**
   ```gradle
   def keystoreProperties = new Properties()
   def keystorePropertiesFile = rootProject.file('key.properties')
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }

   android {
       ...
       signingConfigs {
           release {
               keyAlias keystoreProperties['keyAlias']
               keyPassword keystoreProperties['keyPassword']
               storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
               storePassword keystoreProperties['storePassword']
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
           }
       }
   }
   ```

## 📱 Testing

### Run on Emulator
```bash
# Start Android emulator from Android Studio
# Or use command line:
flutter emulators
flutter emulators --launch <emulator_id>

# Run app
flutter run
```

### Run on Physical Device

1. **Enable Developer Options** on your Android device
2. **Enable USB Debugging**
3. **Connect device via USB**
4. **Run:**
   ```bash
   flutter devices
   flutter run
   ```

## 🎨 Customization

### Theme Colors
Edit `lib/config/constants.dart`:
```dart
static const Color primaryColor = Color(0xFF6C63FF);
static const Color secondaryColor = Color(0xFF4CAF50);
```

### App Constants
Edit `lib/config/constants.dart` to modify:
- API endpoints
- Categories and courses
- Color schemes
- Spacing and radius values

## 📚 Project Structure

```
lib/
├── config/
│   ├── app_theme.dart          # Theme configuration
│   └── constants.dart          # App constants
├── models/
│   ├── user_model.dart         # User data model
│   └── content_models.dart     # Content models
├── providers/
│   ├── auth_provider.dart      # Authentication state
│   └── theme_provider.dart     # Theme state
├── services/
│   ├── api_service.dart        # HTTP client
│   ├── auth_service.dart       # Auth operations
│   └── content_service.dart    # Content operations
├── screens/
│   ├── splash_screen.dart      # Splash screen
│   ├── auth/                   # Authentication screens
│   ├── student/                # Student screens
│   └── admin/                  # Admin screens
└── main.dart                   # App entry point
```

## 🔐 Default Credentials

### Super Admin
- Email: admin@mystudymate.com
- Password: admin123

**⚠️ IMPORTANT:** Change these credentials in production!

## 🐛 Troubleshooting

### Common Issues

1. **"Gradle build failed"**
   ```bash
   cd android
   ./gradlew clean
   cd ..
   flutter clean
   flutter pub get
   ```

2. **"SDK version mismatch"**
   - Update `android/app/build.gradle`:
   ```gradle
   compileSdkVersion 34
   minSdkVersion 21
   targetSdkVersion 34
   ```

3. **"Package not found"**
   ```bash
   flutter pub get
   flutter pub upgrade
   ```

4. **"Connection refused" (API)**
   - Ensure backend server is running
   - Update API URL in `constants.dart`
   - For physical device, use computer's IP address

## 📖 Documentation

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Material Design 3](https://m3.material.io/)

## 🚀 Deployment

### Google Play Store
1. Build app bundle: `flutter build appbundle --release`
2. Create Google Play Console account
3. Upload AAB file
4. Complete store listing
5. Submit for review

### Direct Distribution
1. Build APK: `flutter build apk --release`
2. Share APK file directly
3. Users need to enable "Install from Unknown Sources"

## 📝 License

This project is for educational purposes.

## 👨‍💻 Support

For issues and questions:
- Check troubleshooting section
- Review Flutter documentation
- Check backend API connectivity

---

**Built with ❤️ using Flutter**

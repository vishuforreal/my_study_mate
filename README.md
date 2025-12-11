# My Study Mate - Complete Application

Educational platform with Flutter mobile app and Node.js backend for managing educational content, students, and administrative tasks.

## 📋 Project Overview

**My Study Mate** is a comprehensive educational platform designed for schools, colleges, and coaching institutes. It provides:

- 📱 **Mobile App** (Flutter) - Cross-platform Android & iOS app
- 🖥️ **Backend API** (Node.js + Express) - RESTful API server
- 💾 **Database** (MongoDB) - Cloud-based data storage
- ☁️ **File Storage** (Cloudinary) - Cloud file management

## 🎯 Key Features

### Student Features
- User registration and authentication
- Access to notes, books, tests, PPTs, projects, and assignments
- Permission-based content access
- Profile management with photo upload
- Dark/Light theme support
- Interactive quizzes with timer

### Admin Features
- Student management (view, block/unblock)
- Granular permission control
- Content upload and management
- Analytics dashboard
- Bulk operations

### Super Admin Features
- Create/delete admin accounts
- System-wide settings
- Complete access control

## 🏗️ Architecture

```
MyStudyMate/
├── backend/                    # Node.js Express API
│   ├── models/                # MongoDB models
│   ├── routes/                # API routes
│   ├── middleware/            # Auth & upload middleware
│   ├── config/                # Configuration files
│   └── server.js              # Main server file
│
├── flutter_app/               # Flutter mobile application
│   ├── lib/
│   │   ├── config/           # App configuration
│   │   ├── models/           # Data models
│   │   ├── providers/        # State management
│   │   ├── services/         # API services
│   │   ├── screens/          # UI screens
│   │   └── main.dart         # App entry point
│   └── pubspec.yaml          # Flutter dependencies
│
└── project_details.md         # Complete project documentation
```

## 🚀 Quick Start

### Backend Setup

1. **Navigate to backend directory**
   ```bash
   cd MyStudyMate/backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment**
   ```bash
   cp .env.example .env
   # Edit .env with your credentials
   ```

4. **Start server**
   ```bash
   npm start
   # Or for development:
   npm run dev
   ```

Server will run on `http://localhost:5000`

### Flutter App Setup

1. **Navigate to Flutter directory**
   ```bash
   cd MyStudyMate/flutter_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Update API endpoint**
   - Edit `lib/config/constants.dart`
   - Set `baseUrl` to your backend URL

4. **Run the app**
   ```bash
   flutter run
   ```

## 📦 Building APK

### Quick Build
```bash
cd MyStudyMate/flutter_app
flutter build apk --release
```

APK location: `flutter_app/build/app/outputs/flutter-apk/app-release.apk`

### Optimized Build (smaller size)
```bash
flutter build apk --split-per-abi --release
```

## 🔐 Default Credentials

**Super Admin:**
- Email: `admin@mystudymate.com`
- Password: `admin123`

⚠️ **Change these in production!**

## 📚 Documentation

- **Backend API**: See `backend/README.md`
- **Flutter App**: See `flutter_app/README.md`
- **Project Details**: See `project_details.md`

## 🛠️ Technology Stack

### Backend
- Node.js & Express.js
- MongoDB with Mongoose
- JWT Authentication
- Multer (file uploads)
- Cloudinary (cloud storage)
- bcryptjs (password hashing)

### Frontend
- Flutter 3.0+
- Provider (state management)
- HTTP & Dio (networking)
- Shared Preferences (local storage)
- Google Fonts
- Material Design 3

## 📋 Prerequisites

### For Backend
- Node.js 14+ and npm
- MongoDB Atlas account (free tier)
- Cloudinary account (free tier)

### For Flutter App
- Flutter SDK 3.0+
- Android Studio (for Android)
- Xcode (for iOS, Mac only)

## 🔧 Configuration

### Backend Configuration
Edit `backend/.env`:
```env
MONGODB_URI=your_mongodb_connection_string
JWT_SECRET=your_secret_key
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

### Flutter Configuration
Edit `flutter_app/lib/config/constants.dart`:
```dart
static const String baseUrl = 'http://your-api-url:5000/api';
```

## 🧪 Testing

### Test Backend API
```bash
cd backend
npm start
# Visit http://localhost:5000
```

### Test Flutter App
```bash
cd flutter_app
flutter run
# Or run on specific device:
flutter run -d <device_id>
```

## 📱 Deployment

### Backend Deployment
- Deploy to Railway, Heroku, or AWS
- Set environment variables
- Configure MongoDB Atlas whitelist

### App Deployment
- Build release APK
- Submit to Google Play Store (Android)
- Submit to App Store (iOS)

## 🐛 Troubleshooting

### Backend Issues
- Ensure MongoDB connection string is correct
- Check if port 5000 is available
- Verify environment variables are set

### Flutter Issues
- Run `flutter doctor` to check setup
- Update API URL for physical devices
- Clear build: `flutter clean && flutter pub get`

## 📖 API Endpoints

### Authentication
- `POST /api/auth/register` - Register user
- `POST /api/auth/login` - Login user
- `GET /api/auth/me` - Get current user

### Student
- `GET /api/student/notes` - Get notes
- `GET /api/student/books` - Get books
- `GET /api/student/tests` - Get tests
- `POST /api/student/tests/:id/submit` - Submit test

### Admin
- `GET /api/admin/students` - Get all students
- `PUT /api/admin/students/:id/block` - Block/unblock student
- `POST /api/admin/notes` - Upload note
- `GET /api/admin/analytics` - Get analytics

## 🎨 Features Implemented

✅ User Authentication (JWT)  
✅ Role-based Access Control  
✅ Profile Management  
✅ Content Management (CRUD)  
✅ Permission System  
✅ File Upload  
✅ Dark/Light Theme  
✅ Responsive UI  
✅ State Management  

## 🚧 Future Enhancements

- PDF viewer integration
- Offline content caching
- Push notifications
- Video lectures
- Live classes
- Discussion forums
- Advanced analytics
- Payment integration

## 📄 License

This project is for educational purposes.

## 👨‍💻 Developer

Built with ❤️ for educational institutions

---

**Ready to build your APK!** Follow the instructions in `flutter_app/README.md`

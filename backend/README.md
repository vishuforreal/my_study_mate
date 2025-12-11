# My Study Mate Backend API

Backend server for My Study Mate educational platform built with Node.js, Express, and MongoDB.

## Features

- JWT Authentication
- Role-based Access Control (Student, Admin, Super Admin)
- File Upload Management
- Content Management (Notes, Books, Tests, PPTs, Projects, Assignments)
- Student Permission Management
- Analytics Dashboard

## Setup

1. Install dependencies:
```bash
npm install
```

2. Create `.env` file from `.env.example`:
```bash
cp .env.example .env
```

3. Update `.env` with your credentials:
   - MongoDB Atlas connection string
   - JWT secret key
   - Cloudinary credentials

4. Start server:
```bash
# Development
npm run dev

# Production
npm start
```

## Default Super Admin Credentials

- Email: admin@mystudymate.com
- Password: admin123

**IMPORTANT:** Change these credentials in production!

## API Endpoints

### Authentication
- POST `/api/auth/register` - Register new user
- POST `/api/auth/login` - Login user
- GET `/api/auth/me` - Get current user
- PUT `/api/auth/update-profile` - Update profile
- PUT `/api/auth/change-password` - Change password
- PUT `/api/auth/upload-photo` - Upload profile photo

### Student Routes
- GET `/api/student/notes` - Get notes
- GET `/api/student/books` - Get books
- GET `/api/student/tests` - Get tests
- GET `/api/student/tests/:id` - Get single test
- POST `/api/student/tests/:id/submit` - Submit test
- GET `/api/student/ppts` - Get PPTs
- GET `/api/student/projects` - Get projects
- GET `/api/student/assignments` - Get assignments

### Admin Routes
- GET `/api/admin/students` - Get all students
- PUT `/api/admin/students/:id/block` - Block/unblock student
- PUT `/api/admin/students/:id/permissions` - Update permissions
- POST `/api/admin/notes` - Upload note
- POST `/api/admin/books` - Upload book
- POST `/api/admin/tests` - Create test
- POST `/api/admin/ppts` - Upload PPT
- POST `/api/admin/projects` - Upload project
- POST `/api/admin/assignments` - Create assignment
- GET `/api/admin/analytics` - Get analytics
- POST `/api/admin/create-admin` - Create admin (Super Admin only)

## Tech Stack

- Node.js
- Express.js
- MongoDB with Mongoose
- JWT for authentication
- Multer for file uploads
- Cloudinary for file storage
- bcryptjs for password hashing

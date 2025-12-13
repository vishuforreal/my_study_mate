const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const path = require('path');
require('dotenv').config();

// Import routes
const authRoutes = require('./routes/authRoutes');
const studentRoutes = require('./routes/studentRoutes');
const adminRoutes = require('./routes/adminRoutes');
const categoryRoutes = require('./routes/categoryRoutes');
const subjectRoutes = require('./routes/subjectRoutes');
const clearRoutes = require('./routes/clearRoutes');

// Import models
const User = require('./models/User');
const Note = require('./models/Note');
const Book = require('./models/Book');
const Test = require('./models/Test');
const PPT = require('./models/PPT');
const Project = require('./models/Project');
const Assignment = require('./models/Assignment');

// Initialize express app
const app = express();

// ============ MIDDLEWARE ============

// Security middleware
app.use(helmet());

// CORS
app.use(cors());

// Body parser
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Compression
app.use(compression());

// Logging
app.use(morgan('dev'));

// Rate limiting
const limiter = rateLimit({
    windowMs: 10 * 60 * 1000, // 10 minutes
    max: 100 // limit each IP to 100 requests per windowMs
});
app.use('/api/', limiter);

// Serve static files
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// ============ ROUTES ============

app.get('/', (req, res) => {
    res.json({
        success: true,
        message: 'My Study Mate API Server',
        version: '1.0.0',
        status: 'running',
        timestamp: new Date().toISOString()
    });
});

app.get('/health', (req, res) => {
    res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Reset database and create super admin
app.get('/reset-database', async (req, res) => {
    try {
        // Clear users and notes
        await User.deleteMany({});
        try { await Note.deleteMany({}); } catch(e) {}
        
        // Create new super admin
        await User.create({
            name: 'Vishwajeet',
            email: 'vishuuforreal@gmail.com',
            password: 'Vishu123',
            role: 'superadmin',
            securityQuestion: 'What is your mothers maiden name?',
            securityAnswer: 'Rina'
        });
        
        res.json({ 
            success: true, 
            message: 'Users cleared and super admin created',
            name: 'Vishwajeet',
            email: 'vishuuforreal@gmail.com',
            password: 'Vishu123'
        });
    } catch (error) {
        res.json({ success: false, error: error.message });
    }
});



// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/student', studentRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/subjects', subjectRoutes);
app.use('/api', clearRoutes);

// 404 handler
app.use((req, res) => {
    res.status(404).json({
        success: false,
        message: 'Route not found'
    });
});

// Error handler
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({
        success: false,
        message: 'Server error',
        error: err.message
    });
});

// ============ DATABASE CONNECTION ============

const connectDB = async () => {
    try {
        if (!process.env.MONGODB_URI) {
            throw new Error('MONGODB_URI environment variable is not set');
        }
        
        const conn = await mongoose.connect(process.env.MONGODB_URI);

        console.log(`MongoDB Connected: ${conn.connection.host}`);

        // Create super admin if not exists
        await createSuperAdmin();
    } catch (error) {
        console.error(`Error: ${error.message}`);
        process.exit(1);
    }
};

// Create default super admin
const createSuperAdmin = async () => {
    try {
        // Check if super admin exists
        const existingSuperAdmin = await User.findOne({ role: 'superadmin' });
        
        if (!existingSuperAdmin) {
            // Create new super admin only if none exists
            await User.create({
                name: 'Vishwajeet',
                email: 'vishuuforreal@gmail.com',
                password: 'Vishu123',
                role: 'superadmin',
                securityQuestion: 'What is your mothers maiden name?',
                securityAnswer: 'Rina'
            });
            
            console.log('Super Admin created successfully');
            console.log('Email: vishuuforreal@gmail.com');
            console.log('Password: Vishu123');
        } else {
            console.log('Super Admin already exists');
        }
    } catch (error) {
        console.error('Error creating super admin:', error.message);
    }
};

// ============ START SERVER ============

const PORT = process.env.PORT || 8080;

// Start server immediately
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
    console.log(`API URL: http://localhost:${PORT}`);
});

// Connect to database in background
connectDB();

// Handle unhandled promise rejections
process.on('unhandledRejection', (err) => {
    console.log(`Error: ${err.message}`);
    process.exit(1);
});

module.exports = app;

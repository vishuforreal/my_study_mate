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

// Import models
const User = require('./models/User');

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

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/student', studentRoutes);
app.use('/api/admin', adminRoutes);

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
        const superAdminExists = await User.findOne({ role: 'superadmin' });

        if (!superAdminExists) {
            await User.create({
                name: process.env.SUPER_ADMIN_NAME || 'Super Admin',
                email: process.env.SUPER_ADMIN_EMAIL || 'admin@mystudymate.com',
                password: process.env.SUPER_ADMIN_PASSWORD || 'admin123',
                role: 'superadmin'
            });
            console.log('Super Admin created successfully');
            console.log(`Email: ${process.env.SUPER_ADMIN_EMAIL || 'admin@mystudymate.com'}`);
            console.log(`Password: ${process.env.SUPER_ADMIN_PASSWORD || 'admin123'}`);
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

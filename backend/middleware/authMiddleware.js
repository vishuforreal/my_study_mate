const jwt = require('jsonwebtoken');
const User = require('../models/User');

// Protect routes - verify JWT token
exports.protect = async (req, res, next) => {
    try {
        let token;

        // Check for token in headers
        if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
            token = req.headers.authorization.split(' ')[1];
        }

        if (!token) {
            return res.status(401).json({
                success: false,
                message: 'Not authorized to access this route'
            });
        }

        try {
            // Verify token
            const decoded = jwt.verify(token, process.env.JWT_SECRET);

            // Get user from token
            req.user = await User.findById(decoded.id).select('-password');

            if (!req.user) {
                return res.status(401).json({
                    success: false,
                    message: 'User not found'
                });
            }

            // Check if user is blocked
            if (req.user.isBlocked) {
                return res.status(403).json({
                    success: false,
                    message: 'Your account has been blocked. Please contact admin.'
                });
            }

            next();
        } catch (error) {
            return res.status(401).json({
                success: false,
                message: 'Not authorized to access this route'
            });
        }
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Server error in authentication'
        });
    }
};

// Authorize roles
exports.authorize = (...roles) => {
    return (req, res, next) => {
        if (!roles.includes(req.user.role)) {
            return res.status(403).json({
                success: false,
                message: `User role '${req.user.role}' is not authorized to access this route`
            });
        }
        next();
    };
};

// Check specific permissions
exports.checkPermission = (permissionType) => {
    return (req, res, next) => {
        // Admins and superadmins bypass permission checks
        if (req.user.role === 'admin' || req.user.role === 'superadmin') {
            return next();
        }

        // Check student permissions
        const permissionMap = {
            'notes': 'canAccessNotes',
            'books': 'canAccessBooks',
            'tests': 'canAccessTests',
            'ppts': 'canAccessPPTs',
            'projects': 'canAccessProjects',
            'assignments': 'canAccessAssignments'
        };

        const permission = permissionMap[permissionType];

        if (!permission || !req.user.permissions[permission]) {
            return res.status(403).json({
                success: false,
                message: `You don't have permission to access ${permissionType}`
            });
        }

        next();
    };
};

const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
    name: {
        type: String,
        required: [true, 'Please provide a name'],
        trim: true
    },
    email: {
        type: String,
        required: [true, 'Please provide an email'],
        unique: true,
        lowercase: true,
        trim: true,
        match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Please provide a valid email']
    },
    password: {
        type: String,
        required: [true, 'Please provide a password'],
        minlength: 6,
        select: false
    },
    phone: {
        type: String,
        trim: true
    },
    course: {
        type: String,
        enum: ['BCA', 'BBA', 'MBA', 'MCA', 'B.Tech', 'M.Tech', 'Class 10', 'Class 11', 'Class 12', 'SSC', 'UPSC', 'Other'],
        default: 'Other'
    },
    role: {
        type: String,
        enum: ['student', 'admin', 'superadmin'],
        default: 'student'
    },
    profilePhoto: {
        type: String,
        default: ''
    },
    isBlocked: {
        type: Boolean,
        default: false
    },
    permissions: {
        canAccessNotes: {
            type: Boolean,
            default: true
        },
        canAccessBooks: {
            type: Boolean,
            default: true
        },
        canAccessTests: {
            type: Boolean,
            default: true
        },
        canAccessPPTs: {
            type: Boolean,
            default: true
        },
        canAccessProjects: {
            type: Boolean,
            default: true
        },
        canAccessAssignments: {
            type: Boolean,
            default: true
        }
    },
    lastLogin: {
        type: Date
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
}, {
    timestamps: true
});

// Hash password before saving
userSchema.pre('save', async function (next) {
    if (!this.isModified('password')) {
        return next();
    }

    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next();
});

// Compare password method
userSchema.methods.comparePassword = async function (candidatePassword) {
    return await bcrypt.compare(candidatePassword, this.password);
};

module.exports = mongoose.model('User', userSchema);

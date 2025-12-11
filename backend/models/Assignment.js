const mongoose = require('mongoose');

const assignmentSchema = new mongoose.Schema({
    title: {
        type: String,
        required: [true, 'Please provide an assignment title'],
        trim: true
    },
    description: {
        type: String,
        required: [true, 'Please provide a description'],
        trim: true
    },
    subject: {
        type: String,
        required: [true, 'Please provide a subject'],
        trim: true
    },
    category: {
        type: String,
        required: [true, 'Please select a category'],
        enum: ['College', 'School', 'Competitive']
    },
    course: {
        type: String,
        required: [true, 'Please select a course']
    },
    assignmentFileUrl: {
        type: String,
        required: [true, 'Please upload assignment file']
    },
    solutionFileUrl: {
        type: String
    },
    deadline: {
        type: Date,
        required: [true, 'Please set a deadline']
    },
    totalMarks: {
        type: Number,
        default: 100
    },
    uploadedBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    downloads: {
        type: Number,
        default: 0
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
}, {
    timestamps: true
});

module.exports = mongoose.model('Assignment', assignmentSchema);

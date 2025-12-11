const mongoose = require('mongoose');

const pptSchema = new mongoose.Schema({
    title: {
        type: String,
        required: [true, 'Please provide a title'],
        trim: true
    },
    description: {
        type: String,
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
    fileUrl: {
        type: String,
        required: [true, 'Please upload PPT file']
    },
    thumbnailUrl: {
        type: String,
        default: ''
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

module.exports = mongoose.model('PPT', pptSchema);

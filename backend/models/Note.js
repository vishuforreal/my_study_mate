const mongoose = require('mongoose');

const noteSchema = new mongoose.Schema({
    title: {
        type: String,
        required: [true, 'Please provide a title'],
        trim: true
    },
    description: {
        type: String,
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
    subject: {
        type: String,
        required: [true, 'Please provide a subject'],
        trim: true
    },
    unit: {
        type: String,
        trim: true
    },
    chapter: {
        type: String,
        trim: true
    },
    notesFileUrl: {
        type: String,
        required: [true, 'Please upload notes file']
    },
    questionsFileUrl: {
        type: String
    },
    answersFileUrl: {
        type: String
    },
    isPaid: {
        type: Boolean,
        default: false
    },
    price: {
        type: Number,
        default: 0
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

module.exports = mongoose.model('Note', noteSchema);

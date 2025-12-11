const mongoose = require('mongoose');

const bookSchema = new mongoose.Schema({
    title: {
        type: String,
        required: [true, 'Please provide a book title'],
        trim: true
    },
    author: {
        type: String,
        required: [true, 'Please provide author name'],
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
        required: [true, 'Please select a category']
    },
    subcategory: {
        type: String
    },
    fileUrl: {
        type: String,
        required: [true, 'Please upload book file']
    },
    coverImage: {
        type: String,
        default: ''
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

module.exports = mongoose.model('Book', bookSchema);

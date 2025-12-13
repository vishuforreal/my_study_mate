const express = require('express');
const router = express.Router();
const Book = require('../models/Book');
const PPT = require('../models/PPT');
const Project = require('../models/Project');
const Assignment = require('../models/Assignment');
const Note = require('../models/Note');
const Test = require('../models/Test');

// @route   DELETE /api/clear-database
// @desc    Clear all content from database
// @access  Public (for development)
router.delete('/clear-database', async (req, res) => {
    try {
        await Book.deleteMany({});
        await PPT.deleteMany({});
        await Project.deleteMany({});
        await Assignment.deleteMany({});
        await Note.deleteMany({});
        await Test.deleteMany({});

        res.status(200).json({
            success: true,
            message: 'Database cleared successfully'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error clearing database',
            error: error.message
        });
    }
});

module.exports = router;
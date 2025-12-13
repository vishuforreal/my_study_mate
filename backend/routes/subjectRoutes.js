const express = require('express');
const router = express.Router();
const { protect, authorize } = require('../middleware/authMiddleware');
const Subject = require('../models/Subject');

// @route   GET /api/subjects
// @desc    Get subjects by category and subcategory (for students - filtered by their category)
// @access  Private
router.get('/', protect, async (req, res) => {
    try {
        let query = {};
        
        // If user is student, filter by their category/subcategory
        if (req.user.role === 'student') {
            // Match by subcategory since category is ObjectId in subjects
            query.subcategory = req.user.category;
            console.log('Student:', req.user.name, 'Category:', req.user.category, 'Subcategory:', req.user.subcategory);
        } else {
            // For admin/superadmin, allow query parameters
            const { category, subcategory } = req.query;
            if (category) query.category = category;
            if (subcategory) query.subcategory = subcategory;
        }

        console.log('Query:', JSON.stringify(query));
        const subjects = await Subject.find(query).sort({ name: 1 });
        console.log('Found subjects with query:', subjects.length);

        res.status(200).json({
            success: true,
            count: subjects.length,
            subjects
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching subjects',
            error: error.message
        });
    }
});

// @route   GET /api/subjects/admin
// @desc    Get all subjects (admin only)
// @access  Private (Admin)
router.get('/admin', protect, authorize('admin', 'superadmin'), async (req, res) => {
    try {
        const { category, subcategory } = req.query;
        
        let query = {};
        if (category) query.category = category;
        if (subcategory) query.subcategory = subcategory;

        const subjects = await Subject.find(query).sort({ name: 1 });

        res.status(200).json({
            success: true,
            count: subjects.length,
            subjects
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching subjects',
            error: error.message
        });
    }
});

// @route   POST /api/subjects
// @desc    Create new subject
// @access  Private (Admin)
router.post('/', protect, authorize('admin', 'superadmin'), async (req, res) => {
    try {
        const { name, category, subcategory } = req.body;

        const subjectExists = await Subject.findOne({ name, category, subcategory });
        if (subjectExists) {
            return res.status(400).json({
                success: false,
                message: 'Subject already exists in this category/subcategory'
            });
        }

        const subject = await Subject.create({
            name,
            category,
            subcategory,
            createdBy: req.user.id
        });



        res.status(201).json({
            success: true,
            message: 'Subject created successfully',
            subject
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error creating subject',
            error: error.message
        });
    }
});

// @route   PUT /api/subjects/:id
// @desc    Update subject
// @access  Private (Admin)
router.put('/:id', protect, authorize('admin', 'superadmin'), async (req, res) => {
    try {
        const { name } = req.body;
        
        const subject = await Subject.findByIdAndUpdate(
            req.params.id,
            { name },
            { new: true, runValidators: true }
);

        if (!subject) {
            return res.status(404).json({
                success: false,
                message: 'Subject not found'
            });
        }

        res.status(200).json({
            success: true,
            message: 'Subject updated successfully',
            subject
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error updating subject',
            error: error.message
        });
    }
});

// @route   DELETE /api/subjects/:id
// @desc    Delete subject
// @access  Private (Admin)
router.delete('/:id', protect, authorize('admin', 'superadmin'), async (req, res) => {
    try {
        const subject = await Subject.findByIdAndDelete(req.params.id);

        if (!subject) {
            return res.status(404).json({
                success: false,
                message: 'Subject not found'
            });
        }

        res.status(200).json({
            success: true,
            message: 'Subject deleted successfully'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error deleting subject',
            error: error.message
        });
    }
});

module.exports = router;
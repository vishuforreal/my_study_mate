const express = require('express');
const router = express.Router();
const { protect, authorize } = require('../middleware/authMiddleware');
const Category = require('../models/Category');

// @route   GET /api/categories
// @desc    Get all categories
// @access  Public
router.get('/', async (req, res) => {
    try {
        const categories = await Category.find().sort({ createdAt: -1 });
        res.status(200).json({
            success: true,
            categories
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching categories',
            error: error.message
        });
    }
});

// @route   POST /api/categories
// @desc    Create new category
// @access  Private (Admin)
router.post('/', protect, authorize('admin', 'superadmin'), async (req, res) => {
    try {
        const { name, type } = req.body;

        const categoryExists = await Category.findOne({ name });
        if (categoryExists) {
            return res.status(400).json({
                success: false,
                message: 'Category already exists'
            });
        }

        const category = await Category.create({
            name,
            type,
            createdBy: req.user.id
        });

        res.status(201).json({
            success: true,
            message: 'Category created successfully',
            category
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error creating category',
            error: error.message
        });
    }
});

// @route   POST /api/categories/:id/subcategories
// @desc    Add subcategory
// @access  Private (Admin)
router.post('/:id/subcategories', protect, authorize('admin', 'superadmin'), async (req, res) => {
    try {
        const { name } = req.body;
        const category = await Category.findById(req.params.id);

        if (!category) {
            return res.status(404).json({
                success: false,
                message: 'Category not found'
            });
        }

        category.subcategories.push({ name });
        await category.save();

        res.status(200).json({
            success: true,
            message: 'Subcategory added successfully',
            category
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error adding subcategory',
            error: error.message
        });
    }
});

// @route   PUT /api/categories/:id
// @desc    Update category
// @access  Private (Admin)
router.put('/:id', protect, authorize('admin', 'superadmin'), async (req, res) => {
    try {
        const { name, type } = req.body;
        
        const category = await Category.findByIdAndUpdate(
            req.params.id,
            { name, type },
            { new: true, runValidators: true }
        );

        if (!category) {
            return res.status(404).json({
                success: false,
                message: 'Category not found'
            });
        }

        res.status(200).json({
            success: true,
            message: 'Category updated successfully',
            category
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error updating category',
            error: error.message
        });
    }
});

// @route   DELETE /api/categories/:categoryId/subcategories/:subcategoryId
// @desc    Delete subcategory
// @access  Private (Admin)
router.delete('/:categoryId/subcategories/:subcategoryId', protect, authorize('admin', 'superadmin'), async (req, res) => {
    try {
        const category = await Category.findById(req.params.categoryId);

        if (!category) {
            return res.status(404).json({
                success: false,
                message: 'Category not found'
            });
        }

        category.subcategories = category.subcategories.filter(
            sub => sub._id.toString() !== req.params.subcategoryId
        );
        await category.save();

        res.status(200).json({
            success: true,
            message: 'Subcategory deleted successfully',
            category
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error deleting subcategory',
            error: error.message
        });
    }
});

// @route   DELETE /api/categories/:id
// @desc    Delete category
// @access  Private (Admin)
router.delete('/:id', protect, authorize('admin', 'superadmin'), async (req, res) => {
    try {
        const category = await Category.findByIdAndDelete(req.params.id);

        if (!category) {
            return res.status(404).json({
                success: false,
                message: 'Category not found'
            });
        }

        res.status(200).json({
            success: true,
            message: 'Category deleted successfully'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error deleting category',
            error: error.message
        });
    }
});

module.exports = router;
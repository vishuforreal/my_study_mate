const express = require('express');
const router = express.Router();
const { protect, authorize } = require('../middleware/authMiddleware');
const upload = require('../middleware/uploadMiddleware');
const { upload: cloudinaryUpload, uploadToCloudinary } = require('../middleware/cloudinaryUpload');
const User = require('../models/User');
const Note = require('../models/Note');
const Book = require('../models/Book');
const Test = require('../models/Test');
const PPT = require('../models/PPT');
const Project = require('../models/Project');
const Assignment = require('../models/Assignment');

// ============ SHARED ROUTES (Students + Admins) ============

// @route   GET /api/admin/notes/units/:subjectName
// @desc    Get units for a subject
// @access  Private (Admin/Student)
router.get('/notes/units/:subjectName', protect, async (req, res) => {
    try {
        let query = { subject: req.params.subjectName };
        
        // Filter by subcategory for students
        if (req.user.role === 'student') {
            query.subcategory = req.user.subcategory;
        }
        
        // For debugging - show all notes if no filter matches
        console.log('Units query:', JSON.stringify(query));
        let allNotes = await Note.find({ subject: req.params.subjectName });
        console.log('All notes for subject:', allNotes.length);
        console.log('Notes subcategories:', allNotes.map(n => n.subcategory));
        
        const units = await Note.find(query)
            .select('unit title notesFileUrl')
            .sort({ unit: 1 });
        
        console.log('Found units with filter:', units.length);

        const uniqueUnits = [...new Set(units.map(note => note.unit))]
            .sort((a, b) => parseInt(a) - parseInt(b))
            .map(unit => {
                const noteData = units.find(note => note.unit === unit);
                return {
                    unit: parseInt(unit),
                    title: noteData?.title || `Unit ${unit}`,
                    pdfUrl: noteData?.notesFileUrl || ''
                };
            });

        res.status(200).json({
            success: true,
            units: uniqueUnits
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching units',
            error: error.message
        });
    }
});

// All routes below require admin or superadmin role
router.use(protect);
router.use(authorize('admin', 'superadmin'));

// ============ STUDENT MANAGEMENT ============

// @route   GET /api/admin/students
// @desc    Get all students
// @access  Private (Admin)
router.get('/students', async (req, res) => {
    try {
        const students = await User.find({ role: 'student' }).select('-password').sort({ createdAt: -1 });

        res.status(200).json({
            success: true,
            count: students.length,
            students
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching students',
            error: error.message
        });
    }
});

// @route   PUT /api/admin/students/:id/block
// @desc    Block/Unblock student
// @access  Private (Admin)
router.put('/students/:id/block', async (req, res) => {
    try {
        const student = await User.findById(req.params.id);

        if (!student) {
            return res.status(404).json({
                success: false,
                message: 'Student not found'
            });
        }

        if (student.role !== 'student') {
            return res.status(400).json({
                success: false,
                message: 'Can only block students'
            });
        }

        student.isBlocked = !student.isBlocked;
        await student.save();

        res.status(200).json({
            success: true,
            message: `Student ${student.isBlocked ? 'blocked' : 'unblocked'} successfully`
        });
    } catch (error) {
        console.error('Block student error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error',
            error: error.message
        });
    }
});

// @route   PUT /api/admin/students/:id/permissions
// @desc    Update student permissions
// @access  Private (Admin)
router.put('/students/:id/permissions', async (req, res) => {
    try {
        const { permissions } = req.body;

        const student = await User.findById(req.params.id);

        if (!student || student.role !== 'student') {
            return res.status(404).json({
                success: false,
                message: 'Student not found'
            });
        }

        student.permissions = { ...student.permissions, ...permissions };
        await student.save();

        res.status(200).json({
            success: true,
            message: 'Permissions updated successfully',
            student
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error updating permissions',
            error: error.message
        });
    }
});

// ============ NOTES MANAGEMENT ============

// @route   GET /api/admin/notes
// @desc    Get all notes
// @access  Private (Admin)
router.get('/notes', async (req, res) => {
    try {
        const notes = await Note.find().populate('uploadedBy', 'name email').sort({ createdAt: -1 });

        res.status(200).json({
            success: true,
            count: notes.length,
            notes
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching notes',
            error: error.message
        });
    }
});



// @route   POST /api/admin/notes/simple
// @desc    Simple note upload without files
// @access  Private (Admin)
router.post('/notes/simple', async (req, res) => {
    try {
        const { title, subject, unit, category, subcategory } = req.body;

        const noteData = {
            title,
            subject,
            unit: parseInt(unit) || 1,
            category,
            subcategory,
            notesFileUrl: '',
            uploadedBy: req.user.id
        };

        const note = await Note.create(noteData);

        res.status(201).json({
            success: true,
            message: 'Note uploaded successfully',
            note
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error uploading note',
            error: error.message
        });
    }
});

// @route   POST /api/admin/notes
// @desc    Upload new note
// @access  Private (Admin)
router.post('/notes', async (req, res) => {
    try {
        const { title, subject, unit, category, subcategory } = req.body;

        const noteData = {
            title,
            subject,
            unit: parseInt(unit) || 1,
            category,
            subcategory,
            notesFileUrl: req.body.pdfLink || '',
            coverImageUrl: req.body.coverImageUrl || '',
            uploadedBy: req.user.id
        };

        const note = await Note.create(noteData);

        res.status(201).json({
            success: true,
            message: 'Note uploaded successfully',
            note
        });
    } catch (error) {
        console.error('Note upload error:', error);
        res.status(500).json({
            success: false,
            message: 'Error uploading note',
            error: error.message
        });
    }
});

// @route   PUT /api/admin/notes/:id
// @desc    Update note
// @access  Private (Admin)
router.put('/notes/:id', async (req, res) => {
    try {
        const note = await Note.findByIdAndUpdate(
            req.params.id,
            req.body,
            { new: true, runValidators: true }
        );

        if (!note) {
            return res.status(404).json({
                success: false,
                message: 'Note not found'
            });
        }

        res.status(200).json({
            success: true,
            message: 'Note updated successfully',
            note
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error updating note',
            error: error.message
        });
    }
});

// @route   DELETE /api/admin/notes/:id
// @desc    Delete note
// @access  Private (Admin)
router.delete('/notes/:id', async (req, res) => {
    try {
        const note = await Note.findByIdAndDelete(req.params.id);

        if (!note) {
            return res.status(404).json({
                success: false,
                message: 'Note not found'
            });
        }

        res.status(200).json({
            success: true,
            message: 'Note deleted successfully'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error deleting note',
            error: error.message
        });
    }
});

// @route   DELETE /api/admin/notes/unit/:subject/:unit
// @desc    Delete specific unit from subject
// @access  Private (Admin)
router.delete('/notes/unit/:subject/:unit', async (req, res) => {
    try {
        const { subject, unit } = req.params;
        
        const result = await Note.deleteMany({ 
            subject: subject, 
            unit: parseInt(unit) 
        });

        res.status(200).json({
            success: true,
            message: `Unit ${unit} deleted successfully`,
            deletedCount: result.deletedCount
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error deleting unit',
            error: error.message
        });
    }
});

// ============ BOOKS MANAGEMENT ============

// @route   GET /api/admin/books/units/:subjectName
// @desc    Get units for a subject (books)
// @access  Private (Admin/Student)
router.get('/books/units/:subjectName', protect, async (req, res) => {
    try {
        let query = { subject: req.params.subjectName };
        
        if (req.user.role === 'student') {
            query.subcategory = req.user.subcategory;
        }
        
        const units = await Book.find(query)
            .select('unit title fileUrl')
            .sort({ unit: 1 });

        const uniqueUnits = [...new Set(units.map(book => book.unit))]
            .sort((a, b) => parseInt(a) - parseInt(b))
            .map(unit => {
                const bookData = units.find(book => book.unit === unit);
                return {
                    unit: parseInt(unit),
                    title: bookData?.title || `Unit ${unit}`,
                    pdfUrl: bookData?.fileUrl || ''
                };
            });

        res.status(200).json({
            success: true,
            units: uniqueUnits
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching units',
            error: error.message
        });
    }
});

// @route   POST /api/admin/books
// @desc    Upload new book
// @access  Private (Admin)
router.post('/books', async (req, res) => {
    try {
        const { title, author, subject, unit, category, subcategory, pdfLink, coverImage } = req.body;

        const bookData = {
            title,
            author: author || 'Unknown',
            subject,
            unit: parseInt(unit) || 1,
            category,
            subcategory,
            fileUrl: pdfLink || '',
            coverImage: coverImage || '',
            uploadedBy: req.user.id
        };

        const book = await Book.create(bookData);

        res.status(201).json({
            success: true,
            message: 'Book uploaded successfully',
            book
        });
    } catch (error) {
        console.error('Book upload error:', error);
        res.status(500).json({
            success: false,
            message: 'Error uploading book',
            error: error.message
        });
    }
});

// @route   GET /api/admin/books
// @desc    Get all books
// @access  Private (Admin)
router.get('/books', async (req, res) => {
    try {
        const books = await Book.find().populate('uploadedBy', 'name email').sort({ createdAt: -1 });

        res.status(200).json({
            success: true,
            count: books.length,
            books
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching books',
            error: error.message
        });
    }
});

// @route   PUT /api/admin/books/:id
// @desc    Update book
// @access  Private (Admin)
router.put('/books/:id', async (req, res) => {
    try {
        const book = await Book.findByIdAndUpdate(
            req.params.id,
            req.body,
            { new: true, runValidators: true }
        );

        if (!book) {
            return res.status(404).json({
                success: false,
                message: 'Book not found'
            });
        }

        res.status(200).json({
            success: true,
            message: 'Book updated successfully',
            book
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error updating book',
            error: error.message
        });
    }
});

// @route   DELETE /api/admin/books/:id
// @desc    Delete book
// @access  Private (Admin)
router.delete('/books/:id', async (req, res) => {
    try {
        const book = await Book.findByIdAndDelete(req.params.id);

        if (!book) {
            return res.status(404).json({
                success: false,
                message: 'Book not found'
            });
        }

        res.status(200).json({
            success: true,
            message: 'Book deleted successfully'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error deleting book',
            error: error.message
        });
    }
});

// @route   DELETE /api/admin/books/unit/:subject/:unit
// @desc    Delete specific unit from subject (books)
// @access  Private (Admin)
router.delete('/books/unit/:subject/:unit', async (req, res) => {
    try {
        const { subject, unit } = req.params;
        
        const result = await Book.deleteMany({ 
            subject: subject, 
            unit: parseInt(unit) 
        });

        res.status(200).json({
            success: true,
            message: `Unit ${unit} deleted successfully`,
            deletedCount: result.deletedCount
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error deleting unit',
            error: error.message
        });
    }
});

// ============ TESTS MANAGEMENT ============

// @route   POST /api/admin/tests
// @desc    Create new test
// @access  Private (Admin)
router.post('/tests', async (req, res) => {
    try {
        const testData = {
            ...req.body,
            uploadedBy: req.user.id
        };

        const test = await Test.create(testData);

        res.status(201).json({
            success: true,
            message: 'Test created successfully',
            test
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error creating test',
            error: error.message
        });
    }
});

// @route   GET /api/admin/tests
// @desc    Get all tests
// @access  Private (Admin)
router.get('/tests', async (req, res) => {
    try {
        const tests = await Test.find().populate('uploadedBy', 'name email').sort({ createdAt: -1 });

        res.status(200).json({
            success: true,
            count: tests.length,
            tests
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching tests',
            error: error.message
        });
    }
});

// @route   PUT /api/admin/tests/:id
// @desc    Update test
// @access  Private (Admin)
router.put('/tests/:id', async (req, res) => {
    try {
        const test = await Test.findByIdAndUpdate(
            req.params.id,
            req.body,
            { new: true, runValidators: true }
        );

        if (!test) {
            return res.status(404).json({
                success: false,
                message: 'Test not found'
            });
        }

        res.status(200).json({
            success: true,
            message: 'Test updated successfully',
            test
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error updating test',
            error: error.message
        });
    }
});

// @route   DELETE /api/admin/tests/:id
// @desc    Delete test
// @access  Private (Admin)
router.delete('/tests/:id', async (req, res) => {
    try {
        const test = await Test.findByIdAndDelete(req.params.id);

        if (!test) {
            return res.status(404).json({
                success: false,
                message: 'Test not found'
            });
        }

        res.status(200).json({
            success: true,
            message: 'Test deleted successfully'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error deleting test',
            error: error.message
        });
    }
});

// ============ PPTs, PROJECTS, ASSIGNMENTS ============
// Similar CRUD operations for PPTs, Projects, and Assignments

// ============ PPTs MANAGEMENT ============

// @route   GET /api/admin/ppts/subjects/:subjectName
// @desc    Get PPTs for a subject
// @access  Private (Admin/Student)
router.get('/ppts/subjects/:subjectName', protect, async (req, res) => {
    try {
        let query = { subject: req.params.subjectName };
        
        if (req.user.role === 'student') {
            query.category = req.user.category;
        }
        
        const ppts = await PPT.find(query)
            .select('title description fileUrl thumbnailUrl')
            .sort({ createdAt: -1 });

        res.status(200).json({
            success: true,
            ppts
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching PPTs',
            error: error.message
        });
    }
});

// @route   POST /api/admin/ppts
router.post('/ppts', async (req, res) => {
    try {
        const pptData = {
            ...req.body,
            fileUrl: req.body.pptLink || req.body.fileUrl || '',
            uploadedBy: req.user.id
        };

        const ppt = await PPT.create(pptData);

        res.status(201).json({
            success: true,
            message: 'PPT uploaded successfully',
            ppt
        });
    } catch (error) {
        console.error('PPT upload error:', error);
        res.status(500).json({
            success: false,
            message: 'Error uploading PPT',
            error: error.message
        });
    }
});

// @route   GET /api/admin/ppts
router.get('/ppts', async (req, res) => {
    try {
        const ppts = await PPT.find().populate('uploadedBy', 'name email').sort({ createdAt: -1 });
        res.status(200).json({ success: true, count: ppts.length, ppts });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Error fetching PPTs', error: error.message });
    }
});

// @route   PUT /api/admin/ppts/:id
router.put('/ppts/:id', async (req, res) => {
    try {
        const ppt = await PPT.findByIdAndUpdate(
            req.params.id,
            req.body,
            { new: true, runValidators: true }
        );

        if (!ppt) {
            return res.status(404).json({ success: false, message: 'PPT not found' });
        }

        res.status(200).json({ success: true, message: 'PPT updated successfully', ppt });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Error updating PPT', error: error.message });
    }
});

// @route   DELETE /api/admin/ppts/:id
router.delete('/ppts/:id', async (req, res) => {
    try {
        const ppt = await PPT.findByIdAndDelete(req.params.id);
        if (!ppt) {
            return res.status(404).json({ success: false, message: 'PPT not found' });
        }
        res.status(200).json({ success: true, message: 'PPT deleted successfully' });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Error deleting PPT', error: error.message });
    }
});

// ============ PROJECTS MANAGEMENT ============

// @route   GET /api/admin/projects/category/:categoryName
// @desc    Get projects for a category
// @access  Private (Admin/Student)
router.get('/projects/category/:categoryName', protect, async (req, res) => {
    try {
        const query = { category: req.params.categoryName };
        
        const projects = await Project.find(query)
            .select('title description technology difficulty fileUrl thumbnailUrl tags')
            .sort({ createdAt: -1 });

        res.status(200).json({
            success: true,
            projects
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching projects',
            error: error.message
        });
    }
});

// @route   POST /api/admin/projects
router.post('/projects', async (req, res) => {
    try {
        const projectData = {
            ...req.body,
            fileUrl: req.body.projectLink || req.body.fileUrl || '',
            tags: req.body.tags || [],
            uploadedBy: req.user.id
        };

        const project = await Project.create(projectData);

        res.status(201).json({
            success: true,
            message: 'Project uploaded successfully',
            project
        });
    } catch (error) {
        console.error('Project upload error:', error);
        res.status(500).json({
            success: false,
            message: 'Error uploading project',
            error: error.message
        });
    }
});

// @route   GET /api/admin/projects
router.get('/projects', async (req, res) => {
    try {
        const projects = await Project.find().populate('uploadedBy', 'name email').sort({ createdAt: -1 });
        res.status(200).json({ success: true, count: projects.length, projects });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Error fetching projects', error: error.message });
    }
});

// @route   PUT /api/admin/projects/:id
router.put('/projects/:id', async (req, res) => {
    try {
        const project = await Project.findByIdAndUpdate(
            req.params.id,
            req.body,
            { new: true, runValidators: true }
        );

        if (!project) {
            return res.status(404).json({ success: false, message: 'Project not found' });
        }

        res.status(200).json({ success: true, message: 'Project updated successfully', project });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Error updating project', error: error.message });
    }
});

// @route   DELETE /api/admin/projects/:id
router.delete('/projects/:id', async (req, res) => {
    try {
        const project = await Project.findByIdAndDelete(req.params.id);
        if (!project) {
            return res.status(404).json({ success: false, message: 'Project not found' });
        }
        res.status(200).json({ success: true, message: 'Project deleted successfully' });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Error deleting project', error: error.message });
    }
});

// ============ ASSIGNMENTS MANAGEMENT ============

// @route   GET /api/admin/assignments/subjects/:subjectName
// @desc    Get assignments for a subject
// @access  Private (Admin/Student)
router.get('/assignments/subjects/:subjectName', protect, async (req, res) => {
    try {
        let query = { subject: req.params.subjectName };
        
        if (req.user.role === 'student') {
            query.category = req.user.category;
        }
        
        const assignments = await Assignment.find(query)
            .select('title description assignmentFileUrl solutionFileUrl deadline totalMarks')
            .sort({ deadline: 1 });

        res.status(200).json({
            success: true,
            assignments
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching assignments',
            error: error.message
        });
    }
});

// @route   POST /api/admin/assignments
router.post('/assignments', async (req, res) => {
    try {
        const assignmentData = {
            ...req.body,
            assignmentFileUrl: req.body.assignmentLink || req.body.assignmentFileUrl || '',
            solutionFileUrl: req.body.solutionLink || req.body.solutionFileUrl || '',
            uploadedBy: req.user.id
        };

        const assignment = await Assignment.create(assignmentData);

        res.status(201).json({
            success: true,
            message: 'Assignment created successfully',
            assignment
        });
    } catch (error) {
        console.error('Assignment upload error:', error);
        res.status(500).json({
            success: false,
            message: 'Error creating assignment',
            error: error.message
        });
    }
});

// @route   GET /api/admin/assignments
router.get('/assignments', async (req, res) => {
    try {
        const assignments = await Assignment.find().populate('uploadedBy', 'name email').sort({ createdAt: -1 });
        res.status(200).json({ success: true, count: assignments.length, assignments });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Error fetching assignments', error: error.message });
    }
});

// @route   PUT /api/admin/assignments/:id
router.put('/assignments/:id', async (req, res) => {
    try {
        const assignment = await Assignment.findByIdAndUpdate(
            req.params.id,
            req.body,
            { new: true, runValidators: true }
        );

        if (!assignment) {
            return res.status(404).json({ success: false, message: 'Assignment not found' });
        }

        res.status(200).json({ success: true, message: 'Assignment updated successfully', assignment });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Error updating assignment', error: error.message });
    }
});

// @route   DELETE /api/admin/assignments/:id
router.delete('/assignments/:id', async (req, res) => {
    try {
        const assignment = await Assignment.findByIdAndDelete(req.params.id);
        if (!assignment) {
            return res.status(404).json({ success: false, message: 'Assignment not found' });
        }
        res.status(200).json({ success: true, message: 'Assignment deleted successfully' });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Error deleting assignment', error: error.message });
    }
});

// ============ ANALYTICS ============

// @route   GET /api/admin/analytics
// @desc    Get system analytics
// @access  Private (Admin)
router.get('/analytics', async (req, res) => {
    try {
        const totalStudents = await User.countDocuments({ role: 'student' });
        const activeStudents = await User.countDocuments({ role: 'student', isBlocked: false });
        const totalNotes = await Note.countDocuments();
        const totalBooks = await Book.countDocuments();
        const totalTests = await Test.countDocuments();
        const totalPPTs = await PPT.countDocuments();
        const totalProjects = await Project.countDocuments();
        const totalAssignments = await Assignment.countDocuments();

        res.status(200).json({
            success: true,
            analytics: {
                students: {
                    total: totalStudents,
                    active: activeStudents,
                    blocked: totalStudents - activeStudents
                },
                content: {
                    notes: totalNotes,
                    books: totalBooks,
                    tests: totalTests,
                    ppts: totalPPTs,
                    projects: totalProjects,
                    assignments: totalAssignments,
                    total: totalNotes + totalBooks + totalTests + totalPPTs + totalProjects + totalAssignments
                }
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching analytics',
            error: error.message
        });
    }
});

// ============ DATABASE MANAGEMENT ============

// @route   DELETE /api/admin/clear-database
// @desc    Clear all content from database (Admin only)
// @access  Private (Admin)
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

// ============ SUPER ADMIN ONLY ============

// @route   GET /api/admin/admins
// @desc    Get all admins (Super Admin only)
// @access  Private (Super Admin)
router.get('/admins', authorize('superadmin'), async (req, res) => {
    try {
        const admins = await User.find({ role: { $in: ['admin', 'superadmin'] } })
            .select('-password')
            .sort({ createdAt: -1 });

        res.status(200).json({
            success: true,
            count: admins.length,
            admins
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error fetching admins',
            error: error.message
        });
    }
});

// @route   POST /api/admin/create-admin
// @desc    Create new admin (Super Admin only)
// @access  Private (Super Admin)
router.post('/create-admin', authorize('superadmin'), async (req, res) => {
    try {
        const { name, email, password } = req.body;

        const userExists = await User.findOne({ email });
        if (userExists) {
            return res.status(400).json({
                success: false,
                message: 'User already exists with this email'
            });
        }

        const admin = await User.create({
            name,
            email,
            password,
            role: 'admin',
            securityQuestion: 'What is your favorite color?',
            securityAnswer: 'blue'
        });

        res.status(201).json({
            success: true,
            message: 'Admin created successfully',
            admin: {
                id: admin._id,
                name: admin.name,
                email: admin.email,
                role: admin.role
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error creating admin',
            error: error.message
        });
    }
});

// @route   PUT /api/admin/admins/:id
// @desc    Update admin (Super Admin only)
// @access  Private (Super Admin)
router.put('/admins/:id', authorize('superadmin'), async (req, res) => {
    try {
        const { name, email } = req.body;
        
        const admin = await User.findById(req.params.id);
        if (!admin || !['admin', 'superadmin'].includes(admin.role)) {
            return res.status(404).json({
                success: false,
                message: 'Admin not found'
            });
        }

        admin.name = name || admin.name;
        admin.email = email || admin.email;
        await admin.save();

        res.status(200).json({
            success: true,
            message: 'Admin updated successfully',
            admin: {
                id: admin._id,
                name: admin.name,
                email: admin.email,
                role: admin.role
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error updating admin',
            error: error.message
        });
    }
});

// @route   DELETE /api/admin/admins/:id
// @desc    Delete admin (Super Admin only)
// @access  Private (Super Admin)
router.delete('/admins/:id', authorize('superadmin'), async (req, res) => {
    try {
        const admin = await User.findById(req.params.id);
        
        if (!admin || admin.role !== 'admin') {
            return res.status(404).json({
                success: false,
                message: 'Admin not found'
            });
        }

        if (admin.isSuperAdmin) {
            return res.status(400).json({
                success: false,
                message: 'Cannot delete super admin'
            });
        }

        await User.findByIdAndDelete(req.params.id);

        res.status(200).json({
            success: true,
            message: 'Admin deleted successfully'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error deleting admin',
            error: error.message
        });
    }
});

module.exports = router;
